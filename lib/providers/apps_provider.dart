import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_info.dart';
import '../services/app_channel_service.dart';

final appChannelServiceProvider = Provider<AppChannelService>((ref) {
  return AppChannelService();
});

class AppsState {
  final List<AppInfo> apps;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  const AppsState({
    this.apps = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  List<AppInfo> get filteredApps {
    if (searchQuery.trim().isEmpty) {
      return apps;
    }
    final query = searchQuery.toLowerCase().trim();
    return apps.where((app) {
      return app.appName.toLowerCase().contains(query) ||
          app.packageName.toLowerCase().contains(query);
    }).toList();
  }

  AppsState copyWith({
    List<AppInfo>? apps,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return AppsState(
      apps: apps ?? this.apps,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AppsNotifier extends Notifier<AppsState> {
  late final AppChannelService _channelService;

  @override
  AppsState build() {
    _channelService = ref.watch(appChannelServiceProvider);
    Future.microtask(() => loadApps());
    return const AppsState(isLoading: true);
  }

  Future<void> loadApps() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final apps = await _channelService.getInstalledApps();
      state = state.copyWith(
        apps: apps,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> launchApp(AppInfo app) async {
    return await _channelService.launchApp(app.packageName);
  }
}

final appsProvider = NotifierProvider<AppsNotifier, AppsState>(() {
  return AppsNotifier();
});
