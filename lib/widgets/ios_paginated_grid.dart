import 'package:flutter/material.dart';
import '../models/app_info.dart';
import 'ios_app_icon.dart';
import 'sample_widgets/battery_widget.dart';
import 'sample_widgets/weather_widget.dart';

class IOSPaginatedGrid extends StatefulWidget {
  final List<AppInfo> apps;
  final Function(AppInfo) onAppTap;
  final Widget? Function(int pageIndex)? headerWidgetBuilder;

  const IOSPaginatedGrid({
    super.key,
    required this.apps,
    required this.onAppTap,
    this.headerWidgetBuilder,
  });

  @override
  State<IOSPaginatedGrid> createState() => _IOSPaginatedGridState();
}

class _IOSPaginatedGridState extends State<IOSPaginatedGrid> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget? _getDefaultHeader(int pageIndex) {
    if (widget.headerWidgetBuilder != null) {
      return widget.headerWidgetBuilder!(pageIndex);
    }
    // Default iOS setup:
    // Page 0: Medium Battery Widget (4x2)
    // Page 1: Small Weather Widget (2x2)
    if (pageIndex == 0) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 14.0),
        child: BatteryWidget(),
      );
    } else if (pageIndex == 1) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 14.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: WeatherWidget(),
        ),
      );
    }
    return null;
  }

  List<List<AppInfo>> _chunkApps() {
    if (widget.apps.isEmpty) return [];

    final List<List<AppInfo>> pages = [];
    int cursor = 0;
    int pageIndex = 0;

    while (cursor < widget.apps.length) {
      final hasHeader = _getDefaultHeader(pageIndex) != null;
      final capacity = hasHeader ? 12 : 24; // 12 apps (3 rows) with widget, 24 apps (6 rows) without
      final end = (cursor + capacity < widget.apps.length)
          ? cursor + capacity
          : widget.apps.length;

      pages.add(widget.apps.sublist(cursor, end));
      cursor = end;
      pageIndex++;
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _chunkApps();

    if (pages.isEmpty) {
      return const Center(
        child: Text(
          'No apps available',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Horizontally paginated PageView with iOS BouncingScrollPhysics
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, pageIndex) {
              final pageApps = pages[pageIndex];
              final headerWidget = _getDefaultHeader(pageIndex);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Column(
                  children: [
                    ?headerWidget,
                    Expanded(
                      child: GridView.builder(
                        // Strictly follow a 4-column layout
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 14.0,
                          childAspectRatio: 0.74,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pageApps.length,
                        itemBuilder: (context, appIndex) {
                          final app = pageApps[appIndex];
                          return IOSAppIcon(
                            key: ValueKey('grid_${app.packageName}'),
                            app: app,
                            showLabel: true,
                            iconSize: 60.0,
                            isDock: false,
                            onTap: () => widget.onAppTap(app),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // iOS Style Page Indicator Dots
        if (pages.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (dotIndex) {
                final isSelected = dotIndex == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: isSelected ? 8.0 : 7.0,
                  height: isSelected ? 8.0 : 7.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.35),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
