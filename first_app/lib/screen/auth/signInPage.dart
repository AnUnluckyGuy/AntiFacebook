import 'dart:convert';
import 'package:first_app/screen/auth/finishSignUpPage.dart';
import 'package:first_app/screen/navbar.dart';
import 'package:first_app/screen/newsfeedsPage.dart';
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
                        SignInResponse responseData = await signIn(email, password);
                        if (responseData.code == '1000'){
                          print("Sign in success");
                          switch(appMain.currentUser.active) {
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
                          setState(() {(preEmail, emailError = responseData.message, passwordError = responseData.message);});
                        }
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

  Future<SignInResponse> signIn(String email, String password) async {
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

    if (response.statusCode == 200){
      return SignInResponse.fromJson(jsonDecode(response.body));
    }
    else if (response.statusCode == 403){
      return SignInResponse.fromJson(jsonDecode(response.body));
    }
    else{
      throw Exception('Failed to Sign In');
    }
  }
}

class SignInResponse {
  late String code;
  late String message;

  SignInResponse({required this.code, required this.message});

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    if (json['code'] == '1000') {
      appMain.currentUser.id = json['data']['id'];
      appMain.currentUser.username = json['data']['username'];
      appMain.currentUser.token = json['data']['token'];
      appMain.currentUser.avatar = json['data']['avatar'];
      appMain.currentUser.active = json['data']['active'];
      appMain.currentUser.coins = int.parse(json['data']['coins']);
      return SignInResponse(code: json['code'], message: json['message']);
    }
    else {
      return SignInResponse(code: json['code'], message: json['message']);
    }
  }
}
