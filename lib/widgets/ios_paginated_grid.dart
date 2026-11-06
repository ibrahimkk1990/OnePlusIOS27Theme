import 'package:flutter/material.dart';
import '../models/app_info.dart';
import 'ios_app_icon.dart';

class IOSPaginatedGrid extends StatefulWidget {
  final List<AppInfo> apps;
  final Function(AppInfo) onAppTap;
  final int itemsPerPage;

  const IOSPaginatedGrid({
    super.key,
    required this.apps,
    required this.onAppTap,
    this.itemsPerPage = 24, // 4 columns x 6 rows
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

  List<List<AppInfo>> _chunkApps() {
    if (widget.apps.isEmpty) return [];
    final List<List<AppInfo>> pages = [];
    for (int i = 0; i < widget.apps.length; i += widget.itemsPerPage) {
      final end = (i + widget.itemsPerPage < widget.apps.length)
          ? i + widget.itemsPerPage
          : widget.apps.length;
      pages.add(widget.apps.sublist(i, end));
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

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GridView.builder(
                  // Strictly follow a 4-column layout
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 18.0,
                    crossAxisSpacing: 14.0,
                    childAspectRatio: 0.76,
                  ),
                  physics: const NeverScrollableScrollPhysics(), // Horizontal PageView owns scrolling
                  itemCount: pageApps.length,
                  itemBuilder: (context, appIndex) {
                    final app = pageApps[appIndex];
                    return IOSAppIcon(
                      key: ValueKey(app.packageName),
                      app: app,
                      showLabel: true,
                      iconSize: 60.0,
                      onTap: () => widget.onAppTap(app),
                    );
                  },
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
