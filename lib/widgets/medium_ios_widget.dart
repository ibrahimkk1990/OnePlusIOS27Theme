import 'package:flutter/material.dart';
import 'ios_widget_container.dart';

class MediumIOSWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onRemoveTap;
  final String widgetId;
  final double? width;
  final double height;

  const MediumIOSWidget({
    super.key,
    required this.child,
    this.onTap,
    this.onRemoveTap,
    this.widgetId = 'medium_ios_widget',
    this.width,
    this.height = 158.0,
  });

  @override
  Widget build(BuildContext context) {
    return IOSWidgetContainer(
      widgetId: widgetId,
      width: width ?? double.infinity,
      height: height,
      onTap: onTap,
      onRemoveTap: onRemoveTap,
      child: child,
    );
  }
}
