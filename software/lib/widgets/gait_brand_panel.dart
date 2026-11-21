import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GaitBrandPanel extends StatelessWidget {
  final bool compact;

  const GaitBrandPanel({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 48),
      decoration: BoxDecoration(
        color: AppColors.midnight,
        borderRadius: BorderRadius.circular(compact ? 20 : 28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.multiline_chart_rounded,
                  color: Color(0xFF80D5CF),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'GaitSense',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          if (!compact) ...[
            const Spacer(),
            const Text(
              'Every step\nmatters.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 43,
                fontWeight: FontWeight.w700,
                height: 1.12,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Wearable gait monitoring and '
              'sensory cueing, designed to support '
              'movement awareness.',
              style: TextStyle(
                color: Color(0xFFBAC8D1),
                fontSize: 15,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(painter: GaitWavePainter()),
            ),
            const Spacer(),
            const Text(
              'MONITOR  /  UNDERSTAND  /  SUPPORT',
              style: TextStyle(
                color: Color(0xFF9DB1BF),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.8,
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            const Text(
              'Every step matters.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Wearable gait monitoring and support',
              style: TextStyle(color: Color(0xFFBAC8D1), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class GaitWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final wavePaint = Paint()
      ..color = const Color(0xFF80D5CF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final points = [
      [0.00, 0.55],
      [0.14, 0.55],
      [0.22, 0.40],
      [0.30, 0.70],
      [0.39, 0.20],
      [0.48, 0.60],
      [0.57, 0.48],
      [0.66, 0.55],
      [0.76, 0.55],
      [0.83, 0.35],
      [0.90, 0.55],
      [1.00, 0.55],
    ];

    for (int i = 0; i < points.length; i++) {
      final x = points[i][0] * size.width;
      final y = points[i][1] * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
