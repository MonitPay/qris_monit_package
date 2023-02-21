import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRISController extends MobileScannerController {
  QRISController({
    /// Select which camera should be used.
    ///
    /// Default: CameraFacing.back
    CameraFacing facing = CameraFacing.back,

    /// Sets the speed of detections.
    ///
    /// WARNING: DetectionSpeed.unrestricted can cause memory issues on some devices
    DetectionSpeed detectionSpeed = DetectionSpeed.noDuplicates,

    /// If provided, the scanner will only detect those specific formats
    List<BarcodeFormat>? formats,

    /// Automatically start the mobileScanner on initialization.
    bool autoStart = true,

    /// Sets the timeout of scanner.
    /// The timeout is set in miliseconds.
    ///
    /// NOTE: The timeout only works if the [detectionSpeed] is set to
    /// [DetectionSpeed.normal] (which is the default value).
    int detectionTimeoutMs = 250,

    /// Set to true if you want to return the image buffer with the Barcode event
    ///
    /// Only supported on iOS and Android
    bool returnImage = false,

    /// Enable or disable the torch (Flash) on start
    ///
    /// Default: disabled
    bool torchEnabled = false,
  }) : super(
          facing: facing,
          detectionSpeed: detectionSpeed,
          formats: formats,
          autoStart: autoStart,
          detectionTimeoutMs: detectionTimeoutMs,
          returnImage: returnImage,
          torchEnabled: torchEnabled,
        );

  ///Open Gallery using [ImagePicker] lib
  ///use for scanning QR from gallery
  Future<void> openGallery() async {
    final ImagePicker picker = ImagePicker();
    await picker.pickImage(source: ImageSource.gallery).then((imageFile) {
      if (imageFile != null) {
        analyzeImage(imageFile.path);
      }
    });
  }
}
