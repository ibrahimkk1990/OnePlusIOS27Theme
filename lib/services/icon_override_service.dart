import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class IconOverrideService {
  static const String _storageKey = 'ios27_icon_override_mappings';

  // Default presets for iOS 27 Theme
  static final Map<String, String> _defaultPresets = {
    // Chrome -> Safari
    'com.android.chrome': 'assets/icons/safari.png',
    'com.google.android.apps.chrome': 'assets/icons/safari.png',
    // Phone / Dialer -> iOS Phone
    'com.google.android.dialer': 'assets/icons/phone.png',
    'com.android.dialer': 'assets/icons/phone.png',
    'com.oneplus.dialer': 'assets/icons/phone.png',
    // Messages -> iOS Messages
    'com.google.android.apps.messaging': 'assets/icons/messages.png',
    'com.android.mms': 'assets/icons/messages.png',
    'com.oneplus.mms': 'assets/icons/messages.png',
    // Camera -> iOS Camera
    'com.google.android.GoogleCamera': 'assets/icons/camera.png',
    'com.android.camera': 'assets/icons/camera.png',
    'com.oneplus.camera': 'assets/icons/camera.png',
  };

  /// Loads all package-to-asset mappings from local storage
  Future<Map<String, String>> loadMappings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);

    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        final result = Map<String, String>.from(_defaultPresets);
        decoded.forEach((key, value) {
          if (value is String) {
            result[key] = value;
          }
        });
        return result;
      } catch (e) {
        return Map<String, String>.from(_defaultPresets);
      }
    }

    // First run: save and return default presets
    await saveMappings(_defaultPresets);
    return Map<String, String>.from(_defaultPresets);
  }

  /// Saves all mappings to local SharedPreferences
  Future<void> saveMappings(Map<String, String> mappings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(mappings));
  }

  /// Sets or updates a single mapping
  Future<void> setOverride(String packageName, String assetPath) async {
    final mappings = await loadMappings();
    mappings[packageName] = assetPath;
    await saveMappings(mappings);
  }

  /// Removes an override for a package
  Future<void> removeOverride(String packageName) async {
    final mappings = await loadMappings();
    mappings.remove(packageName);
    await saveMappings(mappings);
  }

  /// Gets the custom asset override path if one exists
  Future<String?> getOverride(String packageName) async {
    final mappings = await loadMappings();
    return mappings[packageName];
  }
}
