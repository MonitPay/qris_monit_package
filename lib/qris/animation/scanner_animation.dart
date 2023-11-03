import 'package:flutter/material.dart';

class ScannerAnimation extends AnimatedWidget {
  final Size? animationSize;

  const ScannerAnimation({
    super.key,
    required Animation<double> animation,
    this.animationSize,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    final scorePosition =
        (animation.value * (MediaQuery.of(context).size.height * .9));

    // Color colorCC = Color(0xCC78b5ff);
    // Color colorAA = Color(0xAA78b5ff);
    Color color88 = const Color(0x8878b5ff);
    Color color66 = const Color(0x6678b5ff);
    Color color44 = const Color(0x4478b5ff);
    Color color22 = const Color(0x223A8EF4);
    Color color00 = const Color(0x003A8EF4);

    if (animation.status == AnimationStatus.reverse) {
      color88 = const Color(0x003A8EF4);
      color66 = const Color(0x223A8EF4);
      color44 = const Color(0x4478b5ff);
      color22 = const Color(0x6678b5ff);
      color00 = const Color(0x8878b5ff);
      // color22 = Color(0xAA78b5ff);
      // color00 = Color(0xCC78b5ff);
    }
    return Positioned(
      bottom: scorePosition,
      child: SizedBox(
        height:
            animationSize?.height ?? MediaQuery.of(context).size.width * .25,
        width: animationSize?.width ?? MediaQuery.of(context).size.width,
        child: ListView.builder(
          itemCount: 100,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext buildContext, int index) {
            return Container(
              margin: const EdgeInsets.all(1),
              height: 5,
              width: 5,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // ignore: prefer_const_literals_to_create_immutables
                stops: [
                  0.0,
                  0.2,
                  0.4,
                  0.6,
                  0.8,
                  // 1,
                  // 1.2,
                ],
                colors: [
                  // colorCC,
                  // colorAA,
                  color88,
                  color66,
                  color44,
                  color22,
                  color00
                ],
              )),
            );
          },
        ),
      ),
    );
  }
}
