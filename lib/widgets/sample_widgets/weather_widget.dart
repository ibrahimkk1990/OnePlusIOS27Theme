import 'package:flutter/material.dart';
import '../small_ios_widget.dart';

class WeatherWidget extends StatelessWidget {
  final String city;
  final String temperature;
  final String condition;
  final String highLow;
  final VoidCallback? onTap;

  const WeatherWidget({
    super.key,
    this.city = 'Cupertino',
    this.temperature = '72°',
    this.condition = 'Mostly Sunny',
    this.highLow = 'H:76° L:58°',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SmallIOSWidget(
      widgetId: 'weather_widget_sample',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1B6BA8).withValues(alpha: 0.55),
              const Color(0xFF4A90E2).withValues(alpha: 0.35),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: Location & Weather Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        condition,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.wb_sunny_rounded,
                  color: Color(0xFFFFD60A),
                  size: 26,
                ),
              ],
            ),

            // Middle & Bottom: Large Temperature & H/L Range
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temperature,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  highLow,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
