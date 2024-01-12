import 'dart:convert';
import 'package:first_app/screen/auth/finishSignUpPage.dart';
import 'package:first_app/screen/navbar.dart';
import 'package:first_app/screen/auth/signUpPage.dart';
import 'package:first_app/screen/auth/verifyPage.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:first_app/main.dart' as appMain;
import 'package:first_app/config/palette.dart' as palette;

class SignInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignInPage>{
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  String preEmail = '';
  String emailError = '';
  String passwordError = '';
  final _palette = palette.Palette();

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: Image.asset(
                  'assets/images/facebook_logo.png',
                  width: 60,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: TextField(
                  controller: emailTextController..text = preEmail,
                  decoration: emailError.isEmpty
                      ? _palette.inputBorderDecoration.copyWith(labelText: 'Email')
                      : _palette.inputBorderDecoration.copyWith(
                      labelText: 'Email',
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(15))),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  emailError,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.red),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextField(
                  controller: passwordTextController,
                  decoration: passwordError.isEmpty
                      ? _palette.inputBorderDecoration.copyWith(labelText: 'Password')
                      : _palette.inputBorderDecoration.copyWith(
                      labelText: 'Password',
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(15))),
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  passwordError,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.red),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      String email = emailTextController.text;
                      String password = passwordTextController.text;
                      emailTextController.clear();
                      passwordTextController.clear();
                      checkSignInInfo(email, password);
                      if (emailError.isEmpty && passwordError.isEmpty){
                        await signIn(email, password).then((value) {
                          if (value == '1000'){
                            switch(appMain.cache.currentUser.active) {
                              case "0":
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerifyPage()));
                                break;
                              case "1"://To Newsfeeds
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavBar()));
                                break;
                              case "-1"://Finish sign up
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FinishSignUpPage()));
                                break;
                              default:
                                break;
                            }
                          }
                          else {
                            setState(() {(preEmail, emailError = '', passwordError = '');});
                          }
                        });
                      }
                      else {
                        setState(() {(preEmail, emailError, passwordError);});
                      }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 25, 10, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        side: BorderSide(color: Colors.blue)
                    ),
                    child: const Text(
                      'Create new account',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkSignInInfo(String email, String password) {
    preEmail = email;
    emailError = '';
    passwordError = '';

    bool emailCheck = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    if (emailCheck == false) emailError = 'Invalid email';
    if (email.isEmpty) emailError = 'Email can not be empty';

    bool passCheck = !((password == email) ||
        (password.length < 6) ||
        (password.length > 10) ||
        !RegExp(r"^[a-zA-Z0-9]+$").hasMatch(password));
    if (passCheck == false){
      if (password == email) passwordError = 'Password can not be similar to email';
      else if (password.length < 6) passwordError = 'Password can not be too short';
      else if (password.length > 10) passwordError = 'Password can not be too long';
      else passwordError = 'Password can not contain special character';
    }
    if (password.isEmpty) passwordError = 'Password can not be empty';
  }

  Future signIn(String email, String password) async {
    var androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'uuid': androidDeviceInfo.id
      }),
    );

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);
    if (decodeResponse['code'] == '1000'){
      appMain.cache.currentUser.id = decodeResponse['data']['id'];
      appMain.cache.currentUser.username = decodeResponse['data']['username'];
      appMain.cache.currentUser.token = decodeResponse['data']['token'];
      appMain.cache.currentUser.avatar = decodeResponse['data']['avatar'];
      appMain.cache.currentUser.active = decodeResponse['data']['active'];
      appMain.cache.currentUser.coins = int.parse(decodeResponse['data']['coins']);
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(decodeResponse['message']),
      ));
    }

    return decodeResponse['code'];
  }
}
