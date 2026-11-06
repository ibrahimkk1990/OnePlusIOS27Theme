import 'package:flutter/material.dart';
import 'ios_widget_container.dart';

class SmallIOSWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onRemoveTap;
  final String widgetId;
  final double size;

  const SmallIOSWidget({
    super.key,
    required this.child,
    this.onTap,
    this.onRemoveTap,
    this.widgetId = 'small_ios_widget',
    this.size = 158.0,
  });

  @override
  Widget build(BuildContext context) {
    return IOSWidgetContainer(
      widgetId: widgetId,
      width: size,
      height: size,
      onTap: onTap,
      onRemoveTap: onRemoveTap,
      child: child,
    );
  }
}
