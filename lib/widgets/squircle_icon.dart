import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// CustomClipper that computes the mathematical superellipse (Lamé curve)
/// Formula: |(x - x0)/a|^n + |(y - y0)/b|^n = 1
/// Parametric:
///   x(t) = x0 + a * sgn(cos(t)) * |cos(t)|^(2/n)
///   y(t) = y0 + b * sgn(sin(t)) * |sin(t)|^(2/n)
/// With exponent n ≈ 4.4, this forms the Apple iOS 'Squircle'.
class SuperellipseClipper extends CustomClipper<Path> {
  final double n;
  final int samples;

  const SuperellipseClipper({
    this.n = 4.4,
    this.samples = 120,
  });

  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double a = size.width / 2.0;
    final double b = size.height / 2.0;
    final double centerX = a;
    final double centerY = b;
    final double p = 2.0 / n;

    for (int i = 0; i < samples; i++) {
      final double t = (i * 2.0 * math.pi) / samples;
      final double cosT = math.cos(t);
      final double sinT = math.sin(t);

      final double sgnCos = cosT >= 0 ? 1.0 : -1.0;
      final double sgnSin = sinT >= 0 ? 1.0 : -1.0;

      final double x = centerX + a * sgnCos * math.pow(cosT.abs(), p);
      final double y = centerY + b * sgnSin * math.pow(sinT.abs(), p);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant SuperellipseClipper oldClipper) =>
      oldClipper.n != n || oldClipper.samples != samples;
}

/// Custom Flutter widget that masks an image byte array or asset using
/// the mathematical Apple superellipse squircle formula.
class SquircleIcon extends StatelessWidget {
  final Uint8List? iconBytes;
  final String? assetPath;
  final double size;
  final Widget? fallback;
  final double exponent;

  const SquircleIcon({
    super.key,
    this.iconBytes,
    this.assetPath,
    this.size = 60.0,
    this.fallback,
    this.exponent = 4.4,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (assetPath != null && assetPath!.isNotEmpty) {
      content = Image.asset(
        assetPath!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) =>
            fallback ?? _defaultFallback(),
      );
    } else if (iconBytes != null && iconBytes!.isNotEmpty) {
      content = Image.memory(
        iconBytes!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            fallback ?? _defaultFallback(),
      );
    } else {
      content = fallback ?? _defaultFallback();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipPath(
        clipper: SuperellipseClipper(n: exponent),
        child: content,
      ),
    );
  }

  Widget _defaultFallback() {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade900,
      child: const Icon(Icons.apps_rounded, color: Colors.white70, size: 30),
    );
  }
}
