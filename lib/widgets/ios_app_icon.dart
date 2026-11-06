import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_info.dart';
import '../providers/edit_mode_provider.dart';
import '../providers/icon_override_provider.dart';
import 'squircle_icon.dart';

class IOSAppIcon extends ConsumerStatefulWidget {
  final AppInfo app;
  final VoidCallback onTap;
  final VoidCallback? onRemoveTap;
  final bool showLabel;
  final double iconSize;
  final bool isDock;

  const IOSAppIcon({
    super.key,
    required this.app,
    required this.onTap,
    this.onRemoveTap,
    this.showLabel = true,
    this.iconSize = 60.0,
    this.isDock = false,
  });

  @override
  ConsumerState<IOSAppIcon> createState() => _IOSAppIconState();
}

class _IOSAppIconState extends ConsumerState<IOSAppIcon>
    with TickerProviderStateMixin {
  // 150ms Launch Bounce Animation Controller
  late final AnimationController _launchController;
  late final Animation<double> _launchAnimation;

  // Jiggle Mode Wobble Controller
  late final AnimationController _jiggleController;
  late final Animation<double> _rotationAnimation;
  late final Animation<Offset> _translationAnimation;

  // Minus badge scale-in animation
  late final AnimationController _badgeController;
  late final Animation<double> _badgeScale;

  late final double _randomRotationDelta;
  late final double _randomTranslationDelta;

  @override
  void initState() {
    super.initState();

    // Deterministic pseudo-random seed per app package for realistic desynchronized jiggle
    final seed = widget.app.packageName.hashCode.abs();
    final random = math.Random(seed);
    _randomRotationDelta = 0.022 + (random.nextDouble() * 0.008); // ~ 1.3° to 1.7°
    _randomTranslationDelta = 0.6 + (random.nextDouble() * 0.8);  // 0.6 to 1.4 px

    // Exactly 150ms scale-down/scale-up liquid bounce animation
    _launchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _launchAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.85).chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 55,
      ),
    ]).animate(_launchController);

    // Jiggle Wobble (randomized cycle between 130ms and 165ms)
    final jiggleDurationMs = 135 + (seed % 30);
    _jiggleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: jiggleDurationMs),
    );

    _rotationAnimation = Tween<double>(
      begin: -_randomRotationDelta,
      end: _randomRotationDelta,
    ).animate(CurvedAnimation(
      parent: _jiggleController,
      curve: Curves.easeInOutSine,
    ));

    _translationAnimation = Tween<Offset>(
      begin: Offset(-_randomTranslationDelta, _randomTranslationDelta * 0.5),
      end: Offset(_randomTranslationDelta, -_randomTranslationDelta * 0.5),
    ).animate(CurvedAnimation(
      parent: _jiggleController,
      curve: Curves.easeInOutSine,
    ));

    // Minus badge pop animation
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _badgeScale = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _launchController.dispose();
    _jiggleController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  void _syncJiggleState(bool isEditMode) {
    if (isEditMode) {
      if (!_jiggleController.isAnimating) {
        // Start wobble animation desynchronized
        _jiggleController.repeat(reverse: true);
        _badgeController.forward();
      }
    } else {
      if (_jiggleController.isAnimating || _jiggleController.value != 0) {
        _jiggleController.stop();
        _jiggleController.reset();
        _badgeController.reverse();
      }
    }
  }

  Future<void> _handleTap() async {
    final isEditMode = ref.read(editModeProvider);
    if (isEditMode) {
      // Tapping during edit mode doesn't launch
      return;
    }

    // Play 150ms liquid bounce animation before firing native launch
    HapticFeedback.lightImpact();
    await _launchController.forward(from: 0.0);
    widget.onTap();
  }

  void _handleLongPress() {
    ref.read(editModeProvider.notifier).enterEditMode();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = ref.watch(editModeProvider);
    _syncJiggleState(isEditMode);

    // Check if custom icon mapping exists in local storage
    final overrides = ref.watch(iconOverridesProvider);
    final customAssetPath = overrides[widget.app.packageName];

    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_launchAnimation, _rotationAnimation, _translationAnimation]),
        builder: (context, child) {
          // Combined launch scale and jiggle wobble
          final scale = _launchAnimation.value;
          final rotation = isEditMode ? _rotationAnimation.value : 0.0;
          final translation = isEditMode ? _translationAnimation.value : Offset.zero;

          return Transform.translate(
            offset: translation,
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with Hero and Minus Badge in Stack
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Hero widget for seamless liquid app launch transitions
                Hero(
                  tag: 'app_icon_${widget.app.packageName}_${widget.isDock ? "dock" : "grid"}',
                  child: SquircleIcon(
                    size: widget.iconSize,
                    assetPath: customAssetPath,
                    iconBytes: customAssetPath == null ? widget.app.iconBytes : null,
                  ),
                ),

                // iOS Edit Mode Minus Badge
                Positioned(
                  top: -5,
                  left: -5,
                  child: ScaleTransition(
                    scale: _badgeScale,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        if (widget.onRemoveTap != null) {
                          widget.onRemoveTap!();
                        } else {
                          _showRemoveDialog(context);
                        }
                      },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8E8E93).withValues(alpha: 0.95),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.remove_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E).withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove "${widget.app.appName}"?',
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Choose an action for this application.',
          style: TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(iconOverridesProvider.notifier).removeOverride(widget.app.packageName);
            },
            child: const Text('Reset Icon', style: TextStyle(color: Colors.orangeAccent)),
          ),
        ],
      ),
    );
  }
}
