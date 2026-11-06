import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/app_info.dart';
import 'ios_app_icon.dart';

class IOSDock extends StatelessWidget {
  final List<AppInfo> dockApps;
  final Function(AppInfo) onAppTap;

  const IOSDock({
    super.key,
    required this.dockApps,
    required this.onAppTap,
  });

  @override
  Widget build(BuildContext context) {
    // Dock strictly holds up to 4 icons
    final displayApps = dockApps.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34.0), // Heavily rounded iOS dock corners
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0), // iOS blur effect
          child: Container(
            height: 94.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22), // Translucent glass background
              borderRadius: BorderRadius.circular(34.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: displayApps.map((app) {
                return IOSAppIcon(
                  key: ValueKey(app.packageName),
                  app: app,
                  showLabel: false, // Dock icons in iOS don't display labels
                  iconSize: 60.0,
                  onTap: () => onAppTap(app),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
