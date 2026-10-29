import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petlink/app/app.dart';

void main() {
  testWidgets('Intro transitions to Welcome for unauthenticated users', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PetLinkApp()));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNothing);

    await tester.pump(const Duration(milliseconds: 3600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('PetLink'), findsOneWidget);
    expect(find.text('Encuentra el camino de vuelta a casa'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });
}
