import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:first_app/screen/auth/finishSignUpPage.dart';
import 'package:first_app/screen/auth/signInPage.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/main.dart' as appMain;
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
                        await checkVerifyCode(appMain.cache.currentUser.email, verifyCode).then((value) async {
                          if (value == '1000'){
                            await signIn(appMain.cache.currentUser.email, appMain.cache.currentUser.password).then((value) {
                              if (value == '1000'){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FinishSignUpPage()));
                              }
                            });
                          }
                          else {
                            setState(() {(textError = '');});
                          }
                        });
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
                      await getVerifyCode(appMain.cache.currentUser.email);
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

  Future getVerifyCode(String email) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/get_verify_code'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email
      }),
    );

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);

    if (decodeResponse['code'] == '1000'){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(decodeResponse['data']['verify_code']),
      ));
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(decodeResponse['message']),
      ));
    }
    return decodeResponse['code'];
  }

  Future checkVerifyCode(String email, String verifyCode) async {
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

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);

    if (decodeResponse['code'] == '1000'){

    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(decodeResponse['message']),
      ));
    }

    return decodeResponse['code'];
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
        content: Text('Error to verify'),
      ));
    }

    return decodeResponse['code'];
  }
}

