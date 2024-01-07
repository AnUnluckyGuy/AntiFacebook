import 'dart:convert';

import 'package:first_app/screen/menu/userSearchPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/main.dart' as appMain;

import '../../widget/avatar.dart';

class MenuBlockPage extends StatefulWidget {
  const MenuBlockPage({super.key});

  @override
  State<MenuBlockPage> createState() => _MenuBlockPageState();
}

class _MenuBlockPageState extends State<MenuBlockPage> {
  bool loading = false;
  List<BlockUser> listBlocks = [];
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge){
        if (scrollController.position.pixels != 0) {
          addBlock();
        }
      }
    });
    listBlocks.clear();
    GetListBlocks('0').then((value) {
      if (value == '200'){
        setState(() { loading = true; });
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Kiểm tra đường truyền mạng"),
        ));
      }
    });
    super.initState();
  }

  void addBlock(){
    GetListBlocks(listBlocks.length.toString()).then((value){
      if (value == '200'){
        setState(() {});
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Kiểm tra đường truyền mạng"),
        ));
      }
    });
  }

  Future GetListBlocks(String index) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/get_list_blocks'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'index': index,
        'count': '15'
      }),
    );

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);
    if (decodeResponse['code'] == '1000'){
      for (var block in decodeResponse['data']){
        BlockUser blockUser = BlockUser();
        blockUser.id = block['id'];
        blockUser.name = block['name'];
        blockUser.avatar = block['avatar'];
        listBlocks.add(blockUser);
      }
    }

    return response.statusCode.toString();
  }

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

  Future Unblock(String id) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/unblock'),
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

  void unblock(BlockUser user) {
    Unblock(user.id).then((value){
      if (value == '200'){
        listBlocks.remove(user);
        setState(() {});
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Kiểm tra đường truyền mạng"),
        ));
      }
    });
  }

  void refresh(){
    listBlocks.clear();
    GetListBlocks('0').then((value) {
      if (value == '200'){
        setState(() { loading = true; });
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
                Navigator.pop(context);
              },
              icon: Image.asset(
                'assets/images/backarrow.png',
                width: 25,
                height: 25,
              ),
            ),
            title: Text(
              'Chặn',
              style: TextStyle(
                color: Colors.black
              ),
            ),
            shape: RoundedRectangleBorder(
                side: BorderSide(width: 0.1)
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Người bị chặn',
                    style: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UserSearchPage())).then((value){
                        if (value != 'none'){
                          Block(value).then((value){
                            if (value == '200'){
                              setState(() {
                                loading = false;
                              });
                              refresh();
                            }
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("Chặn người dùng thất bại"),
                              ));
                            }
                          });
                        }
                      });
                    },
                    child: Text('+ THÊM VÀO DANH SÁCH CHẶN')
                  )
                ],
              ),
            ),
          ),
          if (loading)...[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  for (BlockUser user in listBlocks)
                    BlockContainer(user, unblock)
                ],
              ),
            )
          ]
          else...[
            SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator())
            )
          ]
        ],
      ),
    );
  }
}

class BlockUser {
  String id = '';
  String name = '';
  String avatar = '';
}

class BlockContainer extends StatelessWidget {
  late BlockUser user;
  late Function(BlockUser) onPress;
  BlockContainer(this.user, this.onPress, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        child: Row(
          children: [
            Avatar(user.avatar, 50),
            SizedBox(width: 10,),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500
              ),
            ),
            Expanded(child: SizedBox()),
            TextButton(
              onPressed: (){
                onPress(user);
              },
              child: Text(
                'BỎ CHẶN',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w500
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}

