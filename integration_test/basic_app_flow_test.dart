import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('basic app flow test (desktop & web)',
      (WidgetTester tester) async {
    // Launch the app in test mode without opening a real desktop window
    app.main();

    // Wait for the app to build
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify initial UI elements
    expect(find.text('Save Givens'), findsOneWidget);
    expect(find.text('Reset To Givens'), findsOneWidget);
    expect(find.text('Add All Candidates'), findsOneWidget);
    expect(find.text('Erase All'), findsOneWidget);
    expect(find.text('Set Cand'), findsOneWidget);
    expect(find.text('Reset Cand'), findsOneWidget);
    expect(find.text('Set Num'), findsOneWidget);
    expect(find.text('Reset Num'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('Mark Num'), findsOneWidget);
    expect(find.text('Cand Pairs'), findsOneWidget);
    expect(find.text('Single Cand'), findsOneWidget);
    expect(find.text('Givens'), findsOneWidget);
  });
}
