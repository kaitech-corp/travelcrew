
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/utils/validators.dart';

/// Tests for the Validators.isValidEmail static method.
void testIsValidEmail() {
  const String validEmail = "example@example.com";
  expect(Validators.isValidEmail(validEmail), true);

  const String invalidEmail = "example@example@example.com";
  expect(Validators.isValidEmail(invalidEmail), false);
}

/// Tests for the Validators.isValidFirstName static method.
void testIsValidFirstName() {
  const String validFirstName = "Charlie";
  expect(Validators.isValidFirstName(validFirstName), true);

  const String invalidFirstName = "";
  expect(Validators.isValidFirstName(invalidFirstName), false);
}

void main() {
  group('validators', () {
    test('isValidEmail', () {
      testIsValidEmail();
    });
    test('isValidFirstName', () {
      testIsValidFirstName();
    });
  });
}

