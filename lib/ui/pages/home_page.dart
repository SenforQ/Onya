import 'package:flutter/material.dart';

import '../../services/coin_service.dart';
import 'ai_chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _requiredCoins = 100;

  Future<void> _handleStartExercising() async {
    // 显示二次确认对话框
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C0325),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: <Widget>[
              Icon(
                Icons.monetization_on,
                color: Color(0xFFFFD700),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Confirm Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Start music teacher session?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Container(
                    width: 24,
                    height: 24,
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
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_requiredCoins coins will be deducted',
                      style: const TextStyle(
                        color: Color(0xFF68B6FF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Color(0xFF68B6FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    // 检查余额
    final int currentCoins = await CoinService.getCurrentCoins();
    if (currentCoins < _requiredCoins) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient coins. You need $_requiredCoins coins to start the music teacher session.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // 扣除金币
    final bool success = await CoinService.spendCoins(_requiredCoins);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to deduct coins. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 导航到AI聊天页面
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<AiChatPage>(
          builder: (BuildContext context) => const AiChatPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double topSafe = MediaQuery.of(context).padding.top;
    final double imageWidth = 375 - 80;
    final double imageHeight = imageWidth * 0.98;
    final double imageY = screenSize.height - imageHeight - 86;
    final double imageX = (screenSize.width - imageWidth) / 2;
    
    final double topImageWidth = screenSize.width - 40;
    final double topImageTop = topSafe + 12;
    final double topImageHeight = imageY - topImageTop - 12;
    final double topImageLeft = (screenSize.width - topImageWidth) / 2;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0138),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/mine_bg.webp',
              width: screenSize.width,
              height: screenSize.height,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: topImageLeft,
            top: topImageTop,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: topImageWidth,
                height: topImageHeight,
                child: Stack(
                  children: <Widget>[
                    Image.asset(
                      'assets/home_top_bg.webp',
                      width: topImageWidth,
                      height: topImageHeight,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: const Color(0xFF1C0325),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.info_outline,
                                      color: Color(0xFF68B6FF),
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Music Teacher',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      'Each use of the music teacher requires 100 coins.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          width: 24,
                                          height: 24,
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
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '100 coins per session',
                                          style: TextStyle(
                                            color: Color(0xFF68B6FF),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Got it',
                                      style: TextStyle(
                                        color: Color(0xFF68B6FF),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Stack(
                        children: <Widget>[
                          Image.asset(
                            'assets/home_topimg_cover.webp',
                            width: topImageWidth,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            top: 0,
                            child: Center(
                              child: ElevatedButton(
                                onPressed: _handleStartExercising,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      width: 24,
                                      height: 24,
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
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Start exercising',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '100 coins',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: imageX,
            top: imageY,
            child: Image.asset(
              'assets/home_music_bottom.webp',
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

