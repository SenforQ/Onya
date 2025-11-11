import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../services/coin_service.dart';

// 金币产品常量
class CoinProduct {
  const CoinProduct({
    required this.productId,
    required this.coins,
    required this.price,
    required this.priceText,
  });

  final String productId;
  final int coins;
  final double price;
  final String priceText;
}

final List<CoinProduct> kCoinProducts = <CoinProduct>[
  const CoinProduct(productId: 'Onya', coins: 32, price: 0.99, priceText: '\$0.99'),
  const CoinProduct(productId: 'Onya1', coins: 60, price: 1.99, priceText: '\$1.99'),
  const CoinProduct(productId: 'Onya2', coins: 96, price: 2.99, priceText: '\$2.99'),
  const CoinProduct(productId: 'Onya4', coins: 155, price: 4.99, priceText: '\$4.99'),
  const CoinProduct(productId: 'Onya5', coins: 189, price: 5.99, priceText: '\$5.99'),
  const CoinProduct(productId: 'Onya9', coins: 359, price: 9.99, priceText: '\$9.99'),
  const CoinProduct(productId: 'Onya19', coins: 729, price: 19.99, priceText: '\$19.99'),
  const CoinProduct(productId: 'Onya49', coins: 1869, price: 49.99, priceText: '\$49.99'),
  const CoinProduct(productId: 'Onya99', coins: 3799, price: 99.99, priceText: '\$99.99'),
  const CoinProduct(productId: 'Onya159', coins: 5999, price: 159.99, priceText: '\$159.99'),
  const CoinProduct(productId: 'Onya239', coins: 9059, price: 239.99, priceText: '\$239.99'),
];

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int _currentCoins = 0;
  int _selectedIndex = 0; // 默认选中第一个产品
  bool _isPurchasing = false; // 全局购买状态
  final Map<String, Timer> _timeoutTimers = {}; // 为每个商品管理超时定时器

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  Map<String, ProductDetails> _products = {};
  int _retryCount = 0;
  static const int maxRetries = 3;
  static const int timeoutDuration = 30; // 30秒超时

  // 处理购买超时
  void _handlePurchaseTimeout() {
    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });

      // 取消定时器
      _timeoutTimers['purchase']?.cancel();
      _timeoutTimers.remove('purchase');

      // 显示超时提示
      try {
        _showToast('Payment timeout. Please try again.');
      } catch (e) {
        debugPrint('Failed to show timeout toast: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeUserAndLoadCoins();
    _checkConnectivityAndInit();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    // 取消所有超时定时器
    for (final timer in _timeoutTimers.values) {
      timer.cancel();
    }
    _timeoutTimers.clear();
    super.dispose();
  }

  Future<void> _checkConnectivityAndInit() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.none)) {
        _showToast('No internet connection. Please check your network settings.');
        return;
      }
    } catch (e) {
      // 如果连接检查失败（例如插件未注册），直接继续初始化IAP
      // IAP 系统本身会处理连接问题
      debugPrint('Connectivity check failed: $e');
    }
    await _initIAP();
  }

  Future<void> _initIAP() async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!mounted) return;
      setState(() {
        _isAvailable = available;
      });
      if (!available) {
        if (mounted) {
          _showToast('In-App Purchase not available');
        }
        return;
      }

      final Set<String> kIds = kCoinProducts.map((CoinProduct e) => e.productId).toSet();
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(kIds);
      if (response.error != null) {
        if (_retryCount < maxRetries) {
          _retryCount++;
          await Future<void>.delayed(const Duration(seconds: 2));
          await _initIAP();
          return;
        }
        _showToast('Failed to load products: ${response.error!.message}');
      }

      setState(() {
        _products = <String, ProductDetails>{for (ProductDetails p in response.productDetails) p.id: p};
      });

      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () {
          _subscription?.cancel();
        },
        onError: (Object e) {
          if (mounted) {
            _showToast('Purchase error: ${e.toString()}');
          }
        },
      );
    } catch (e) {
      if (_retryCount < maxRetries) {
        _retryCount++;
        await Future<void>.delayed(const Duration(seconds: 2));
        await _initIAP();
      } else {
        if (mounted) {
          _showToast('Failed to initialize in-app purchases. Please try again later.');
        }
      }
    }
  }

  Future<void> _initializeUserAndLoadCoins() async {
    // 静默初始化新用户（只在首次进入时执行）
    await CoinService.initializeNewUser();
    await _loadCoins();
  }

  Future<void> _loadCoins() async {
    final int coins = await CoinService.getCurrentCoins();
    setState(() {
      _currentCoins = coins;
    });
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      // 只有在购买成功或恢复购买时才添加金币
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        // 先完成购买确认
        await _inAppPurchase.completePurchase(purchase);

        // 验证购买是否真的成功
        if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
          // 找到对应的产品并添加金币
          final CoinProduct product = kCoinProducts.firstWhere(
            (CoinProduct p) => p.productId == purchase.productID,
            orElse: () => const CoinProduct(productId: '', coins: 0, price: 0, priceText: ''),
          );

          // 只有在找到有效产品且金币数量大于0时才添加
          if (product.coins > 0) {
            final bool success = await CoinService.addCoins(product.coins);

            if (success && mounted) {
              await _loadCoins(); // 重新加载金币余额

              // 显示成功提示
              try {
                _showToast('Successfully purchased ${product.coins} coins!');
              } catch (e) {
                debugPrint('Failed to show success toast: $e');
              }
            } else {
              // 添加金币失败
              if (mounted) {
                try {
                  _showToast('Failed to add coins. Please contact support.');
                } catch (e) {
                  debugPrint('Failed to show error toast: $e');
                }
              }
            }
          }
        }
      } else if (purchase.status == PurchaseStatus.error) {
        if (mounted) {
          try {
            _showToast('Purchase failed: ${purchase.error?.message ?? ''}');
          } catch (e) {
            debugPrint('Failed to show error toast: $e');
          }
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        if (mounted) {
          try {
            _showToast('Purchase canceled.');
          } catch (e) {
            debugPrint('Failed to show cancel toast: $e');
          }
        }
      }

      // 清除购买状态和超时定时器
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });

        // 取消所有超时定时器
        for (final Timer timer in _timeoutTimers.values) {
          timer.cancel();
        }
        _timeoutTimers.clear();
      }
    }
  }

  Future<void> _handleConfirmPurchase() async {
    if (!_isAvailable) {
      _showToast('Store is not available');
      return;
    }

    // 获取选中的产品
    final CoinProduct selectedProduct = kCoinProducts[_selectedIndex];

    setState(() {
      _isPurchasing = true; // 使用全局购买状态
    });

    // 设置30秒超时定时器
    _timeoutTimers['purchase'] = Timer(
      const Duration(seconds: timeoutDuration),
      () => _handlePurchaseTimeout(),
    );

    try {
      // 尝试获取对应的产品详情
      final ProductDetails? product = _products[selectedProduct.productId];

      // 如果没有找到对应的产品，使用第一个可用的产品进行购买
      ProductDetails? productToUse = product;
      if (productToUse == null && _products.isNotEmpty) {
        productToUse = _products.values.first;
      }

      if (productToUse == null) {
        throw Exception('No products available for purchase');
      }

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productToUse);
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      // 取消超时定时器
      _timeoutTimers['purchase']?.cancel();
      _timeoutTimers.remove('purchase');

      if (mounted) {
        _showToast('Purchase failed: ${e.toString()}');
      }
      setState(() {
        _isPurchasing = false; // 清除购买状态
      });
    }
  }

  void _showToast(String message) {
    if (mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) => Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0138),
      body: Stack(
        children: <Widget>[
          // 背景图片
          Positioned(
            left: 0,
            top: 0,
            width: screenSize.width,
            height: screenSize.height,
            child: Image.asset(
              'assets/mine_bg.webp',
              width: screenSize.width,
              height: screenSize.height,
              fit: BoxFit.cover,
            ),
          ),
          // 返回按钮
          Positioned(
            top: statusBarHeight,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/nav_back.webp',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // 主要内容
          SafeArea(
            child: Column(
              children: <Widget>[
                SizedBox(height: statusBarHeight > 0 ? 20 : 40),
                // 标题和说明按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'My Coins',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showCoinInfoDialog();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: <Color>[Color(0xFF68B6FF), Color(0xFFA256FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // 余额显示区域
                Text(
                  _currentCoins.toString(),
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                // 购买选项区域
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: <Widget>[
                        // 购买选项列表
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: kCoinProducts.length,
                          itemBuilder: (BuildContext context, int index) {
                            final CoinProduct product = kCoinProducts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildPurchaseOption(product),
                            );
                          },
                        ),
                        SizedBox(height: safeAreaBottom + 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 购买Loading覆盖层
          if (_isPurchasing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5197FF)),
                    strokeWidth: 4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOption(CoinProduct product) {
    return GestureDetector(
      onTap: _isPurchasing
          ? null
          : () {
              HapticFeedback.lightImpact();
              _onProductSelected(product);
            },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: _isPurchasing
              ? const Color(0xFF2D1B69).withOpacity(0.4)
              : const Color(0xFF2D1B69).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 20),
            // 金币图标
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFFFFD700), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 20),
            // 金币数量和描述
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${product.coins} Coins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // 价格按钮
            Container(
              width: 100,
              height: 40,
              margin: const EdgeInsets.only(right: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFF68B6FF), Color(0xFFA256FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Center(
                child: Text(
                  product.priceText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onProductSelected(CoinProduct product) {
    // 更新选中的产品索引
    final int productIndex = kCoinProducts.indexWhere((CoinProduct p) => p.productId == product.productId);
    if (productIndex != -1) {
      setState(() {
        _selectedIndex = productIndex;
      });
    }

    // 显示确认对话框
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: <Widget>[
              Icon(
                Icons.diamond,
                color: Color(0xFFFFD700),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Confirm Purchase',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to purchase ${product.coins} coins for ${product.priceText}?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleConfirmPurchase();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80FED6),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Purchase',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 显示金币说明对话框
  void _showCoinInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C0325),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xFF8B5CF6), Color(0xFFE91E63)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: const Icon(
                  Icons.diamond,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Coin Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildCoinInfoRule(
                '1',
                'Each robot workout costs 200 Coins.',
              ),
              const SizedBox(height: 16),
              _buildCoinInfoRule(
                '2',
                'It costs 200 Coins to unlock someone else\'s music demo each time.',
              ),
              const SizedBox(height: 16),
              _buildCoinInfoRule(
                '3',
                'Coins are obtained through in-app purchases',
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 构建金币说明规则
  Widget _buildCoinInfoRule(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xFF8B5CF6), Color(0xFFE91E63)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFCCCCCC),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
