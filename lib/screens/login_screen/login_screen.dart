import 'package:flutter/material.dart';
import 'package:travelcrew/screens/login_screen/signup_screen.dart';
import 'package:travelcrew/services/apple_auth.dart';
import 'package:travelcrew/services/auth.dart';
import 'package:travelcrew/services/google_auth.dart';
import 'image_banner.dart';


class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();

}
  class _LoginPageState extends State<LoginPage> {

    final _formKey = GlobalKey<FormState>();

    Key get key => null;

  final AuthService _auth = AuthService();
  final AppleAuthService _auth2 = AppleAuthService();
  bool loading = false;
  String error = '';
  String email = '';
  String password = '';
//TODO: Add form and validator and return errors
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login',style: Theme.of(context).textTheme.headline3,),
      ),
      body: SingleChildScrollView(
         child: Builder(
           builder: (context) => Form(
             key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ImageBanner("assets/images/travelPics.png"),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        TextFormField(
                          style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                          enableInteractiveSelection: true,
                          validator: (value) {
                            if (value.isEmpty || !value.contains('.com')) {
                              return 'Please enter valid email address.';
                            } else {
                            return null;
                            }
                          },
                          onChanged: (val){
                            setState(() => email = val.trim());
                            setState(() =>error = '');
                          },
                          obscureText: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Email",
                            labelStyle: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextFormField(
                          style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                          onChanged: (val){
                            setState(() => password = val);
                            setState(() =>error = '');
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter password.';
                            } else {
                              return null;
                            }
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Password",
                            labelStyle: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)
                          ),
                        ),
                      ],
                    ),
                  ),
//                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30.0, horizontal: 50.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                      onPressed: () async{
                        final form = _formKey.currentState;
                        if (form.validate()){
                          setState(() => loading = true);
                          dynamic result = await _auth.signInCredentials(email, password);
                          try {
                            var _ =result.uid;
                          } catch (e){
                            setState(() {
                              error = result;
                            });
                          }
                        }
                      },
                      color: Colors.lightBlue,
                      child: const Text(
                          'Login',
                          style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold,fontSize: 20)
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _signInButton(),
                      FutureBuilder(
                        future: _auth2.appleSignInAvailable,
                        builder: (context, snapshot) {

                          if (snapshot.data == true) {
                            return _signInAppleButton();
                          } else {
                            return Container();
                          }
                        },
                      ),

                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('No account?',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                        FlatButton(
                          child: Text('Sign up here!',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                          textColor: Colors.lightBlue,
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(error != null ? error : '',
                        style: TextStyle(color: Colors.red, fontSize: 16.0), textAlign: TextAlign.center,),
                    ],
                  )
                ],
              ),
           ),
        ),
      ),
    );
  }

    Widget _signInButton() {
      return OutlineButton(
        splashColor: Colors.grey,
        onPressed: () {
          GoogleAuthService().signInWithGoogle();
        },
        shape: CircleBorder(),
        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.grey),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage("assets/images/google_logo.png"), height: 25.0),
//              Padding(
//                padding: const EdgeInsets.only(left: 10),
//                child: Text(
//                  'Sign in with Google',
//                  style: TextStyle(
//                    fontSize: 20,
//                    color: Colors.grey,
//                  ),
//                ),
//              )
            ],
          ),
        ),
      );
    }

    Widget _signInAppleButton() {
      return OutlineButton(
        splashColor: Colors.grey,
        onPressed: () {
          _auth2.appleSignIn();
        },
        shape: CircleBorder(),
        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.grey),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage("assets/images/apple_logo.png"), height: 25.0),
//              Padding(
//                padding: const EdgeInsets.only(left: 10),
//                child: Text(
//                  'Sign in with Google',
//                  style: TextStyle(
//                    fontSize: 20,
//                    color: Colors.grey,
//                  ),
//                ),
//              )
            ],
          ),
        ),
      );
    }
}