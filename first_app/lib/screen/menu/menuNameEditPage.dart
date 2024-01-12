import 'dart:convert';

import 'package:first_app/screen/auth/signInPage.dart';
import 'package:flutter/material.dart';
import 'package:first_app/main.dart' as appMain;
import 'package:http/http.dart' as http;

class MenuNameEditPage extends StatefulWidget {
  const MenuNameEditPage({super.key});

  @override
  State<MenuNameEditPage> createState() => _MenuNameEditPageState();
}

class _MenuNameEditPageState extends State<MenuNameEditPage> {
  TextEditingController nameEditController = TextEditingController();

  Future<String> SetUserName(String name) async {
    var req = http.MultipartRequest('POST', Uri.parse('https://it4788.catan.io.vn/set_user_info'));
    req.headers.addAll({
      //'Content-Type': 'multipart/form-data; charset=UTF-8',
      'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
    });
    req.fields['username'] = name;
    final response = await req.send();

    //Map<String, dynamic> decodeResponse = jsonDecode(response.);
    return response.statusCode.toString();
  }

  bool check(String name){
    if (name.trim().isEmpty) return false;
    if (!RegExp(r"^[a-zA-Z0-9 ]+$").hasMatch(name)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                'Tên',
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
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tên',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: nameEditController..text = appMain.cache.currentUser.username,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue, width: 3),
                          borderRadius: BorderRadius.circular(15))
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xffd3d1d1),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text('Xin lưu ý rằng: Nếu đổi tên, bạn không thể đổi lại tên trong 60 ngày. Đừng thêm bất cứ cách viết hoa khác thường, dấu câu, ký tự hoặc các từ ngẫu nhiên.')),
                  Container(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        if (nameEditController.text != appMain.cache.currentUser.username){
                          if (check(nameEditController.text)){
                            await SetUserName(nameEditController.text).then((value){
                              if (value == '201'){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage()));
                              }
                            });
                          }
                        }
                      },
                      child: Text(
                        'Thay đổi',
                        style: TextStyle(
                          color: Colors.black
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.grey,
                          width: 0.5
                        )
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
