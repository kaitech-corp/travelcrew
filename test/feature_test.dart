import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelcrew/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:travelcrew/blocs/authentication_bloc/authentication_event.dart';
import 'package:travelcrew/main.dart';
import 'package:travelcrew/repositories/user_repository.dart';
import 'package:travelcrew/screens/login/login_screen.dart';
import 'package:travelcrew/services/initializer/project_initializer.dart';
import 'package:travelcrew/services/widgets/gradient_button.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_test/flutter_test.dart';

// Test Features in Travel Crew
Future<void> testInitializeApp() async {
  expect(await projectInitializer(), 'initialized');
}

Future<void> testFirebaseAuth() async {
  expect(await projectInitializer(), 'initialized');
  final FirebaseAuth auth = FirebaseAuth.instance;
  const String email = 'jandoe@gmail.com';
  const String password = 'password!';
  final UserCredential user =
      await auth.signInWithEmailAndPassword(email: email, password: password);
  expect(user.user!.email, equals(email));
}

void main() {
  // testWidgets('Test app start', (tester) async {
  //   await tester.runAsync(() async {
  //     expect(await projectInitializer(), 'initialized');

  //     const String email = 'jandoe@gmail.com';
  //     const String password = 'password!';
  //     // final UserRepository userRepository = UserRepository();
  //     // await tester.pumpWidget(BlocProvider<AuthenticationBloc>(
  //     //     create: (BuildContext context) =>
  //     //         AuthenticationBloc(userRepository: userRepository)
  //     //           ..add(AuthenticationLoggedOut()),
  //     //     child: LoginScreen()));
  //     await tester.pumpWidget(LoginScreen());
  //     await tester.enterText(find.byKey(const Key('email')), email);
  //     await tester.enterText(find.byKey(const Key('password')), password);
  //     // await tester.tap(find.byType(GradientButton));
  //     await tester.pump();
  //     expect(find.text(email), findsOneWidget);
  //     // expect(find.byType(CurvedNavigationBar), findsOneWidget);
  //   });
    group('feature_tests', () {
      test('Test app initiation', () {
        testInitializeApp();
      });
      test('projectInitializer', () {
        testFirebaseAuth();
      });
  });
}
