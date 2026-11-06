import 'dart:typed_data';

class AppInfo {
  final String appName;
  final String packageName;
  final String? activityName;
  final Uint8List? iconBytes;

  const AppInfo({
    required this.appName,
    required this.packageName,
    this.activityName,
    this.iconBytes,
  });

  factory AppInfo.fromMap(Map<dynamic, dynamic> map) {
    return AppInfo(
      appName: map['appName'] as String? ?? 'Unknown App',
      packageName: map['packageName'] as String? ?? '',
      activityName: map['activityName'] as String?,
      iconBytes: map['icon'] != null ? Uint8List.fromList((map['icon'] as List).cast<int>()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'packageName': packageName,
      'activityName': activityName,
      'icon': iconBytes,
    };
  }

  @override
  String toString() => 'AppInfo(appName: $appName, packageName: $packageName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfo &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;
}
