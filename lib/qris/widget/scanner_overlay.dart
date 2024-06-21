import 'package:flutter/material.dart';
import 'package:qris_monit_package/qris/animation/scanner_animation.dart';
import 'package:qris_monit_package/qris_monit_package.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    super.key,
    required this.qrisController,
    this.frontCanvasBuilder,
    this.isFlashButtonEnabled,
    this.isGalleryButtonEnabled,
    this.animationSize,
    required this.qrisData,
    required this.animationController,
  });

  final QRISController qrisController;
  final QRISFrontCanvasBuilder? frontCanvasBuilder;
  final bool? isFlashButtonEnabled;
  final bool? isGalleryButtonEnabled;
  final Size? animationSize;
  final QRIS? qrisData;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScannerAnimation(
          animation: animationController,
          animationSize: animationSize,
        ),
        if (frontCanvasBuilder != null) ...[
          ...frontCanvasBuilder!(qrisData),
        ] else ...[
          _defaultFrontCanvasBuilder()
        ],
      ],
    );
  }

  Widget _defaultFrontCanvasBuilder() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Offstage(
                offstage: !(isFlashButtonEnabled ?? true),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(36)),
                  child: Container(
                    color: Colors.white,
                    child: IconButton(
                      icon: ValueListenableBuilder(
                        valueListenable: qrisController,
                        builder: (context, state, child) {
                          return switch (state.torchState) {
                            TorchState.off =>
                              const Icon(Icons.flash_off, color: Colors.black),
                            TorchState.on =>
                              const Icon(Icons.flash_on, color: Colors.yellow),
                            TorchState.auto =>
                              const Icon(Icons.flash_off, color: Colors.black),
                            TorchState.unavailable =>
                              const Icon(Icons.flash_off, color: Colors.black),
                          };
                        },
                      ),
                      iconSize: 24.0,
                      onPressed: () => qrisController.toggleTorch(),
                    ),
                  ),
                ),
              ),
              Builder(builder: (context) {
                if ((isFlashButtonEnabled ?? true) &&
                    (isGalleryButtonEnabled ?? true)) {
                  return const SizedBox(width: 16);
                } else {
                  return const SizedBox();
                }
              }),
              Offstage(
                offstage: !(isGalleryButtonEnabled ?? true),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(36)),
                  child: Container(
                    color: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.add_photo_alternate_outlined,
                          color: Colors.black),
                      iconSize: 24.0,
                      onPressed: () {
                        qrisController.scanFromGallery();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
