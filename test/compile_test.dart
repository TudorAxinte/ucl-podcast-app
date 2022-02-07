import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podcasts_app/main.dart';
import 'mock/firebase_mock.dart';

void main() {
  testWidgets('Expect no errors thrown', (WidgetTester tester) async {

    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
    await tester.pumpWidget(PodcastApp());

    expect(find.text('Error'), findsNothing);
  });
}
