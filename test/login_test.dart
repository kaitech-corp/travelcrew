import 'package:flutter_test/flutter_test.dart';
import 'package:travelcrew/repositories/user_repository.dart';
import 'package:travelcrew/services/initializer/project_initializer.dart';


/// Tests for the Validators.isValidEmail static method.
void testLoginWithCredentials() async {
  const String validEmail = "jandoe@gmail.com";
  const String validPassword = "password!";

  expect(await projectInitializer(), "Passed");

  // expect(Validators.isValidEmail(validEmail), true);

  const String invalidEmail = "example@example@example.com";
  // expect(Validators.isValidEmail(invalidEmail), false);
  UserRepository().signInWithCredentials(validEmail, validPassword).then((value) => {
    if(value.user.uid.isNotEmpty){
      print('Login successful')
    } else {
      print('Login unsuccessful')
    }
  });

}


void main() {
  group('login_validators', () {
    test('isValidEmail', () {
    });
    test('testLoginWithCredentials', () {
      testLoginWithCredentials();
    });
  });
}