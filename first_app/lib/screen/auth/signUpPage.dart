import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:first_app/screen/auth/signInPage.dart';
import 'package:first_app/main.dart' as appMain;
import 'package:first_app/screen/auth/verifyPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/config/palette.dart' as palette;


class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage>{
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final _palette = palette.Palette();
  String preEmail = '';
  String emailError = '';
  String passwordError = '';

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
              Align(
                alignment: AlignmentDirectional(-1.00, -1.00),
                child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: IconButton(
                      icon: Icon(Icons.chevron_left_sharp),
                      onPressed: (){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage())); },
                      iconSize: 40,
                    )
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                          borderRadius: BorderRadius.circular(15)))),
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
                      email = email.trim();
                      password = password.trimRight();
                      emailTextController.clear();
                      passwordTextController.clear();
                      checkSignUpInfo(email, password);
                      if (emailError.isEmpty && passwordError.isEmpty){
                        SignUpResponse responseData = await signUp(email, password);
                        if (responseData.code == '1000'){
                          appMain.currentUser.email = email;
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerifyPage()));
                        }
                        else {
                          setState(() {(preEmail, emailError = 'This user existed', passwordError);});
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
                      'Sign Up',
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

  void checkSignUpInfo(String email, String password) {
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

  Future<SignUpResponse> signUp(String email, String password) async {
    var androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'uuid': androidDeviceInfo.id
      }),
    );

    if (response.statusCode == 201){
      return SignUpResponse.fromJson(jsonDecode(response.body));
    }
    else if (response.statusCode == 400){
      return SignUpResponse.fromJson(jsonDecode(response.body));
    }
    else{
      throw Exception('Failed to Sign Up');
    }
  }
}

class SignUpResponse {
  late String code;
  late String message;

  SignUpResponse({required this.code, required this.message});

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    if (json['code'] == '1000') {
      return SignUpResponse(code: json['code'], message: json['message']);
    }
    else {
      return SignUpResponse(code: json['code'], message: json['message']);
    }
  }
}