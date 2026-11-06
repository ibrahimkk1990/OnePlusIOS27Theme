import 'package:flutter/material.dart';
import '../models/app_info.dart';

class IOSAppIcon extends StatefulWidget {
  final AppInfo app;
  final VoidCallback onTap;
  final bool showLabel;
  final double iconSize;

  const IOSAppIcon({
    super.key,
    required this.app,
    required this.onTap,
    this.showLabel = true,
    this.iconSize = 62.0,
  });

  @override
  State<IOSAppIcon> createState() => _IOSAppIconState();
}

class _IOSAppIconState extends State<IOSAppIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
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
            // iOS Squircle Icon Container
            Container(
              width: widget.iconSize,
              height: widget.iconSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(widget.iconSize * 0.235), // iOS standard curvature ratio
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.app.iconBytes != null
                  ? Image.memory(
                      widget.app.iconBytes!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.apps_rounded, color: Colors.white, size: 30),
                    )
                  : const Icon(Icons.apps_rounded, color: Colors.white, size: 30),
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
