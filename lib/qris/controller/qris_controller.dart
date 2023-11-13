import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
    super.autoStart,

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

  ///Open Gallery using [ImagePicker] lib
  ///use for scanning QR from gallery
  Future<({bool isValidQr, File? qrImageFile})> openGallery() async {
    final ImagePicker picker = ImagePicker();
    return await picker
        .pickImage(source: ImageSource.gallery)
        .then((imageFile) async {
      if (imageFile != null) {
        return (
          isValidQr: await analyzeImage(imageFile.path),
          qrImageFile: File(imageFile.path)
        );
      }

      return (isValidQr: false, qrImageFile: null);
    });
  }
}
