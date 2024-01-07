import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/main.dart' as appMain;
import '../../Model/Friend.dart';
import '../../widget/avatar.dart';

List<Friend> listFriends = [];
class OtherAllFriendPage extends StatefulWidget {
  late Friend user;
  OtherAllFriendPage(this.user, {super.key});

  @override
  State<OtherAllFriendPage> createState() => _OtherAllFriendPageState();
}

class _OtherAllFriendPageState extends State<OtherAllFriendPage> {
  bool loading = false;

  Future<GetFriendsResponse> GetFriends() async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/get_user_friends'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'index': '0',
        'count': '20',
        'user_id': widget.user.id
      }),
    );

    return GetFriendsResponse.fromJson(jsonDecode(response.body));
  }

  void initState() {
    listFriends.clear();
    GetFriends().then((value) {
      if (value.code == '1000') {
        setState(() {
          loading = true;
        });
      }
    });
    super.initState();
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
              widget.user.username,
              style: TextStyle(
                color: Colors.black
              ),
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
            shape: RoundedRectangleBorder(
                side: BorderSide(width: 0.1)
            ),
          ),
          if (!loading)...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    )
                ),
              ),
            ),
          ]
          else...[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  for (Friend friend in listFriends)
                    FriendContainer(friend)
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
}

class FriendContainer extends StatefulWidget {
  late Friend friend;
  FriendContainer(this.friend, {super.key});

  @override
  State<FriendContainer> createState() => _FriendContainerState();
}

class _FriendContainerState extends State<FriendContainer> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        child: LayoutBuilder(builder: (context, constraints) {
          return Row(
            children: [
              Avatar(widget.friend.avatar, constraints.maxWidth / 5),
              SizedBox(width: 10,),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.friend.username,
                        style: TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(height: 2.5),
                    ],
                  )
              ),
            ],
          );
        }),
      ),
    );
  }
}

class GetFriendsResponse {
  late String code;
  late String message;

  GetFriendsResponse({required this.code, required this.message});

  factory GetFriendsResponse.fromJson(Map<String, dynamic> json) {
    if (json['code'] == '1000') {
      for (var request in json['data']['friends']) {
        Friend friend = Friend();
        friend.id = request['id'];
        friend.username = request['username'];
        friend.avatar = request['avatar'];
        friend.sameFriends = request['same_friends'];
        friend.created = request['created'];

        listFriends.add(friend);
      }
    }
    return GetFriendsResponse(code: json['code'], message: json['message']);
  }
}
