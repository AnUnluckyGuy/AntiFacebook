import 'dart:convert';
import 'package:first_app/screen/auth/signInPage.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:first_app/main.dart' as appMain;
import 'package:first_app/screen/auth/signUpPage.dart';
import 'package:flutter/material.dart';
import 'package:first_app/config/palette.dart' as palette;

class VerifyPage extends StatefulWidget {
  @override

  State<StatefulWidget> createState() => _verifyState();
}

class _verifyState extends State<VerifyPage>{
  final verifyCodeTextController = TextEditingController();
  final _palette = palette.Palette();
  String textError = "";

  @override
  void dispose() {
    verifyCodeTextController.dispose();
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
                    controller: verifyCodeTextController,
                    decoration: textError.isEmpty
                        ? _palette.inputBorderDecoration.copyWith(labelText: 'Verify code')
                        : _palette.inputBorderDecoration.copyWith(
                        labelText: 'Verify code',
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(15))),
                )
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  textError,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.red),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      String verifyCode = verifyCodeTextController.text;
                      verifyCodeTextController.clear();
                      if (verifyCode.isEmpty){
                        setState(() {(textError = 'Code can not be empty');});
                      }
                      else{
                        VerifyResponse1 responseData = await checkVerifyCode(appMain.currentUser.email, verifyCode);
                        if (responseData.code == '1000'){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage()));
                        }
                        else {
                          setState(() {(textError = 'Code is not correct');});
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    child: const Text(
                      'Verify code',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 25, 10, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      VerifyResponse responseData = await getVerifyCode(appMain.currentUser.email);
                      final scaffold = ScaffoldMessenger.of(context);
                      scaffold.showSnackBar(
                        SnackBar(
                          content: Text(responseData.verifyCode),
                          action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        side: BorderSide(color: Colors.blue)
                    ),
                    child: const Text(
                      'Send code',
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
}

Future<VerifyResponse> getVerifyCode(String email) async {
  final response = await http.post(
    Uri.parse('https://it4788.catan.io.vn/get_verify_code'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email
    }),
  );

  if (response.statusCode == 200){
    return VerifyResponse.fromJson(jsonDecode(response.body));
  }
  else if (response.statusCode == 403){
    return VerifyResponse.fromJson(jsonDecode(response.body));
  }
  else{
    throw Exception('Failed to get verify code');
  }
}

Future<VerifyResponse1> checkVerifyCode(String email, String verifyCode) async {
  final response = await http.post(
    Uri.parse('https://it4788.catan.io.vn/check_verify_code'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'code_verify': verifyCode
    }),
  );

  if (response.statusCode == 200){
    return VerifyResponse1.fromJson(jsonDecode(response.body));
  }
  else if (response.statusCode == 400){
    return VerifyResponse1.fromJson(jsonDecode(response.body));
  }
  else{
    throw Exception('Failed to check verify code');
  }
}

class VerifyResponse {
  late String code;
  late String message;
  late String verifyCode;

  VerifyResponse({required this.code, required this.message, required this.verifyCode});

  factory VerifyResponse.fromJson(Map<String, dynamic> json) {
    if (json['code'] == '1000') {
      return VerifyResponse(code: json['code'], message: json['message'], verifyCode: json['data']['verify_code']);
    }
    else {
      return VerifyResponse(code: json['code'], message: json['message'], verifyCode: "");
    }
  }
}

class VerifyResponse1 {
  late String code;
  late String message;

  VerifyResponse1({required this.code, required this.message});

  factory VerifyResponse1.fromJson(Map<String, dynamic> json) {
    if (json['code'] == '1000') {
      return VerifyResponse1(code: json['code'], message: json['message']);
    }
    else {
      return VerifyResponse1(code: json['code'], message: json['message']);
    }
  }
}