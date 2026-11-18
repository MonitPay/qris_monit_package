import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('Example offers navigation to the scanner', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Flutter Demo Home Page'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byTooltip('Scan'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
