import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qris_monit_package/qris_monit_package.dart';

import '../../animation/scanner_animation.dart';

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
    qrisController = widget.qrisController;
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
    return MobileScanner(
      controller: qrisController,
      errorBuilder: widget.errorBuilder,
      overlay: _scannerOverlay(),
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
            // debugPrint(
            //   'Failed to scan barcode '
            //   '\n\n'
            //   '================================================================================\n'
            //   '$e\n'
            //   '================================================================================\n'
            //   '\n\n',
            // );

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

  Stack _scannerOverlay() {
    return Stack(
      children: [
        ScannerAnimation(
          animation: _animationController,
          animationSize: widget.animationSize,
        ),
        if (widget.frontCanvasBuilder != null) ...[
          ...widget.frontCanvasBuilder!(qrisData),
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
                        qrisController.openGallery().then(
                          (value) {
                            if (!value.isValidQr) {
                              _showInvalidQRDialog();
                            }
                          },
                        );
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

  void _showInvalidQRDialog() {
    showAdaptiveDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog.adaptive(
          title: const Text('Unrecognized QR code'),
          content: const Text('Please scan the code again'),
          actions: [
            if (Platform.isIOS)
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Close'),
              ),
            if (Platform.isAndroid)
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Close'),
              )
          ],
        );
      },
    );
  }
}
