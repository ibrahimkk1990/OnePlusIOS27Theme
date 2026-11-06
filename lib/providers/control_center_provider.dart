import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ControlCenterState {
  final bool isOpen;
  final bool isAppleMode; // true = Apple iOS27 Mode, false = Default Android/OnePlus Panel
  final double brightness; // 0.0 - 1.0
  final double volume; // 0.0 - 1.0
  final bool isWifiOn;
  final bool isBluetoothOn;
  final bool isAirplaneMode;
  final bool isCellularOn;
  final bool isFlashlightOn;
  final bool isRotationLocked;
  final bool isDndOn;
  final bool isPlayingMusic;

  const ControlCenterState({
    this.isOpen = false,
    this.isAppleMode = true,
    this.brightness = 0.75,
    this.volume = 0.60,
    this.isWifiOn = true,
    this.isBluetoothOn = true,
    this.isAirplaneMode = false,
    this.isCellularOn = true,
    this.isFlashlightOn = false,
    this.isRotationLocked = false,
    this.isDndOn = false,
    this.isPlayingMusic = false,
  });

  ControlCenterState copyWith({
    bool? isOpen,
    bool? isAppleMode,
    double? brightness,
    double? volume,
    bool? isWifiOn,
    bool? isBluetoothOn,
    bool? isAirplaneMode,
    bool? isCellularOn,
    bool? isFlashlightOn,
    bool? isRotationLocked,
    bool? isDndOn,
    bool? isPlayingMusic,
  }) {
    return ControlCenterState(
      isOpen: isOpen ?? this.isOpen,
      isAppleMode: isAppleMode ?? this.isAppleMode,
      brightness: brightness ?? this.brightness,
      volume: volume ?? this.volume,
      isWifiOn: isWifiOn ?? this.isWifiOn,
      isBluetoothOn: isBluetoothOn ?? this.isBluetoothOn,
      isAirplaneMode: isAirplaneMode ?? this.isAirplaneMode,
      isCellularOn: isCellularOn ?? this.isCellularOn,
      isFlashlightOn: isFlashlightOn ?? this.isFlashlightOn,
      isRotationLocked: isRotationLocked ?? this.isRotationLocked,
      isDndOn: isDndOn ?? this.isDndOn,
      isPlayingMusic: isPlayingMusic ?? this.isPlayingMusic,
    );
  }
}

class ControlCenterNotifier extends Notifier<ControlCenterState> {
  @override
  ControlCenterState build() => const ControlCenterState();

  void open() {
    HapticFeedback.mediumImpact();
    state = state.copyWith(isOpen: true);
  }

  void close() {
    HapticFeedback.lightImpact();
    state = state.copyWith(isOpen: false);
  }

  void toggleOpen() {
    if (state.isOpen) {
      close();
    } else {
      open();
    }
  }

  void setAppleMode(bool isApple) {
    HapticFeedback.selectionClick();
    state = state.copyWith(isAppleMode: isApple);
  }

  void setBrightness(double val) {
    state = state.copyWith(brightness: val.clamp(0.0, 1.0));
  }

  void setVolume(double val) {
    state = state.copyWith(volume: val.clamp(0.0, 1.0));
  }

  void toggleWifi() {
    HapticFeedback.selectionClick();
    state = state.copyWith(isWifiOn: !state.isWifiOn);
  }

  void toggleBluetooth() {
    HapticFeedback.selectionClick();
    state = state.copyWith(isBluetoothOn: !state.isBluetoothOn);
  }

  void toggleAirplane() {
    HapticFeedback.selectionClick();
    state = state.copyWith(isAirplaneMode: !state.isAirplaneMode);
  }

  void toggleCellular() {
    HapticFeedback.selectionClick();
    state = state.copyWith(isCellularOn: !state.isCellularOn);
  }

  void toggleFlashlight() {
    HapticFeedback.selectionClick();
    state = state.copyWith(isFlashlightOn: !state.isFlashlightOn);
  }

  void toggleRotationLock() {
    HapticFeedback.selectionClick();
    state = state.copyWith(isRotationLocked: !state.isRotationLocked);
  }

  void toggleDnd() {
    HapticFeedback.selectionClick();
    state = state.copyWith(isDndOn: !state.isDndOn);
  }

  void toggleMusic() {
    HapticFeedback.selectionClick();
    state = state.copyWith(isPlayingMusic: !state.isPlayingMusic);
  }
}

final controlCenterProvider =
    NotifierProvider<ControlCenterNotifier, ControlCenterState>(() {
  return ControlCenterNotifier();
});
