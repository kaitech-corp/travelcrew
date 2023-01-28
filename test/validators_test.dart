import 'package:flutter_test/flutter_test.dart';
import 'package:travelcrew/services/initializer/project_initializer.dart';
import 'package:travelcrew/utils/validators.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_test/flutter_test.dart';

/// Tests for the Validators.isValidEmail static method.
void testIsValidEmail() {
  const String validEmail = 'robdoe@gmail.com';
  expect(isValidEmail(validEmail), true);

  const String invalidEmail = 'example@example@example.com';
  expect(isValidEmail(invalidEmail), false);
}

/// Tests for the Validators.isValidFirstName static method.
void testIsValidPassword() {
  const String validPassword = 'password!';
  expect(isValidPassword(validPassword), true);

  const String invalidPassword = '';
  expect(isValidPassword(invalidPassword), false);
}

Future<void> testIsProjectInitialized() async {
  expect(await projectInitializer(), 'initialized');
}

void main() {
  group('validators', () {
    test('isValidEmail', () {
      testIsValidEmail();
    });
    test('isValidPassword', () {
      testIsValidPassword();
    });
    test('projectInitializer', () {
      testIsProjectInitialized();
    });
  });
}
