import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petlink/app/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PetLinkApp()));
    await tester.pumpAndSettle();

    expect(find.text('Radar'), findsWidgets);
  });
}
