import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petlink/app/app.dart';

void main() {
  testWidgets('Welcome screen renders for unauthenticated users', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PetLinkApp()));
    await tester.pumpAndSettle();

    expect(find.text('PetLink'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });
}
