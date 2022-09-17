import 'package:flutter_test/flutter_test.dart';
import 'package:travelcrew/utils/validators.dart';

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

void main() {
  group('validators', () {
    test('isValidEmail', () {
      testIsValidEmail();
    });
    test('isValidPassword', () {
      testIsValidPassword();
    });
  });
}
