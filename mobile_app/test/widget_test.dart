import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luster_360/app.dart';

void main() {
  testWidgets('Luster 360 smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: Luster360App()));
    expect(find.byType(Luster360App), findsOneWidget);
  });
}
