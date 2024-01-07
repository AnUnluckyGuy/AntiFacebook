import 'dart:convert';

import 'package:first_app/widget/avatar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/main.dart' as appMain;

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  List<SearchedUser> listSearch = [];
  String searchKeyword = '';
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge){
        if (scrollController.position.pixels != 0) {
          addSearch();
        }
      }
    });
    super.initState();
  }

  void addSearch(){
    SearchUser(searchKeyword, listSearch.length.toString()).then((value){
      Map<String, dynamic> decodeResponse = jsonDecode(value);
      if (decodeResponse['code'] == '1000') {
        setState(() {
          for (var res in decodeResponse['data']) {
            SearchedUser user = SearchedUser();
            user.id = res['id'];
            user.username = res['username'];
            user.avatar = res['avatar'];
            listSearch.add(user);
          }
        });
      }
    });
  }

  Future SearchUser(String keyword, String index) async{
    final response = await http.post(
        Uri.parse('https://it4788.catan.io.vn/search_user'),
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${appMain.currentUser.token}'
        },
        body: jsonEncode(<String, String> {
          'keyword': keyword,
          'index': index,
          'count': '10'
        })
    );

    return response.body;
  }

  void refreshSearchResult(String keyword){
    SearchUser(keyword, '0').then((value){
      Map<String, dynamic> decodeResponse = jsonDecode(value);
      if (decodeResponse['code'] == '1000'){
        setState(() {
          searchKeyword = keyword;
          listSearch.clear();
          for (var res in decodeResponse['data']){
            SearchedUser user = SearchedUser();
            user.id = res['id'];
            user.username = res['username'];
            user.avatar = res['avatar'];
            listSearch.add(user);
          }
        });
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Kiểm tra đường truyền mạng"),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: (){
                Navigator.pop(context, 'none');
              },
              icon: Image.asset(
                'assets/images/backarrow.png',
                width: 25,
                height: 25,
              ),
            ),
            title: Container(
              child: TextField(
                autofocus: true,
                style: TextStyle(
                  fontSize: 15
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(50)
                  ),
                  hintText: 'Nhập tên'
                ),
                onSubmitted: (value){
                  if (value.trim().isNotEmpty){
                    refreshSearchResult(value.trim());
                  }
                },
              ),
            ),
            shape: RoundedRectangleBorder(
                side: BorderSide(width: 0.1)
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                for (SearchedUser user in listSearch)...[
                  SearchResultContainer(user, selectedUser)
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  void selectedUser(String id){
    Navigator.pop(context, id);
  }
}

class SearchResultContainer extends StatelessWidget {
  late SearchedUser user;
  late Function(String) onPress;
  SearchResultContainer(this.user, this.onPress, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextButton(
        onPressed: (){
          onPress(user.id);
        },
        child: Row(
          children: [
            Avatar(user.avatar, 50),
            SizedBox(width: 10,),
            Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SearchedUser {
  String id = '';
  String username = '';
  String avatar = '';
}
