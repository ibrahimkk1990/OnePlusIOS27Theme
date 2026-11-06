import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/control_center_provider.dart';
import '../services/app_channel_service.dart';

class IOSControlCenter extends ConsumerWidget {
  const IOSControlCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(controlCenterProvider);
    final notifier = ref.read(controlCenterProvider.notifier);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dismiss tap backdrop
          GestureDetector(
            onTap: () => notifier.close(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),

          // Control Center Glassmorphic Body
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(38),
                  bottomRight: Radius.circular(38),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 35.0, sigmaY: 35.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E).withValues(alpha: 0.72),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(38),
                        bottomRight: Radius.circular(38),
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle / grab bar
                        Container(
                          width: 38,
                          height: 4.5,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),

                        // MODE SWITCHER: Adapt Default Panel <-> Apple Mode
                        _buildModeSwitcher(context, ref, state, notifier),

                        const SizedBox(height: 16),

                        // Main Pods Grid
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Connectivity (2x2) & Focus
                            Expanded(
                              child: Column(
                                children: [
                                  _buildConnectivityPod(state, notifier),
                                  const SizedBox(height: 12),
                                  _buildFocusPod(state, notifier),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Right Column: Music Player & Vertical Sliders
                            Expanded(
                              child: Column(
                                children: [
                                  _buildMusicPod(state, notifier),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      // Brightness Slider
                                      Expanded(
                                        child: _buildVerticalSlider(
                                          icon: Icons.wb_sunny_rounded,
                                          value: state.brightness,
                                          onChanged: notifier.setBrightness,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Volume Slider
                                      Expanded(
                                        child: _buildVerticalSlider(
                                          icon: Icons.volume_up_rounded,
                                          value: state.volume,
                                          onChanged: notifier.setVolume,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Bottom Row: Quick Action Pods
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSquareToggle(
                              icon: Icons.flashlight_on_rounded,
                              isActive: state.isFlashlightOn,
                              onTap: notifier.toggleFlashlight,
                            ),
                            _buildSquareToggle(
                              icon: Icons.screen_rotation_rounded,
                              isActive: state.isRotationLocked,
                              activeColor: const Color(0xFFFF453A),
                              onTap: notifier.toggleRotationLock,
                            ),
                            _buildSquareToggle(
                              icon: Icons.screen_share_rounded,
                              isActive: false,
                              onTap: () {},
                            ),
                            _buildSquareToggle(
                              icon: Icons.camera_alt_rounded,
                              isActive: false,
                              onTap: () {
                                notifier.close();
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitcher(
    BuildContext context,
    WidgetRef ref,
    ControlCenterState state,
    ControlCenterNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          // Default Mode (Android / OxygenOS panel)
          Expanded(
            child: GestureDetector(
              onTap: () async {
                notifier.setAppleMode(false);
                notifier.close();
                // Call native status bar expander
                await AppChannelService().expandStatusBar();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !state.isAppleMode
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.android_rounded,
                      size: 16,
                      color: !state.isAppleMode ? Colors.white : Colors.white60,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Default Mode',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: !state.isAppleMode ? Colors.white : Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Apple Mode (iOS 27 Control Center)
          Expanded(
            child: GestureDetector(
              onTap: () {
                notifier.setAppleMode(true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: state.isAppleMode
                      ? const Color(0xFF007AFF).withValues(alpha: 0.85)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: state.isAppleMode
                      ? [
                          BoxShadow(
                            color: const Color(0xFF007AFF).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apple_rounded,
                      size: 17,
                      color: state.isAppleMode ? Colors.white : Colors.white60,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Apple Mode',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: state.isAppleMode ? Colors.white : Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectivityPod(ControlCenterState state, ControlCenterNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircleBtn(
                icon: Icons.airplanemode_active_rounded,
                isActive: state.isAirplaneMode,
                activeColor: const Color(0xFFFF9500),
                onTap: notifier.toggleAirplane,
              ),
              _buildCircleBtn(
                icon: Icons.cell_tower_rounded,
                isActive: state.isCellularOn,
                activeColor: const Color(0xFF34C759),
                onTap: notifier.toggleCellular,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircleBtn(
                icon: Icons.wifi_rounded,
                isActive: state.isWifiOn,
                activeColor: const Color(0xFF007AFF),
                onTap: notifier.toggleWifi,
              ),
              _buildCircleBtn(
                icon: Icons.bluetooth_rounded,
                isActive: state.isBluetoothOn,
                activeColor: const Color(0xFF007AFF),
                onTap: notifier.toggleBluetooth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMusicPod(ControlCenterState state, ControlCenterNotifier notifier) {
    return Container(
      height: 98,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.music_note_rounded, size: 16, color: Colors.white70),
              SizedBox(width: 4),
              Text(
                'Music',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Text(
            'Not Playing',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(Icons.skip_previous_rounded, size: 22, color: Colors.white60),
              GestureDetector(
                onTap: notifier.toggleMusic,
                child: Icon(
                  state.isPlayingMusic ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 26,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.skip_next_rounded, size: 22, color: Colors.white60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusPod(ControlCenterState state, ControlCenterNotifier notifier) {
    return GestureDetector(
      onTap: notifier.toggleDnd,
      child: Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: state.isDndOn
              ? const Color(0xFF5856D6).withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.do_not_disturb_on_rounded,
              color: state.isDndOn ? Colors.white : Colors.white70,
              size: 26,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Focus',
                    style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    state.isDndOn ? 'On' : 'Off',
                    style: TextStyle(
                      color: state.isDndOn ? Colors.white70 : Colors.white60,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalSlider({
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // Dragging up increases, down decreases
        final delta = -details.primaryDelta! / 120.0;
        onChanged((value + delta).clamp(0.0, 1.0));
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Filled fraction
            FractionallySizedBox(
              heightFactor: value,
              widthFactor: 1.0,
              child: Container(
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
            // Bottom icon
            Positioned(
              bottom: 12,
              child: Icon(
                icon,
                color: value > 0.3 ? Colors.black87 : Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? activeColor : Colors.white.withValues(alpha: 0.16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSquareToggle({
    required IconData icon,
    required bool isActive,
    Color activeColor = const Color(0xFF007AFF),
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 60,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
