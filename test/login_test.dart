import 'package:flutter_test/flutter_test.dart';


/// Tests for the Validators.isValidEmail static method.
void testLoginWithCredentials() {
  const String validEmail = "jandoe@gmail.com";
  const String validPassword = "password!";
  // expect(Validators.isValidEmail(validEmail), true);

  const String invalidEmail = "example@example@example.com";
  // expect(Validators.isValidEmail(invalidEmail), false);
}


void main() {
  group('login_validators', () {
    test('isValidEmail', () {
      // testIsValidEmail();
    });
    test('isValidFirstName', () {
      // testIsValidFirstName();
    });
  });
}