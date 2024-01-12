import 'dart:convert';

import 'package:first_app/screen/menu/menuEditPage.dart';
import 'package:first_app/widget/avatar.dart';
import 'package:flutter/material.dart';
import '../auth/signInPage.dart';
import 'package:first_app/main.dart' as appMain;
import 'package:http/http.dart' as http;
import '../navbar.dart' as navbar;

final avatarNotifier = ValueNotifier(appMain.cache.currentUser.avatar);
final coinsNotifier = ValueNotifier(appMain.cache.currentUser.coins);

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();

  void avatarChanged(){
    avatarNotifier.value = appMain.cache.currentUser.avatar;
  }

  void coinsChanged(){
    coinsNotifier.value = appMain.cache.currentUser.coins;
  }
}

class _MenuPageState extends State<MenuPage> {

  Future BuyCoin() async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/buy_coins'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'code': 'code',
        'coins': '3000'
      }),
    );

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);

    if (decodeResponse['code'] == '1000'){
      appMain.cache.currentUser.coins = decodeResponse['data']['coins'];
      coinsNotifier.value = appMain.cache.currentUser.coins;
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(decodeResponse['message']),
      ));
    }

    return response.statusCode.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe3e6ea),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Color(0xffe3e6ea),
            title: Text(
              'Menu',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color:Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.search, size: 25,),
                  color: Colors.black,
                ),
              )
            ],
          ),
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: (){
                navbar.selectedIndex.value = 3;
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: avatarNotifier,
                      builder: (context, value, child) {
                        return Avatar(avatarNotifier.value, 50, online: "1",);
                      }
                    ),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appMain.cache.currentUser.username,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17.5,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        Text(
                          'Xem trang cá nhân của bạn',
                          style: TextStyle(
                            color: Colors.grey
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: coinsNotifier,
                    builder: (context, value, child) {
                      return Text(
                        'Số coin còn lại: ${coinsNotifier.value}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500
                        ),
                      );
                    }
                  ),
                  Expanded(child: SizedBox()),
                  TextButton(
                    onPressed: () async {
                      await BuyCoin();
                    },
                    child: Text('Thêm coins'),
                  )
                ],
              ),
            ),
          ),
          /*SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomButton(
                        'Bảng tin',
                        Image.asset(
                          'assets/images/newspaper.png',
                          width: 30,
                          height: 30,
                        )
                      ),
                      SizedBox(width: 10),
                      CustomButton(
                        'Bạn bè',
                        Image.asset(
                          'assets/images/friend.png',
                          width: 30,
                          height: 30,
                        )
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      CustomButton(
                          'Nhóm',
                          Image.asset(
                            'assets/images/groups.png',
                            width: 30,
                            height: 30,
                          )
                      ),
                      SizedBox(width: 10),
                      CustomButton(
                          'Bạn bè',
                          Image.asset(
                            'assets/images/friend.png',
                            width: 30,
                            height: 30,
                          )
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/more.png',
                          width: 30,
                          height: 30,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 10,),
                        Text(
                          'Xem thêm',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Image.asset(
                              'assets/images/arrowdown.png',
                              width: 30,
                              height: 30,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),*/
          SliverToBoxAdapter(
            child: Divider(
              color: Color(0xffafaeae),
              thickness: 0.25,
              height: 0.5
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: MenuCustomWidget(),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
                color: Color(0xffafaeae),
                thickness: 0.25,
                height: 0.5
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: MenuCustomWidget1(),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
                color: Color(0xffafaeae),
                thickness: 0.25,
                height: 0.5
            ),
          ),
          SliverToBoxAdapter(
            child: TextButton(
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage()));
              },
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logout.png',
                    color: Colors.blue,
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10,),
                  Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]
              )
            ),
          )
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  late String text;
  late Image icon;
  CustomButton(this.text, this.icon,{super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: (){},
        style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: icon
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}

class MenuCustomWidget extends StatefulWidget {
  const MenuCustomWidget({super.key});

  @override
  State<MenuCustomWidget> createState() => _MenuCustomWidgetState();
}

class _MenuCustomWidgetState extends State<MenuCustomWidget> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: (){
            setState(() { open = !open; });
          },
          child: Row(
            children: [
              Image.asset(
                'assets/images/questionmark.png',
                color: Colors.blue,
                width: 30,
                height: 30,
              ),
              SizedBox(width: 10,),
              Text(
                'Trợ giúp & hỗ trợ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    open ? 'assets/images/arrowup.png' : 'assets/images/arrowdown.png',
                    width: 30,
                    height: 30,
                    color: Colors.black
                  ),
                ),
              ),
            ]
          )
        ),
        if (open)...[
          MenuCustomWidgetItem('Trung tâm trợ giúp', (){}),
          MenuCustomWidgetItem('Hộp thư hỗ trợ', (){}),
          MenuCustomWidgetItem('Cộng đồng trợ giúp', (){}),
          MenuCustomWidgetItem('Báo cáo sự cố', (){}),
          MenuCustomWidgetItem('Điều khoản & chính sách', (){}),
        ]
      ],
    );
  }
}

class MenuCustomWidgetItem extends StatelessWidget {
  late String text;
  late Function() onPress;
  MenuCustomWidgetItem(this.text, this.onPress, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: TextButton(
            onPressed: onPress,
            style: TextButton.styleFrom(
                backgroundColor: Colors.white
            ),
            child: Text(
              text,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500
              ),
            )
        ),
      ),
    );
  }
}

class MenuCustomWidget1 extends StatefulWidget {
  const MenuCustomWidget1({super.key});

  @override
  State<MenuCustomWidget1> createState() => _MenuCustomWidget1State();
}

class _MenuCustomWidget1State extends State<MenuCustomWidget1> {
  bool open = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
            onPressed: (){
              setState(() { open = !open; });
            },
            child: Row(
                children: [
                  Image.asset(
                    'assets/images/settings.png',
                    color: Colors.blue,
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10,),
                  Text(
                    'Cài đặt thông báo đẩy',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                          open ? 'assets/images/arrowup.png' : 'assets/images/arrowdown.png',
                          width: 30,
                          height: 30,
                          color: Colors.black
                      ),
                    ),
                  ),
                ]
            )
        ),
        if (open)...[
          MenuCustomWidgetItem('Cài đặt', (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => MenuEditPage()));
          }),
          MenuCustomWidgetItem('Lối tắt quyền riêng tư', (){}),
          MenuCustomWidgetItem('Thời gian trên Anti facebook', (){}),
          MenuCustomWidgetItem('Ngôn ngữ', (){}),
          MenuCustomWidgetItem('Trình tiết kiệm dữ liệu', (){}),
          MenuCustomWidgetItem('Trình tạo mã', (){}),
        ]
      ],
    );
  }
}




