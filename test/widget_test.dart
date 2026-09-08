import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/main.dart';
import 'package:tee_rk/screens/shell/main_shell.dart';

void main() {
  testWidgets('App boots into the main shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TeeRkApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('BAG'), findsOneWidget);
  });
}
