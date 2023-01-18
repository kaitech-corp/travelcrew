// ignore_for_file: eol_at_end_of_file

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

// Write a unit test simulating a user logging in using Firebase, Dart
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   FirebaseAuth auth;
//   String email = 'test@example.com';
//   String password = 'password123';
//
//   setUp(() {
//     auth = FirebaseAuth.instance;
//   });
//
//   test('User login with correct credentials', () async {
//     final user = await auth.signInWithEmailAndPassword(
//         email: email, password: password);
//     expect(user.email, equals(email));
//   });
//
//   test('User login with wrong credentials', () async {
//     final user = await auth.signInWithEmailAndPassword(
//         email: email, password: 'wrong_password');
//     expect(user, isNull);
//   });
// }

// Write a unit test simulating a user logging in using Firebase, Dart
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   FirebaseAuth auth;
//   String email = 'test@example.com';
//   String password = 'password123';
//
//   setUp(() {
//     auth = FirebaseAuth.instance;
//   });
//
//   test('User login with correct credentials', () async {
//     final user = await auth.signInWithEmailAndPassword(
//         email: email, password: password);
//     expect(user.email, equals(email));
//   });
//
//   test('User login with wrong credentials', () async {
//     final user = await auth.signInWithEmailAndPassword(
//         email: email, password: 'wrong_password');
//     expect(user, isNull);
//   });
// }