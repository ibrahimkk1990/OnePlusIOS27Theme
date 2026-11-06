import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_info.dart';
import '../providers/icon_override_provider.dart';
import 'squircle_icon.dart';

class IOSAppIcon extends ConsumerStatefulWidget {
  final AppInfo app;
  final VoidCallback onTap;
  final bool showLabel;
  final double iconSize;

  const IOSAppIcon({
    super.key,
    required this.app,
    required this.onTap,
    this.showLabel = true,
    this.iconSize = 60.0,
  });

  @override
  ConsumerState<IOSAppIcon> createState() => _IOSAppIconState();
}

class _IOSAppIconState extends ConsumerState<IOSAppIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Check if custom icon mapping exists in local storage
    final overrides = ref.watch(iconOverridesProvider);
    final customAssetPath = overrides[widget.app.packageName];

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Apple Superellipse (Squircle) Masked Icon
            SquircleIcon(
              size: widget.iconSize,
              assetPath: customAssetPath,
              iconBytes: customAssetPath == null ? widget.app.iconBytes : null,
            ),

            if (widget.showLabel) ...[
              const SizedBox(height: 5),
              SizedBox(
                width: widget.iconSize + 16,
                child: Text(
                  widget.app.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: -0.2,
                    shadows: [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
