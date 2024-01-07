import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/main.dart' as appMain;

class MenuPasswordEditPage extends StatefulWidget {

  @override
  State<MenuPasswordEditPage> createState() => _MenuPasswordEditPageState();
}

class _MenuPasswordEditPageState extends State<MenuPasswordEditPage> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();

  bool check(){
    if (controller1.text != controller2.text) return false;
    if (controller1.text == controller3.text) return false;
    if (controller3.text.length < 6 || controller3.text.length > 20) return false;
    if (!RegExp(r"^[a-zA-Z0-9]+$").hasMatch(controller3.text)) return false;
    return true;
  }

  Future ChangePassword() async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/change_password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'password': controller1.text,
        'new_password': controller3.text
      }),
    );

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);
    if (decodeResponse['code'] == '1000'){
      appMain.currentUser.token = decodeResponse['data']['token'];
    }
    return response.statusCode.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Image.asset(
                  'assets/images/backarrow.png',
                  width: 25,
                  height: 25,
                ),
              ),
              title: Text(
                'Đổi mật khẩu',
                style: TextStyle(
                    color: Colors.black
                ),
              ),
              shape: RoundedRectangleBorder(
                  side: BorderSide(width: 0.1)
              )
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: TextField(
                      controller: controller1,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue, width: 3),
                              borderRadius: BorderRadius.circular(10)),
                        hintText: 'Nhập mật khẩu cũ'
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: TextField(
                      controller: controller2,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.blue, width: 3),
                            borderRadius: BorderRadius.circular(10)),
                        hintText: 'Nhập lại mật khẩu cũ'
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: TextField(
                      controller: controller3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue, width: 3),
                          borderRadius: BorderRadius.circular(10)),
                          hintText: 'Nhập mật khẩu mới'
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        if (check()){
                          await ChangePassword().then((value){
                            if (value == '200'){
                              Navigator.pop(context);
                            }
                            else {
                              final scaffold = ScaffoldMessenger.of(context);
                              scaffold.showSnackBar(
                                  SnackBar(
                                    content: Text('Mật khẩu cũ không đúng'),
                                    //action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
                                  )
                              );
                            }
                          });
                        }
                        else {
                          final scaffold = ScaffoldMessenger.of(context);
                          scaffold.showSnackBar(
                            SnackBar(
                              content: Text('Mật khẩu cũ không đúng hoặc mật khẩu mới không hợp lệ'),
                              //action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Lưu thay đổi',
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(width: 0.5)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
