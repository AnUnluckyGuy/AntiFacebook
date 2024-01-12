import 'dart:convert';
import 'package:first_app/main.dart' as appMain;
import 'package:first_app/screen/navbar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:first_app/config/palette.dart' as palette;

class FinishSignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FinishSignUpState();
}

class _FinishSignUpState extends State<FinishSignUpPage> {
  final fnameTextController = TextEditingController();
  final lnameTextController = TextEditingController();
  final _palette = palette.Palette();
  int textError = 0;

  @override
  void dispose() {
    fnameTextController.dispose();
    lnameTextController.dispose();
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
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                        child: TextField(
                            controller: fnameTextController,
                            //decoration: inputBorderDecoration.copyWith(labelText: 'Verify code')
                            decoration: ((textError == 1) || (textError == 3))
                                ? _palette.inputBorderDecoration.copyWith(
                                    labelText: 'First name',
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            const BorderSide(color: Colors.red),
                                        borderRadius:
                                            BorderRadius.circular(15)))
                                : _palette.inputBorderDecoration
                                    .copyWith(labelText: 'First name'))),
                  ),
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                        child: TextField(
                            controller: lnameTextController,
                            //decoration: inputBorderDecoration.copyWith(labelText: 'Verify code')
                            decoration: ((textError == 2) || (textError == 3))
                                ? _palette.inputBorderDecoration.copyWith(
                                    labelText: 'Last name',
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            const BorderSide(color: Colors.red),
                                        borderRadius:
                                            BorderRadius.circular(15)))
                                : _palette.inputBorderDecoration
                                    .copyWith(labelText: 'Last name'))),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      String fname = fnameTextController.text;
                      String lname = lnameTextController.text;
                      fnameTextController.clear();
                      fname = fname.trim();
                      lname = lname.trim();
                      if (fname.isEmpty || lname.isEmpty) {
                        int t = 0;
                        if (fname.isEmpty && lname.isEmpty)
                          t = 3;
                        else if (fname.isEmpty)
                          t = 1;
                        else
                          t = 2;
                        setState(() {
                          (textError = t);
                        });
                      } else {
                        String name = fname + lname;
                        await finishSignUp(name).then((value) {
                          if (value == '1000'){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavBar()));
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
                      'Finish',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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

  Future finishSignUp(String name) async {
    var bodyDataMap = <String, dynamic>{
      'username': name,
    };
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/change_profile_after_signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
      },
      body: jsonEncode(bodyDataMap),
    );

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);

    return decodeResponse['code'];
  }
}
