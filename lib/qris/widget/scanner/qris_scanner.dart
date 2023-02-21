import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qris_monit_package/qris_monit_package.dart';

///The parent widget is [Stack]
///Preferably use [Positioned] for positioning the children
typedef QRISFrontCanvasBuilder = List<Widget> Function(
  QRIS? qrisData,
  QRISController qrisController,
);

typedef QRISOnScanCompleted = Future Function(
  String rawData,
  QRIS qrisData,
);

class QRISScanner extends StatefulWidget {
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
    Key? key,
  }) : super(key: key);

  @override
  State<QRISScanner> createState() => _QRISScannerState();
}

class _QRISScannerState extends State<QRISScanner> {
  ///instance of [MobileScannerController]
  ///for controlling QR scanner camera
  QRISController qrisController = QRISController();

  ///instance of [QRIS]
  ///
  /// return null if qr is not scanned
  ///
  /// return parsed qr code data
  QRIS? qrisData;

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
                    'barcodeData.rawValue ===== ${barcodes.barcodes.first.rawValue}');
              }
              try {
                qrisData = QRIS(barcodes.barcodes.first.rawValue!);
                widget.onScanCompleted(
                  barcodes.barcodes.first.rawValue!,
                  qrisData!,
                );
                setState(() {});
              } catch (e) {
                debugPrint(
                  'Failed to scan barcode '
                  '\n\n'
                  '================================================================================\n'
                  '$e\n'
                  '================================================================================\n'
                  '\n\n',
                );
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
        if (widget.frontCanvasBuilder != null)
          ...widget.frontCanvasBuilder!(qrisData, qrisController),
        if (widget.frontCanvasBuilder == null) _defaultFrontCanvasBuilder(),
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
                      switch (state) {
                        case TorchState.off:
                          return const Icon(Icons.flash_off,
                              color: Colors.black);
                        case TorchState.on:
                          return const Icon(Icons.flash_on,
                              color: Colors.yellow);
                      }
                    },
                  ),
                  iconSize: 24.0,
                  onPressed: () => qrisController.toggleTorch(),
                ),
              ),
            ),
          ),
          if ((widget.isFlashButtonEnabled ?? true) &&
              (widget.isGalleryButtonEnabled ?? true))
            const SizedBox(width: 16),
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
