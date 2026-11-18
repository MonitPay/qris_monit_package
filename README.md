# qris_monit_package

Monit's QRIS scanner wraps the mobile_scanner fork with QRIS parsing, gallery
scanning, an animated overlay, and optional app-provided controls and error UI.

## Requirements

- Dart 3.13 or newer and Flutter 3.47 or newer.
- Development and verification use Flutter 3.50.0 through FVM (`.fvmrc`).
- UI uses `material_ui: ^1.11.1` from pub.dev. Its Cupertino dependency supplies
  adaptive Material UI; this package does not directly import Cupertino widgets.

Apps must import `package:material_ui/material_ui.dart` for their Material
ancestors and custom builders. The default gallery error feedback looks up the
extracted `ScaffoldMessenger` provided by that `MaterialApp` and `Scaffold`.

```dart
import 'package:material_ui/material_ui.dart';
import 'package:qris_monit_package/qris_monit_package.dart';

final controller = QRISController();

Widget buildScanner() => MaterialApp(
  home: Scaffold(
    body: QRISScanner(
      qrisController: controller,
      onScanCompleted: (rawData, qrisData, error) async {
        // Handle parsed QRIS data or the existing QRISError contract.
      },
    ),
  ),
);
```

`frontCanvasBuilder` still returns children positioned in the scanner's `Stack`;
when supplied, it replaces the default flash/gallery controls. `errorBuilder`
still receives the original `MobileScannerException`. `QRISScanner` disposes
its supplied controller when removed. Gallery scans continue through the fork's
`addBarcode` API and the same parsing/callback path as camera scans.

The [example](example/lib/scanner_screen.dart) demonstrates scan callbacks,
custom error UI, and pausing/resuming around the result dialog. Keep the native
camera/photo permissions and scanner platform setup required by mobile_scanner
and image_picker in the consuming app.

## Local checks

```sh
fvm use 3.50.0 --skip-pub-get
fvm flutter pub get
fvm flutter test
fvm flutter analyze
(cd example && fvm flutter test && fvm flutter analyze)
fvm dart format --output=none --set-exit-if-changed lib test example/lib example/test
```

Widget tests use scanner and image-picker platform fakes to cover default and
custom UI, permission errors, gallery success/failure/cancellation, QRIS parsing,
stream errors, animation sizing, and disposal. They do not verify native camera,
photo access, torch hardware, or device lifecycle behavior.

## Testing an unpublished scanner rebase

The committed scanner Git pin stays at
`c7e0210400f997dfa30454078ec41cfb85aa45ad` until a remotely consumable replacement
is available. To test a reviewed local scanner revision, create an untracked
`pubspec_overrides.yaml` in this package and in `example/`:

```yaml
dependency_overrides:
  mobile_scanner:
    path: /absolute/path/to/reviewed/mobile_scanner/worktree
```

Run dependency resolution and the checks above again. A consuming app needs the
override in its own root pubspec override file, because dependency overrides do
not propagate from a dependency. Do not commit local override paths or a lockfile
resolved with a temporary scanner path; remove the overrides and resolve again
before recording the example lockfile.
