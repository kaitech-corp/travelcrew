import 'package:flutter/material.dart';
import 'package:travelcrew/screens/login_screen/signup_screen.dart';
import 'package:travelcrew/services/auth.dart';
import 'image_banner.dart';


class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();

}
  class _LoginPageState extends State<LoginPage> {
    final _formKey = GlobalKey<FormState>();

    Key get key => null;

  final AuthService _auth = AuthService();
  bool loading = false;
  String error = '';
  String email = '';
  String password = '';
//TODO: Add form and validator and return errors
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
         child: Builder(
           builder: (context) => Form(
             key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ImageBanner("assests/images/travelPics.png"),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  ),
                  TextFormField(
                    enableInteractiveSelection: true,
                    validator: (value) {
                      if (value.isEmpty || !value.contains('.com')) {
                        return 'Please enter valid email address.';
                      }
                    },
                    onChanged: (val){
                      setState(() => email = val.trim());
                    },
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Email",
                    ),
                  ),
                  TextFormField(
                    onChanged: (val){
                      setState(() => password = val);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter password.';
                      }
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Password",
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30.0, horizontal: 30.0),
                    child: RaisedButton(
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
                          style: TextStyle(color: Colors.white, fontSize: 20 )
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('No account?'),
                        FlatButton(
                          child: Text('Sign up here!'),
                          textColor: Colors.lightBlue,
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupScreen()),
                            );
                          },
                        )
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
}