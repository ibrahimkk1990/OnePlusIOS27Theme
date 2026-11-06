import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_info.dart';
import '../providers/apps_provider.dart';
import '../providers/edit_mode_provider.dart';
import '../widgets/ios_dock.dart';
import '../widgets/ios_paginated_grid.dart';

class LauncherHomeScreen extends ConsumerStatefulWidget {
  const LauncherHomeScreen({super.key});

  @override
  ConsumerState<LauncherHomeScreen> createState() => _LauncherHomeScreenState();
}

class _LauncherHomeScreenState extends ConsumerState<LauncherHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Selects up to 4 iconic launcher apps for the bottom Dock
  List<AppInfo> _extractDockApps(List<AppInfo> allApps) {
    if (allApps.isEmpty) return [];

    final dockKeywords = ['dialer', 'phone', 'contact', 'message', 'sms', 'chrome', 'browser', 'camera'];
    final List<AppInfo> dockList = [];

    // Prioritize key communication & browser apps
    for (final keyword in dockKeywords) {
      if (dockList.length >= 4) break;
      final match = allApps.firstWhere(
        (app) =>
            !dockList.contains(app) &&
            (app.packageName.toLowerCase().contains(keyword) ||
             app.appName.toLowerCase().contains(keyword)),
        orElse: () => const AppInfo(appName: '', packageName: ''),
      );
      if (match.packageName.isNotEmpty) {
        dockList.add(match);
      }
    }

    // Fill remaining dock slots up to 4 if needed
    for (final app in allApps) {
      if (dockList.length >= 4) break;
      if (!dockList.contains(app)) {
        dockList.add(app);
      }
    }

    return dockList;
  }

  void _onAppTap(AppInfo app) async {
    // If in edit mode, tapping app shouldn't launch
    if (ref.read(editModeProvider)) {
      return;
    }

    final success = await ref.read(appsProvider.notifier).launchApp(app);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch ${app.appName}'),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appsState = ref.watch(appsProvider);
    final appsNotifier = ref.read(appsProvider.notifier);
    final isEditMode = ref.watch(editModeProvider);

    // Dock apps and paginated apps separation
    final dockApps = _extractDockApps(appsState.apps);
    final gridApps = _isSearching
        ? appsState.filteredApps
        : appsState.apps.where((app) => !dockApps.contains(app)).toList();

    return Scaffold(
      backgroundColor: Colors.transparent, // Displays system wallpaper seamlessly
      body: GestureDetector(
        onTap: () {
          // Tapping wallpaper or empty space exits edit mode
          if (isEditMode) {
            ref.read(editModeProvider.notifier).exitEditMode();
          }
        },
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header: Toggle between Spotlight Search and Edit Mode "Done" Action
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: isEditMode
                      ? Row(
                          key: const ValueKey('edit_mode_header'),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Edit Home Screen',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                                ],
                              ),
                            ),
                            // iOS "Done" Pill Button
                            GestureDetector(
                              onTap: () {
                                ref.read(editModeProvider.notifier).exitEditMode();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.28),
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    width: 1.0,
                                  ),
                                ),
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          key: const ValueKey('search_header'),
                          borderRadius: BorderRadius.circular(16.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                            child: Container(
                              height: 42.0,
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 0.6,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search_rounded, color: Colors.white70, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      cursorColor: Colors.white,
                                      onChanged: (val) {
                                        setState(() {
                                          _isSearching = val.trim().isNotEmpty;
                                        });
                                        appsNotifier.setSearchQuery(val);
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Search Apps...',
                                        hintStyle: TextStyle(color: Colors.white60, fontSize: 14.5),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        appsNotifier.setSearchQuery('');
                                        setState(() {
                                          _isSearching = false;
                                        });
                                      },
                                      child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ),

              // Main Content: Horizontally Paginated GridView
              Expanded(
                child: appsState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : appsState.errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Failed to load apps: ${appsState.errorMessage}',
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => appsNotifier.loadApps(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : IOSPaginatedGrid(
                            apps: gridApps,
                            onAppTap: _onAppTap,
                          ),
              ),

              // Persistent iOS Bottom Dock (holds up to 4 icons)
              SafeArea(
                top: false,
                child: IOSDock(
                  dockApps: dockApps,
                  onAppTap: _onAppTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
