import 'package:flutter/material.dart';
import '../medium_ios_widget.dart';

class BatteryItemData {
  final String label;
  final int percentage;
  final IconData icon;
  final bool isCharging;

  const BatteryItemData({
    required this.label,
    required this.percentage,
    required this.icon,
    this.isCharging = false,
  });
}

class BatteryWidget extends StatelessWidget {
  final List<BatteryItemData>? items;
  final VoidCallback? onTap;

  const BatteryWidget({
    super.key,
    this.items,
    this.onTap,
  });

  static const List<BatteryItemData> defaultDevices = [
    BatteryItemData(
      label: 'OnePlus 12',
      percentage: 88,
      icon: Icons.phone_android_rounded,
      isCharging: true,
    ),
    BatteryItemData(
      label: 'Buds Pro',
      percentage: 95,
      icon: Icons.headphones_rounded,
      isCharging: false,
    ),
    BatteryItemData(
      label: 'Watch 2',
      percentage: 72,
      icon: Icons.watch_rounded,
      isCharging: false,
    ),
    BatteryItemData(
      label: 'Pad Pro',
      percentage: 64,
      icon: Icons.tablet_android_rounded,
      isCharging: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final displayItems = items ?? defaultDevices;

    return MediumIOSWidget(
      widgetId: 'battery_widget_sample',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Title
            const Row(
              children: [
                Icon(Icons.battery_charging_full_rounded, color: Color(0xFF34C759), size: 18),
                SizedBox(width: 6),
                Text(
                  'Batteries',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),

            // 4 Circular Battery Progress Rings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: displayItems.map((device) {
                return _buildBatteryRing(device);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryRing(BatteryItemData device) {
    final progress = (device.percentage / 100.0).clamp(0.0, 1.0);
    const ringColor = Color(0xFF34C759); // Apple iOS vibrant battery green

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Background track
            SizedBox(
              width: 54,
              height: 54,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 4.8,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
            // Progress arc
            SizedBox(
              width: 54,
              height: 54,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 4.8,
                strokeCap: StrokeCap.round,
                valueColor: const AlwaysStoppedAnimation<Color>(ringColor),
              ),
            ),
            // Device Icon & Charging indicator
            Icon(
              device.icon,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
        const SizedBox(height: 7),
        // Percentage Text
        Text(
          '${device.percentage}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        // Device Label
        Text(
          device.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
