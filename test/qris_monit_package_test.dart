import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qris_monit_package/qris/animation/scanner_animation.dart';
import 'package:qris_monit_package/qris_monit_package.dart';

const _validQRIS =
    '00020101021126550016ID.CO.SHOPEE.WWW'
    '01189360091800000000180202180303UBE51440014ID.CO.QRIS.WWW'
    '0215ID20190022915550303UBE5204839853033605802ID5906Baznas'
    '6013Jakarta Pusat61051034062070703A016304A402';

void main() {
  late FakeScannerPlatform platform;
  late FakeImagePicker picker;
  late QRISController controller;
  late MobileScannerPlatform originalScanner;
  late ImagePickerPlatform originalPicker;

  setUp(() {
    originalScanner = MobileScannerPlatform.instance;
    originalPicker = ImagePickerPlatform.instance;
    platform = FakeScannerPlatform();
    picker = FakeImagePicker();
    MobileScannerPlatform.instance = platform;
    ImagePickerPlatform.instance = picker;
    controller = QRISController();
  });

  tearDown(() async {
    await controller.dispose();
    MobileScannerPlatform.instance = originalScanner;
    ImagePickerPlatform.instance = originalPicker;
  });

  Future<void> pumpScanner(
    WidgetTester tester, {
    QRISFrontCanvasBuilder? frontCanvasBuilder,
    Widget Function(BuildContext, MobileScannerException)? errorBuilder,
    QRISOnScanCompleted? onScanCompleted,
    bool? isFlashButtonEnabled,
    bool? isGalleryButtonEnabled,
    Size? animationSize,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QRISScanner(
            qrisController: controller,
            onScanCompleted: onScanCompleted ?? (_, _, _) async {},
            frontCanvasBuilder: frontCanvasBuilder,
            errorBuilder: errorBuilder,
            isFlashButtonEnabled: isFlashButtonEnabled,
            isGalleryButtonEnabled: isGalleryButtonEnabled,
            animationSize: animationSize,
          ),
        ),
      ),
    );
    // The scanner animation repeats, so pumpAndSettle would never finish.
    await tester.pump();
  }

  testWidgets('Default controls use extracted Material and update the torch', (
    tester,
  ) async {
    await pumpScanner(tester, animationSize: const Size(120, 30));
    expect(platform.starts, hasLength(1));
    expect(platform.starts.single.detectionSpeed, DetectionSpeed.noDuplicates);
    expect(find.byType(IconButton), findsNWidgets(2));
    expect(find.byType(ScannerAnimation), findsOneWidget);
    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(ScannerAnimation),
          matching: find.byType(CustomPaint),
        ),
      ),
      const Size(120, 30),
    );

    await tester.tap(find.byIcon(Icons.flash_off));
    await tester.pump();
    expect(platform.torchToggles, 1);
    expect(controller.value.torchState, TorchState.on);
    expect(find.byIcon(Icons.flash_on), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(platform.disposals, 1);
    await expectLater(
      controller.start(),
      throwsA(isA<MobileScannerException>()),
    );
  });

  testWidgets('Disabled default controls stay hidden', (tester) async {
    await pumpScanner(
      tester,
      isFlashButtonEnabled: false,
      isGalleryButtonEnabled: false,
    );
    expect(find.byType(IconButton), findsNothing);
    expect(find.byType(IconButton, skipOffstage: false), findsNWidgets(2));
    expect(find.byType(ScannerAnimation), findsOneWidget);
  });

  testWidgets('Gallery failure uses the extracted ScaffoldMessenger', (
    tester,
  ) async {
    platform.imageResult = const BarcodeCapture(barcodes: []);
    await pumpScanner(tester);
    await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(picker.source, ImageSource.gallery);
    expect(picker.options?.imageQuality, 100);
    expect(platform.analyzedPaths, ['/gallery/qr.png']);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Unable to read QR code'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Gallery cancellation does not analyze or show an error', (
    tester,
  ) async {
    picker.image = null;
    await pumpScanner(tester);
    await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
    await tester.pump();
    expect(platform.analyzedPaths, isEmpty);
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Late gallery failure after unmount is safely ignored', (
    tester,
  ) async {
    final result = Completer<BarcodeCapture?>();
    platform.pendingImage = result.future;
    await pumpScanner(tester);
    await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    result.complete(null);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Gallery addBarcode reaches parsing and the custom canvas', (
    tester,
  ) async {
    String? rawData;
    QRIS? parsed;
    QRISError? scanError;
    var completions = 0;
    platform.imageResult = const BarcodeCapture(
      barcodes: [Barcode(rawValue: _validQRIS)],
    );
    await pumpScanner(
      tester,
      frontCanvasBuilder: (qris) => [
        Positioned(
          bottom: 0,
          child: Column(
            children: [
              Text(qris?.merchantName ?? 'Waiting for QRIS'),
              TextButton(
                onPressed: controller.scanFromGallery,
                child: const Text('Choose QRIS'),
              ),
            ],
          ),
        ),
      ],
      onScanCompleted: (raw, qris, error) async {
        completions++;
        rawData = raw;
        parsed = qris;
        scanError = error;
      },
    );
    expect(find.text('Waiting for QRIS'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
    await tester.tap(find.text('Choose QRIS'));
    await tester.pump();
    await tester.pump();
    expect(completions, 1);
    expect(rawData, _validQRIS);
    expect(parsed?.merchantName, 'Baznas');
    expect(parsed?.merchantCity, 'Jakarta Pusat');
    expect(scanError, isNull);
    expect(find.text('Baznas'), findsOneWidget);
    expect(find.byType(ScannerAnimation), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Default gallery control delivers successful scans once', (
    tester,
  ) async {
    var completions = 0;
    platform.imageResult = const BarcodeCapture(
      barcodes: [Barcode(rawValue: _validQRIS)],
    );
    await pumpScanner(
      tester,
      onScanCompleted: (raw, qris, error) async {
        completions++;
        expect(raw, _validQRIS);
        expect(qris?.merchantName, 'Baznas');
        expect(error, isNull);
      },
    );
    await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
    await tester.pump();
    await tester.pump();
    expect(completions, 1);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Camera parsing and stream errors keep their callback contract', (
    tester,
  ) async {
    final results = <(String?, QRIS?, QRISError?)>[];
    await pumpScanner(
      tester,
      onScanCompleted: (raw, qris, error) async {
        results.add((raw, qris, error));
      },
    );
    platform.barcodes.add(const BarcodeCapture(barcodes: []));
    platform.barcodes.add(const BarcodeCapture(barcodes: [Barcode()]));
    platform.barcodes.add(
      const BarcodeCapture(barcodes: [Barcode(rawValue: 'invalid')]),
    );
    platform.barcodes.addError(Exception('camera decode failed'));
    await tester.pump();
    expect(results, hasLength(4));
    expect(results[0].$1, isNull);
    expect(results[0].$3?.code, 'not_a_barcode');
    expect(results[1].$3?.code, 'not_a_barcode');
    expect(results[2].$1, 'invalid');
    expect(results[2].$2, isNull);
    expect(results[2].$3, isA<QRISError>());
    expect(results[3].$3?.message, contains('camera decode failed'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Default permission error uses extracted UI without controls', (
    tester,
  ) async {
    platform.startError = const MobileScannerException(
      errorCode: MobileScannerErrorCode.permissionDenied,
    );
    await pumpScanner(tester);
    expect(controller.value.hasCameraPermission, isFalse);
    expect(
      find.text(MobileScannerErrorCode.permissionDenied.message),
      findsOneWidget,
    );
    expect(find.byType(IconButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Custom permission error receives the original exception', (
    tester,
  ) async {
    const error = MobileScannerException(
      errorCode: MobileScannerErrorCode.permissionDenied,
    );
    platform.startError = error;
    MobileScannerException? received;
    await pumpScanner(
      tester,
      errorBuilder: (context, exception) {
        received = exception;
        return const Center(child: Text('App permission guidance'));
      },
    );
    expect(received, same(error));
    expect(find.text('App permission guidance'), findsOneWidget);
    expect(find.text(error.errorCode.message), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('Gallery analysis exceptions retain the QRIS error contract', () async {
    platform.analysisError = Exception('image decoder failed');
    await expectLater(
      controller.scanFromGallery(),
      throwsA(
        isA<QRISError>()
            .having((error) => error.code, 'code', 'not_a_barcode')
            .having(
              (error) => error.message,
              'message',
              contains('image decoder failed'),
            ),
      ),
    );
  });
}

class FakeImagePicker extends ImagePickerPlatform {
  XFile? image = XFile('/gallery/qr.png');
  ImageSource? source;
  ImagePickerOptions? options;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    this.source = source;
    this.options = options;
    return image;
  }
}

class FakeScannerPlatform extends MobileScannerPlatform {
  final barcodes = StreamController<BarcodeCapture?>.broadcast();
  final torch = StreamController<TorchState>.broadcast();
  final starts = <StartOptions>[];
  final analyzedPaths = <String>[];
  BarcodeCapture? imageResult;
  Future<BarcodeCapture?>? pendingImage;
  MobileScannerException? startError;
  Exception? analysisError;
  var torchToggles = 0;
  var disposals = 0;

  @override
  Stream<BarcodeCapture?> get barcodesStream => barcodes.stream;

  @override
  Stream<TorchState> get torchStateStream => torch.stream;

  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();

  @override
  Future<MobileScannerViewAttributes> start(StartOptions startOptions) async {
    starts.add(startOptions);
    if (startError case final error?) throw error;
    return const MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: TorchState.off,
      size: Size(200, 200),
      numberOfCameras: 1,
    );
  }

  @override
  Widget buildCameraView() => const SizedBox.square(dimension: 200);

  @override
  Future<void> toggleTorch() async {
    torchToggles++;
    torch.add(TorchState.on);
  }

  @override
  Future<BarcodeCapture?> analyzeImage(
    String path, {
    List<BarcodeFormat> formats = const [],
  }) async {
    analyzedPaths.add(path);
    if (analysisError case final error?) throw error;
    return pendingImage ?? Future.value(imageResult);
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    disposals++;
    await barcodes.close();
    await torch.close();
  }
}
