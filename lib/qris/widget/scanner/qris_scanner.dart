import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qris_monit_package/qris_monit_package.dart';

import '../../animation/scanner_animation.dart';

///The parent widget is [Stack]
///Preferably use [Positioned] for positioning the children
typedef QRISFrontCanvasBuilder = List<Widget> Function(
  QRIS? qrisData,
  QRISController qrisController,
);

typedef QRISOnScanCompleted = Future Function(
  String rawData,
  QRIS? qrisData,
  QRISError? qrisError,
);

class QRISScanner extends StatefulWidget {
  final Size? animationSize;

  final QRISOnScanCompleted onScanCompleted;

  final QRISFrontCanvasBuilder? frontCanvasBuilder;

  final MobileScannerErrorBuilder? errorBuilder;

  final bool? isFlashButtonEnabled;

  final bool? isGalleryButtonEnabled;

  const QRISScanner({
    required this.onScanCompleted,
    this.errorBuilder,
    this.isFlashButtonEnabled,
    this.isGalleryButtonEnabled,
    this.frontCanvasBuilder,
    this.animationSize,
    Key? key,
  }) : super(key: key);

  @override
  State<QRISScanner> createState() => _QRISScannerState();
}

class _QRISScannerState extends State<QRISScanner>
    with SingleTickerProviderStateMixin {
  ///instance of [MobileScannerController]
  ///for controlling QR scanner camera
  late QRISController qrisController;

  ///instance of [QRIS]
  ///
  /// return null if qr is not scanned
  ///
  /// return parsed qr code data
  QRIS? qrisData;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    qrisController = QRISController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animateScanAnimation(true);
      } else if (status == AnimationStatus.dismissed) {
        animateScanAnimation(false);
      }
    });
    animateScanAnimation(false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    qrisController.dispose();
    super.dispose();
  }

  void animateScanAnimation(bool reverse) {
    if (reverse) {
      _animationController.reverse(from: 1.0);
    } else {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: qrisController,
          errorBuilder: widget.errorBuilder,
          onDetect: (BarcodeCapture barcodes) {
            if (barcodes.barcodes.first.rawValue != null) {
              if (kDebugMode) {
                print(
                    'Barcode Raw Value ===== ${barcodes.barcodes.first.rawValue}');
              }
              try {
                if (barcodes.barcodes.first.rawValue != null) {
                  List<String> rawQRStrings =
                      barcodes.barcodes.first.rawValue?.split('|') ?? [];
                  if (rawQRStrings.first == 'LOGIN') {
                    widget.onScanCompleted(rawQRStrings.last, null, null);
                  } else {
                    qrisData = QRIS(barcodes.barcodes.first.rawValue!);
                    if (kDebugMode) {
                      print('QRIS Data Value ===== ${qrisData.toString()}');
                    }
                    widget.onScanCompleted(
                        barcodes.barcodes.first.rawValue!, qrisData, null);
                    setState(() {});
                  }
                }
              } on QRISError catch (e) {
                debugPrint(
                  'Failed to scan barcode '
                  '\n\n'
                  '================================================================================\n'
                  '$e\n'
                  '================================================================================\n'
                  '\n\n',
                );

                widget.onScanCompleted(
                    barcodes.barcodes.first.rawValue!, null, e);
              }
            } else {
              debugPrint(
                'Failed to scan barcode '
                '\n\n'
                '================================================================================\n'
                'Unable to read QR code'
                '================================================================================\n'
                '\n\n',
              );
            }
          },
        ),
        ScannerAnimation(
          animation: _animationController,
          animationSize: widget.animationSize,
        ),
        if (widget.frontCanvasBuilder != null) ...[
          ...widget.frontCanvasBuilder!(qrisData, qrisController),
        ] else ...[
          _defaultFrontCanvasBuilder()
        ],
      ],
    );
  }

  Widget _defaultFrontCanvasBuilder() {
    return Positioned(
      top: AppBar().preferredSize.height - 16,
      right: 16.0,
      child: Row(
        children: [
          Offstage(
            offstage: !(widget.isFlashButtonEnabled ?? true),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(36)),
              child: Container(
                color: Colors.white,
                child: IconButton(
                  icon: ValueListenableBuilder(
                    valueListenable: qrisController.torchState,
                    builder: (context, state, child) {
                      return switch (state) {
                        TorchState.off =>
                          const Icon(Icons.flash_off, color: Colors.black),
                        TorchState.on =>
                          const Icon(Icons.flash_on, color: Colors.yellow),
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
            if ((widget.isFlashButtonEnabled ?? true) &&
                (widget.isGalleryButtonEnabled ?? true)) {
              return const SizedBox(width: 16);
            } else {
              return const SizedBox();
            }
          }),
          Offstage(
            offstage: !(widget.isGalleryButtonEnabled ?? true),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(36)),
              child: Container(
                color: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.add_photo_alternate_outlined,
                      color: Colors.black),
                  iconSize: 24.0,
                  onPressed: () {
                    qrisController.openGallery();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
