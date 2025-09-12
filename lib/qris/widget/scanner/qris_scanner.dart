import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qris_monit_package/qris_monit_package.dart';

///The parent widget is [Stack]
///Preferably use [Positioned] for positioning the children
typedef QRISFrontCanvasBuilder = List<Widget> Function(QRIS? qrisData);

typedef QRISOnScanCompleted = Future Function(
  String? rawData,
  QRIS? qrisData,
  QRISError? qrisError,
);

class QRISScanner extends StatefulWidget {
  const QRISScanner({
    required this.onScanCompleted,
    required this.qrisController,
    this.errorBuilder,
    this.isFlashButtonEnabled,
    this.isGalleryButtonEnabled,
    this.frontCanvasBuilder,
    this.animationSize,
    super.key,
  });

  ///instance of [MobileScannerController]
  ///for controlling QR scanner camera
  final QRISController qrisController;

  final Size? animationSize;

  final QRISOnScanCompleted onScanCompleted;

  final QRISFrontCanvasBuilder? frontCanvasBuilder;

  final Widget Function(BuildContext, MobileScannerException)? errorBuilder;

  final bool? isFlashButtonEnabled;

  final bool? isGalleryButtonEnabled;

  @override
  State<QRISScanner> createState() => _QRISScannerState();
}

class _QRISScannerState extends State<QRISScanner>
    with SingleTickerProviderStateMixin {
  ///instance of [MobileScannerController]
  ///for controlling QR scanner camera
  late final QRISController _qrisController = widget.qrisController;

  late final QRISOnScanCompleted _onScanCompleted = widget.onScanCompleted;

  ///instance of [QRIS]
  ///
  /// return null if qr is not scanned
  ///
  /// return parsed qr code data
  QRIS? _qrisData;

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
    // Dispose the controller when the widget is disposed.
    _qrisController.dispose();

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
    return MobileScanner(
      controller: _qrisController,
      errorBuilder: (ctx, error) {
        return widget.errorBuilder != null
            ? widget.errorBuilder!(ctx, error)
            : Center(
                child: Container(
                  color: Colors.white,
                  child: Text(error.errorCode.message),
                ),
              );
      },
      overlayBuilder: (_, __) => ScannerOverlay(
        qrisController: _qrisController,
        frontCanvasBuilder: widget.frontCanvasBuilder,
        isFlashButtonEnabled: widget.isFlashButtonEnabled,
        isGalleryButtonEnabled: widget.isGalleryButtonEnabled,
        animationSize: widget.animationSize,
        qrisData: _qrisData,
        animationController: _animationController,
      ),
      onDetectError: (error, stackTrace) {
        _onScanCompleted(
          null,
          null,
          QRISError(
            'not_a_barcode',
            message: 'Unable to read QR code: $error',
          ),
        );
      },
      onDetect: (BarcodeCapture barcodes) {
        // Early return for empty barcodes or null rawValue
        if (barcodes.barcodes.isEmpty ||
            barcodes.barcodes.first.rawValue == null) {
          _onScanCompleted(
            null,
            null,
            QRISError('not_a_barcode', message: 'Unable to read QR code'),
          );
          return;
        }

        final rawValue = barcodes.barcodes.first.rawValue!;
        debugPrint('Barcode Raw Value ===== $rawValue');

        try {
          _qrisData = QRIS(rawValue);
          _onScanCompleted(rawValue, _qrisData, null);
          setState(() {});
        } on QRISError catch (e) {
          _onScanCompleted(rawValue, null, e);
        }
      },
    );
  }
}
