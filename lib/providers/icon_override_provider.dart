import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/icon_override_service.dart';

final iconOverrideServiceProvider = Provider<IconOverrideService>((ref) {
  return IconOverrideService();
});

class IconOverridesNotifier extends Notifier<Map<String, String>> {
  late final IconOverrideService _service;

  @override
  Map<String, String> build() {
    _service = ref.watch(iconOverrideServiceProvider);
    Future.microtask(() => loadOverrides());
    return const {};
  }

  Future<void> loadOverrides() async {
    final mappings = await _service.loadMappings();
    state = mappings;
  }

  Future<void> setOverride(String packageName, String assetPath) async {
    await _service.setOverride(packageName, assetPath);
    state = {
      ...state,
      packageName: assetPath,
    };
  }

  Future<void> removeOverride(String packageName) async {
    await _service.removeOverride(packageName);
    final updated = Map<String, String>.from(state)..remove(packageName);
    state = updated;
  }
}

final iconOverridesProvider =
    NotifierProvider<IconOverridesNotifier, Map<String, String>>(() {
  return IconOverridesNotifier();
});
