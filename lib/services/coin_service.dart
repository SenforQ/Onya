import 'package:shared_preferences/shared_preferences.dart';

class CoinService {
  static const String _coinsKey = 'user_coins';

  /// 初始化新用户（只在首次进入时执行）
  static Future<void> initializeNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    // 如果用户还没有金币记录，初始化为0
    if (!prefs.containsKey(_coinsKey)) {
      await prefs.setInt(_coinsKey, 0);
    }
  }

  /// 获取当前金币数量
  static Future<int> getCurrentCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 0;
  }

  /// 添加金币
  static Future<bool> addCoins(int coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCoins = prefs.getInt(_coinsKey) ?? 0;
      await prefs.setInt(_coinsKey, currentCoins + coins);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 消费金币
  static Future<bool> spendCoins(int coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCoins = prefs.getInt(_coinsKey) ?? 0;
      if (currentCoins >= coins) {
        await prefs.setInt(_coinsKey, currentCoins - coins);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

