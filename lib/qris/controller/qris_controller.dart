import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qris_monit_package/qris_monit_package.dart';

class QRISController extends MobileScannerController {
  QRISController({
    /// Select which camera should be used.
    ///
    /// Default: CameraFacing.back
    super.facing,

    /// Sets the speed of detections.
    ///
    /// WARNING: DetectionSpeed.unrestricted can cause memory issues on some devices
    super.detectionSpeed = DetectionSpeed.noDuplicates,

    /// If provided, the scanner will only detect those specific formats
    super.formats,

    /// Automatically start the mobileScanner on initialization.
    /// If set to false, you need to call [start] manually.
    /// Default: true
    super.autoStart = true,

    /// Sets the timeout of scanner.
    /// The timeout is set in miliseconds.
    ///
    /// NOTE: The timeout only works if the [detectionSpeed] is set to
    /// [DetectionSpeed.normal] (which is the default value).
    super.detectionTimeoutMs,

    /// Set to true if you want to return the image buffer with the Barcode event
    ///
    /// Only supported on iOS and Android
    super.returnImage,

    /// Enable or disable the torch (Flash) on start
    ///
    /// Default: disabled
    super.torchEnabled,
  });

  /// Initiates a process to scan a barcode from an image selected from the gallery.
  ///
  /// This method uses the `ImagePicker` to allow the user to select an image from the gallery.
  /// The selected image is then processed to detect any barcodes present.
  ///
  /// The method returns a `Future` that completes with a `BarcodeCapture` object representing
  /// the detected barcodes. If no image is selected or no barcodes are detected, the method
  /// returns `null`.
  ///
  /// @return A `Future` that completes with a `BarcodeCapture` object representing the detected
  ///         barcodes, or `null` if no image is selected or no barcodes are detected.
  Future<BarcodeCapture?> scanFromGallery() async {
    return ImagePicker()
        .pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    )
        .then((imageFile) async {
      if (imageFile == null) return null;
      return await _processImage(imageFile.path);
    });
  }

  /// Processes an image to detect any barcodes present.
  ///
  /// This method takes a file path to an image, analyzes the image to detect
  /// any barcodes, and then adds the detected barcodes to the `barcodes` stream.
  ///
  /// The method uses the `analyzeImage` function to perform the barcode detection.
  /// The detected barcodes are then printed to the debug console and added to the
  /// `barcodes` stream by calling the `addBarcode` method.
  ///
  /// The `addBarcode` method is defined in the `MobileScannerController` superclass
  /// and allows subclasses to add data to the `barcodes` stream.
  ///
  /// @param filePath The file path to the image to be processed.
  /// @return A `Future` that completes when the image has been processed and the
  ///         detected barcodes have been added to the `barcodes` stream.
  Future<BarcodeCapture?> _processImage(String filePath) async {
    // Analyze the image to detect any barcodes.
    BarcodeCapture? barcodeCapture = await analyzeImage(filePath);

    // Print the detected barcodes to the debug console.
    debugPrint(
        'barcodeCapture ===== ${barcodeCapture?.barcodes.first.rawValue}');
    debugPrint('barcodeCapture ===== ${barcodeCapture?.barcodes.first.type}');
    debugPrint('barcodeCapture ===== ${barcodeCapture?.barcodes.first.format}');

    // Add the detected barcodes to the `barcodes` stream.
    if (barcodeCapture != null) addBarcode(barcodeCapture);

    return barcodeCapture;
  }
}
