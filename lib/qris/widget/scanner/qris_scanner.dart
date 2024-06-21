import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qris_monit_package/qris_monit_package.dart';

///The parent widget is [Stack]
///Preferably use [Positioned] for positioning the children
typedef QRISFrontCanvasBuilder = List<Widget> Function(
  QRIS? qrisData,
);

typedef QRISOnScanCompleted = Future Function(
  String? rawData,
  QRIS? qrisData,
  QRISError? qrisError,
);

class QRISScanner extends StatefulWidget {
  ///instance of [MobileScannerController]
  ///for controlling QR scanner camera
  final QRISController qrisController;

  final Size? animationSize;

  final QRISOnScanCompleted onScanCompleted;

  final QRISFrontCanvasBuilder? frontCanvasBuilder;

  final MobileScannerErrorBuilder? errorBuilder;

  final bool? isFlashButtonEnabled;

  final bool? isGalleryButtonEnabled;

  const QRISScanner({
    super.key,
    required this.onScanCompleted,
    required this.qrisController,
    this.errorBuilder,
    this.isFlashButtonEnabled,
    this.isGalleryButtonEnabled,
    this.frontCanvasBuilder,
    this.animationSize,
  });

  @override
  State<QRISScanner> createState() => _QRISScannerState();
}

class _QRISScannerState extends State<QRISScanner>
    with SingleTickerProviderStateMixin {
  ///instance of [MobileScannerController]
  ///for controlling QR scanner camera
  late QRISController qrisController = widget.qrisController;

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

    // // Finally, start the scanner itself.
    // unawaited(qrisController.start());
  }

  @override
  void dispose() {
    // Dispose the animation controller when the widget is disposed.
    _animationController.dispose();

    super.dispose();

    // Dispose the controller when the widget is disposed.
    qrisController.dispose();
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
    return MobileScanner(
      controller: qrisController,
      errorBuilder: widget.errorBuilder,
      overlayBuilder: (_, __) => ScannerOverlay(
        qrisController: qrisController,
        frontCanvasBuilder: widget.frontCanvasBuilder,
        isFlashButtonEnabled: widget.isFlashButtonEnabled,
        isGalleryButtonEnabled: widget.isGalleryButtonEnabled,
        animationSize: widget.animationSize,
        qrisData: qrisData,
        animationController: _animationController,
      ),
      onDetect: (BarcodeCapture barcodes) {
        if (barcodes.barcodes.first.rawValue != null) {
          if (kDebugMode) {
            print(
                'Barcode Raw Value ===== ${barcodes.barcodes.first.rawValue}');
          }
          try {
            qrisData = QRIS(barcodes.barcodes.first.rawValue ?? '');
            widget.onScanCompleted(
                barcodes.barcodes.first.rawValue, qrisData, null);
            setState(() {});
          } on QRISError catch (e) {
            widget.onScanCompleted(barcodes.barcodes.first.rawValue, null, e);
          }
        } else {
          widget.onScanCompleted(null, null,
              QRISError('not_a_barcode', message: 'Unable to read QR code'));
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
    );
  }
}
