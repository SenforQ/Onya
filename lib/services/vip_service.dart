import 'package:shared_preferences/shared_preferences.dart';

class VipService {
  static const String _vipActiveKey = 'vip_active';
  static const String _vipPurchaseDateKey = 'vip_purchase_date';
  static const String _vipProductIdKey = 'vip_product_id';
  static const String _vipExpiryDateKey = 'vip_expiry_date';

  static Future<bool> isVipActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vipActiveKey) ?? false;
  }

  static Future<bool> isVipExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDateStr = prefs.getString(_vipExpiryDateKey);
    if (expiryDateStr == null) {
      return false;
    }
    try {
      final expiryDate = DateTime.parse(expiryDateStr);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return false;
    }
  }

  static Future<void> activateVip({
    required String productId,
    required String purchaseDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final purchaseDateTime = DateTime.parse(purchaseDate);
    
    // 根据产品ID确定VIP时长
    int daysToAdd = 7; // 默认7天
    if (productId == 'vip_monthly') {
      daysToAdd = 30;
    }
    
    final expiryDate = purchaseDateTime.add(Duration(days: daysToAdd));
    
    await prefs.setBool(_vipActiveKey, true);
    await prefs.setString(_vipPurchaseDateKey, purchaseDate);
    await prefs.setString(_vipProductIdKey, productId);
    await prefs.setString(_vipExpiryDateKey, expiryDate.toIso8601String());
  }

  static Future<void> deactivateVip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vipActiveKey, false);
    await prefs.remove(_vipPurchaseDateKey);
    await prefs.remove(_vipProductIdKey);
    await prefs.remove(_vipExpiryDateKey);
  }

  static Future<int> getVipRemainingDays() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDateStr = prefs.getString(_vipExpiryDateKey);
    if (expiryDateStr == null) {
      return 0;
    }
    try {
      final expiryDate = DateTime.parse(expiryDateStr);
      final now = DateTime.now();
      if (now.isAfter(expiryDate)) {
        return 0;
      }
      return expiryDate.difference(now).inDays;
    } catch (e) {
      return 0;
    }
  }

  static Future<String?> getVipPurchaseDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_vipPurchaseDateKey);
  }
}

