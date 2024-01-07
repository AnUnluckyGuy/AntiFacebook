import 'dart:convert';

import 'package:first_app/screen/profile/OtherAllFriendPage.dart';
import 'package:first_app/screen/profile/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/main.dart' as appMain;
import '../../Model/Friend.dart';
import '../../widget/avatar.dart';
import 'otherProfilePage.dart';

List<Friend> listFriends = [];
class ProfileAllFriendPage extends StatefulWidget {
  const ProfileAllFriendPage({super.key});

  @override
  State<ProfileAllFriendPage> createState() => _ProfileAllFriendPageState();
}

class _ProfileAllFriendPageState extends State<ProfileAllFriendPage> {
  bool loading = false;
  bool bottomSheetVisible = false;
  Friend selectedFriend = Friend();

  Future<GetFriendsResponse> GetFriends(String index) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/get_user_friends'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'index': index,
        'count': '20'
      }),
    );

    return GetFriendsResponse.fromJson(jsonDecode(response.body));
  }

  void initState() {
    listFriends.clear();
    GetFriends('0').then((value) {
      if (value.code == '1000') {
        setState(() {
          loading = true;
        });
      }
    });
    super.initState();
  }

  void refreshFriends(){
    listFriends.clear();
    loading = false;
    GetFriends('0').then((value) {
      if (value.code == '1000') {
        setState(() {
          loading = true;
        });
      }
    });
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
                    FriendContainer(friend, friendSelected)
                ],
              ),
            )
          ]
        ],
      ),
      bottomSheet: (bottomSheetVisible)
          ? Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: GestureDetector(
                  onTap: (){
                    setState(() {
                      bottomSheetVisible = false;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Text(
                      'Here',
                      style: TextStyle(
                          color: Colors.transparent
                      ),
                    ),
                  )
              )
          ),
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20)
                  )
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Avatar(selectedFriend.avatar, 50),
                        SizedBox(width: 10,),
                        Text(
                          selectedFriend.username,
                          style: TextStyle(
                              fontSize: 17.5,
                              fontWeight: FontWeight.w400
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(),
                  TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OtherAllFriendPage(selectedFriend)));
                      },
                      child: Text('Xem bạn bè', style: TextStyle(color: Colors.black),)
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfilePage(selectedFriend.id)));
                      },
                      child: Text('Xem trang cá nhân', style: TextStyle(color: Colors.black),)
                  ),
                  TextButton(
                      onPressed: () async {
                        await Block().then((value){
                          if (value == '200') {
                            setState(() {
                              //refreshFriends();
                              bottomSheetVisible = false;
                            });
                          }
                          else {
                            final scaffold = ScaffoldMessenger.of(context);
                            scaffold.showSnackBar(
                              SnackBar(
                                content: Text('Getting errors'),
                                action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
                              ),
                            );
                          }
                        });
                      },
                      child: Text('Chặn', style: TextStyle(color: Colors.black),)
                  ),
                  TextButton(
                      onPressed: () async {
                        await Unfriend().then((value){
                          if (value == '200'){
                            setState(() {
                              refreshFriends();
                              bottomSheetVisible = false;
                            });
                          }
                          else {
                            final scaffold = ScaffoldMessenger.of(context);
                            scaffold.showSnackBar(
                              SnackBar(
                                content: Text('Getting errors'),
                                action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
                              ),
                            );
                          }
                        });

                      },
                      child: Text('Hủy kết bạn', style: TextStyle(color: Colors.black))
                  ),
                ],
              )
          ),
        ],
      ) : null,
    );
  }
  void friendSelected(Friend friend){
    setState(() {
      bottomSheetVisible = true;
      selectedFriend = friend;
    });
  }

  Future Unfriend() async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/unfriend'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        "user_id": selectedFriend.id
      }),
    );

    return response.statusCode.toString();
  }

  Future Block() async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/set_block'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        "user_id": selectedFriend.id
      }),
    );

    return response.statusCode.toString();
  }
}

class FriendContainer extends StatefulWidget {
  late Friend friend;
  late Function(Friend friend) onPress;
  FriendContainer(this.friend, this.onPress, {super.key});

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
                      if (widget.friend.sameFriends != '0')
                        Text(
                          '${widget.friend.sameFriends} bạn chung',
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                          ),
                        )
                    ],
                  )
              ),
              IconButton(
                  onPressed: (){
                    widget.onPress(widget.friend);
                  },
                  icon: Icon(
                      Icons.more_horiz_rounded
                  )
              )
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
