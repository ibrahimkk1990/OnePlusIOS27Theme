import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/edit_mode_provider.dart';
import 'squircle_icon.dart';

class IOSWidgetContainer extends ConsumerStatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onRemoveTap;
  final String widgetId;

  const IOSWidgetContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.onTap,
    this.onRemoveTap,
    required this.widgetId,
  });

  @override
  ConsumerState<IOSWidgetContainer> createState() => _IOSWidgetContainerState();
}

class _IOSWidgetContainerState extends ConsumerState<IOSWidgetContainer>
    with TickerProviderStateMixin {
  late final AnimationController _jiggleController;
  late final Animation<double> _rotationAnimation;
  late final Animation<Offset> _translationAnimation;

  late final AnimationController _badgeController;
  late final Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();
    final seed = widget.widgetId.hashCode.abs();
    final random = math.Random(seed);
    final rotDelta = 0.012 + (random.nextDouble() * 0.005); // Subtle wobble for large widgets
    final transDelta = 0.5 + (random.nextDouble() * 0.5);

    _jiggleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 140 + (seed % 25)),
    );

    _rotationAnimation = Tween<double>(
      begin: -rotDelta,
      end: rotDelta,
    ).animate(CurvedAnimation(
      parent: _jiggleController,
      curve: Curves.easeInOutSine,
    ));

    _translationAnimation = Tween<Offset>(
      begin: Offset(-transDelta, transDelta * 0.5),
      end: Offset(transDelta, -transDelta * 0.5),
    ).animate(CurvedAnimation(
      parent: _jiggleController,
      curve: Curves.easeInOutSine,
    ));

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
    _jiggleController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  void _syncJiggle(bool isEditMode) {
    if (isEditMode) {
      if (!_jiggleController.isAnimating) {
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

  @override
  Widget build(BuildContext context) {
    final isEditMode = ref.watch(editModeProvider);
    _syncJiggle(isEditMode);

    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _translationAnimation]),
      builder: (context, child) {
        final rot = isEditMode ? _rotationAnimation.value : 0.0;
        final trans = isEditMode ? _translationAnimation.value : Offset.zero;

        return Transform.translate(
          offset: trans,
          child: Transform.rotate(
            angle: rot,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onLongPress: () {
          ref.read(editModeProvider.notifier).enterEditMode();
        },
        onTap: () {
          if (!isEditMode && widget.onTap != null) {
            HapticFeedback.lightImpact();
            widget.onTap!();
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Glassmorphic translucent squircle widget tile matching dock styling
            ClipPath(
              clipper: const SuperellipseClipper(n: 4.4, samples: 120),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22), // Dock-identical translucency
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
                  child: widget.child,
                ),
              ),
            ),

            // Edit Mode Minus Badge
            Positioned(
              top: -6,
              left: -6,
              child: ScaleTransition(
                scale: _badgeScale,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    if (widget.onRemoveTap != null) {
                      widget.onRemoveTap!();
                    }
                  },
                  child: Container(
                    width: 24,
                    height: 24,
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
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
