import 'dart:convert';
import 'package:first_app/screen/search/profileSearchPage.dart';
import 'package:flutter/material.dart';
import 'package:first_app/main.dart' as appMain;
import 'package:http/http.dart' as http;

class OtherProfileEditPage extends StatelessWidget {
  late String id;
  OtherProfileEditPage(this.id, {super.key});

  Future Block(String id) async {
    final response = await http.post(
        Uri.parse('https://it4788.catan.io.vn/set_block'),
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${appMain.currentUser.token}'
        },
        body: jsonEncode(<String, String> {
          'user_id': id
        })
    );

    return response.statusCode.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Image.asset(
                'assets/images/backarrow.png',
                width: 25,
                height: 25,
              ),
            ),
            title: Text(
              'Cài đặt trang cá nhân',
              style: TextStyle(
                  color: Colors.black
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 10,
              color: Colors.grey[300],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: (){
                        Block(id);
                      },
                      child: Text(
                        'Chặn',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.grey[300],
                  ),
                  Container(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSearchPage(id)));
                      },
                      child: Text(
                        'Tìm kiếm trên trang cá nhân',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500
                        ),
                      )
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 10,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}
