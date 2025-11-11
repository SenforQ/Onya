import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class ATTService {
  /// 请求追踪权限
  /// 返回 true 表示用户授权，false 表示用户拒绝或未授权
  static Future<bool> requestTrackingPermission() async {
    if (!Platform.isIOS) {
      debugPrint('ATT is only available on iOS');
      return false;
    }

    try {
      // 检查追踪状态
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('Current ATT status: $status');

      // 如果已经授权，直接返回 true
      if (status == TrackingStatus.authorized) {
        debugPrint('ATT already authorized');
        return true;
      }

      // 如果状态是未确定，请求权限
      if (status == TrackingStatus.notDetermined) {
        debugPrint('Requesting ATT permission...');
        final result = await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('ATT permission result: $result');
        return result == TrackingStatus.authorized;
      }

      // 其他情况（拒绝、限制等）返回 false
      debugPrint('ATT status is not authorized: $status');
      return false;
    } catch (e, stackTrace) {
      debugPrint('Error requesting ATT permission: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// 获取当前追踪状态
  static Future<TrackingStatus?> getTrackingStatus() async {
    if (!Platform.isIOS) {
      return null;
    }

    try {
      return await AppTrackingTransparency.trackingAuthorizationStatus;
    } catch (e) {
      debugPrint('Error getting ATT status: $e');
      return null;
    }
  }

  /// 检查是否已授权
  static Future<bool> isAuthorized() async {
    final status = await getTrackingStatus();
    return status == TrackingStatus.authorized;
  }
}

