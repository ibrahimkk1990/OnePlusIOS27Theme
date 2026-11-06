import 'package:flutter/services.dart';
import '../models/app_info.dart';

class AppChannelService {
  static const MethodChannel _channel = MethodChannel('com.oneplus.ios27/apps');

  /// Fetches the list of all user-launchable apps installed on the Android device.
  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<dynamic>? rawApps = await _channel.invokeListMethod<dynamic>('getInstalledApps');
      if (rawApps == null) return [];

      return rawApps.map((item) {
        if (item is Map) {
          return AppInfo.fromMap(item);
        }
        return AppInfo(appName: 'Unknown', packageName: '');
      }).where((app) => app.packageName.isNotEmpty).toList();
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('Failed to get installed apps from native channel: ${e.message}');
      return [];
    }
  }

  /// Launches an application by its package name using Android Intent.
  Future<bool> launchApp(String packageName) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'launchApp',
        {'packageName': packageName},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('Failed to launch app $packageName: ${e.message}');
      return false;
    }
  }
}
