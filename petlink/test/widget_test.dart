import 'package:flutter_test/flutter_test.dart';
import 'package:petlink/app/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const PetLinkApp());
    await tester.pumpAndSettle();

    expect(find.text('Radar'), findsWidgets);
  });
}
