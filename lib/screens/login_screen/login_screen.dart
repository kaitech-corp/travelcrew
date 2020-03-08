import 'package:flutter/material.dart';
import 'package:travelcrew/screens/loading.dart';
import 'package:travelcrew/screens/login_screen/signup_screen.dart';
import 'package:travelcrew/services/auth.dart';
import 'image_banner.dart';


class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();

}
  class _LoginPageState extends State<LoginPage> {

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
                      setState(() => loading = true);
                      dynamic result = await _auth.signInCredentials(email, password);
                      if (result == null) {
                        setState(() {
                          error = result;
                        });
                      } else {
//                        setState(() => loading = false);
                        print('Logged in.');
                      }

                  },
                  color: Colors.lightBlue,
                  child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 20)
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
                    style: TextStyle(color: Colors.red, fontSize: 16.0),),
                ],
              )
            ],
          ),
      ),
    );
  }
}