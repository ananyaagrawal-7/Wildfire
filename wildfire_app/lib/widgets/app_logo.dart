import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showBadge;
  final bool showAura;

  const AppLogo({
    super.key,
    this.size = 110,
    this.showBadge = true,
    this.showAura = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Soft Pulsing Radial Glow
          if (showAura)
            Container(
              width: size * 1.15,
              height: size * 1.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.28),
                    AppColors.primary.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 0.65, 1.0],
                ),
              ),
            ),

          // 2. Main Armored Shield Frame
          CustomPaint(
            size: Size(size, size),
            painter: _ShieldLogoPainter(),
          ),

          // 3. Indian Forestry Telemetry Badge
          if (showBadge && size >= 70)
            Positioned(
              bottom: size * 0.04,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size * 0.08,
                  vertical: size * 0.02,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF9933), // Indian Saffron
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'INDIA',
                      style: TextStyle(
                        fontSize: max(8.0, size * 0.09),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF138808), // Indian Green
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShieldLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Shield Path
    final shieldPath = Path();
    shieldPath.moveTo(w * 0.5, h * 0.05); // top apex
    shieldPath.lineTo(w * 0.90, h * 0.20); // top right
    shieldPath.quadraticBezierTo(w * 0.92, h * 0.58, w * 0.5, h * 0.95); // bottom tip
    shieldPath.quadraticBezierTo(w * 0.08, h * 0.58, w * 0.10, h * 0.20); // bottom left
    shieldPath.close();

    // Shield Background Fill (Deep Pine Charcoal Gradient)
    final shieldPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF183023), // deep forest green
          Color(0xFF0F1E16), // pine charcoal
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(shieldPath, shieldPaint);

    // Shield Outer Border (Radiant Amber Stroke)
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF9E43), // amber light
          Color(0xFFFF7A00), // primary flame
          Color(0xFFD66000), // burnt orange
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2.0, w * 0.035)
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(shieldPath, borderPaint);

    // 2. Stylized Dual-Tone Flame Path (Outer Flame)
    final flamePath = Path();
    flamePath.moveTo(w * 0.5, h * 0.22); // flame tip
    flamePath.cubicTo(w * 0.72, h * 0.38, w * 0.78, h * 0.62, w * 0.5, h * 0.78);
    flamePath.cubicTo(w * 0.22, h * 0.62, w * 0.28, h * 0.38, w * 0.5, h * 0.22);
    flamePath.close();

    final flamePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, 0.2),
        radius: 0.8,
        colors: [
          Color(0xFFFFD54F), // radiant gold core
          Color(0xFFFF7A00), // flame orange
          Color(0xFFE53935), // crimson outer
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(flamePath, flamePaint);

    // 3. Inner Forest Pine Silhouette (Dark silhouette nestled inside flame)
    final pinePath = Path();
    // Top tier
    pinePath.moveTo(w * 0.5, h * 0.38);
    pinePath.lineTo(w * 0.58, h * 0.48);
    pinePath.lineTo(w * 0.54, h * 0.48);
    // Middle tier
    pinePath.lineTo(w * 0.62, h * 0.58);
    pinePath.lineTo(w * 0.56, h * 0.58);
    // Lower tier
    pinePath.lineTo(w * 0.66, h * 0.68);
    pinePath.lineTo(w * 0.52, h * 0.68);
    // Trunk
    pinePath.lineTo(w * 0.52, h * 0.74);
    pinePath.lineTo(w * 0.48, h * 0.74);
    pinePath.lineTo(w * 0.48, h * 0.68);
    // Left side mirror
    pinePath.lineTo(w * 0.34, h * 0.68);
    pinePath.lineTo(w * 0.44, h * 0.58);
    pinePath.lineTo(w * 0.38, h * 0.58);
    pinePath.lineTo(w * 0.46, h * 0.48);
    pinePath.lineTo(w * 0.42, h * 0.48);
    pinePath.close();

    final pinePaint = Paint()
      ..color = const Color(0xFF0C1410).withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    canvas.drawPath(pinePath, pinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
