import 'package:flutter_test/flutter_test.dart';
import 'package:travelcrew/services/initializer/project_initializer.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_test/flutter_test.dart';

// Test Features in Travel Crew
Future<void> testIsProjectInitialized() async {
  expect(await projectInitializer(), 'initialized');
}

void main() {
  group('feature_tests', () {
    test('projectInitializer', () {
      testIsProjectInitialized();
    });
  });
}
