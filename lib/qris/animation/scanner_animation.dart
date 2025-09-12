import 'package:flutter/material.dart';

class ScannerAnimation extends AnimatedWidget {
  const ScannerAnimation({
    required Animation<double> animation,
    this.animationSize,
    super.key,
  }) : super(listenable: animation);
  final Size? animationSize;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    final scorePosition =
        animation.value * (MediaQuery.of(context).size.height * .9);

    return Positioned(
      bottom: scorePosition,
      child: SizedBox(
        height:
            animationSize?.height ?? MediaQuery.of(context).size.width * .25,
        width: animationSize?.width ?? MediaQuery.of(context).size.width,
        child: CustomPaint(
          painter: ScannerPainter(
            animationStatus: animation.status,
          ),
          size: Size(
            animationSize?.width ?? MediaQuery.of(context).size.width,
            animationSize?.height ?? MediaQuery.of(context).size.width * .25,
          ),
        ),
      ),
    );
  }
}

class ScannerPainter extends CustomPainter {
  const ScannerPainter({
    required this.animationStatus,
  });

  final AnimationStatus animationStatus;

  @override
  void paint(Canvas canvas, Size size) {
    // Define colors based on animation direction
    List<Color> colors;
    if (animationStatus == AnimationStatus.reverse) {
      colors = const [
        Color(0x003A8EF4),
        Color(0x223A8EF4),
        Color(0x4478b5ff),
        Color(0x6678b5ff),
        Color(0x8878b5ff),
      ];
    } else {
      colors = const [
        Color(0x8878b5ff),
        Color(0x6678b5ff),
        Color(0x4478b5ff),
        Color(0x223A8EF4),
        Color(0x003A8EF4),
      ];
    }

    // Create gradient paint
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.2, 0.4, 0.6, 0.8],
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw the gradient rectangle covering the entire area
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(ScannerPainter oldDelegate) {
    return oldDelegate.animationStatus != animationStatus;
  }
}
