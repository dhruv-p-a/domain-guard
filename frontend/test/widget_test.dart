import 'package:flutter_test/flutter_test.dart';
import 'package:domainguard_frontend/app.dart';

void main() {
  testWidgets('DomainGuardApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DomainGuardApp());
    expect(find.byType(DomainGuardApp), findsOneWidget);
  });
}
