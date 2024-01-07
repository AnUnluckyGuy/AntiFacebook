import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Model/friendRequest.dart';
import '../../Model/suggestedFriend.dart';
import '../../widget/avatar.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/main.dart' as appMain;

List<SuggestedFriend> listSuggestedFriends = [];
class SuggestedFriendPage extends StatefulWidget {
  const SuggestedFriendPage({super.key});

  @override
  State<SuggestedFriendPage> createState() => _SuggestedFriendPageState();
}

class _SuggestedFriendPageState extends State<SuggestedFriendPage> {
  bool loading = false;

  @override
  void initState() {
    listSuggestedFriends.clear();
    if (appMain.cache.suggestedFriend.isNotEmpty){
      setState(() {
        appMain.cache.suggestedFriend.forEach((element) {
          listSuggestedFriends.add(element);
        });
        loading = true;
      });
    }
    else {
      GetSuggestedFriends('0').then((value) {
        if (value.code == '1000') {
          setState(() {
            loading = true;
          });
        }
      });
    }
    super.initState();
  }

  Future<GetSuggestedFriendsResponse> GetSuggestedFriends(String index) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/get_suggested_friends'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'index': index,
        'count': "30",
      }),
    );

     return GetSuggestedFriendsResponse.fromJson(jsonDecode(response.body));
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
              onPressed: (){
                appMain.cache.saveSuggestedFriend(listSuggestedFriends);
                Navigator.pop(context);
              },
              icon: Image.asset(
                'assets/images/backarrow.png',
                width: 25,
                height: 25,
              ),
            ),
            title: Text(
              'Gợi ý',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20
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
                side: BorderSide(
                    width: 0.1
                )
            ),
          ),
          if (!loading)
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
          if (loading)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text(
                          'Những người bạn có thể biết',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < listSuggestedFriends.length; ++i)...[
                    FriendContainer(i, listSuggestedFriends[i].friendReq, listSuggestedFriends[i].addFriend)
                  ]
                ],
              ),
            )
        ],
      ),
    );
  }
}

class FriendContainer extends StatefulWidget {
  late int id;
  late FriendRequest req;
  late bool addFriend;

  FriendContainer(this.id, this.req, this.addFriend, {super.key});

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
              Avatar(widget.req.avatar, constraints.maxWidth / 5),
              SizedBox(width: 10,),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.req.userName,
                        style: TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(height: 2.5),
                      if (widget.req.sameFriends != '0')
                        Text(
                          '${widget.req.sameFriends} bạn chung',
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      SizedBox(height: 2.5),
                      if (widget.addFriend)...[
                        Container(
                          width: constraints.maxWidth,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                    onPressed: () async {
                                      await DelAddFriend(widget.req.id).then((value){
                                        if (value == '200'){
                                          setState(() {
                                            widget.addFriend = false;
                                            listSuggestedFriends[widget.id].addFriend = false;
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
                                    child: Text(
                                      'Hủy yêu cầu',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                        backgroundColor: Color(0xff0064ff),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                        )
                                    )
                                ),
                              ),
                            ],
                          ),
                        )
                      ]
                      else...[
                        Container(
                          width: constraints.maxWidth,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () async {
                                    await AddFriend(widget.req.id).then((value){
                                      if (value == '200'){
                                        setState(() {
                                          widget.addFriend = true;
                                          listSuggestedFriends[widget.id].addFriend = true;
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
                                  child: Text(
                                    'Thêm bạn bè',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                      backgroundColor: Color(0xff0064ff),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)
                                      )
                                  )
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: TextButton(
                                    onPressed: (){},
                                    child: Text(
                                      'Gỡ',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.grey[300],
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                        )
                                    )
                                ),
                              ),
                            ],
                          ),
                        )
                      ]
                    ],
                  )
              ),
            ],
          );
        }),
      ),
    );
  }

  Future AddFriend(String id) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/set_request_friend'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        "user_id": id
      }),
    );

    return response.statusCode.toString();
  }

  Future DelAddFriend(String id) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/del_request_friend'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        "user_id": id
      }),
    );

    return response.statusCode.toString();
  }
}

class GetSuggestedFriendsResponse {
  late String code;
  late String message;

  GetSuggestedFriendsResponse({required this.code, required this.message});

  factory GetSuggestedFriendsResponse.fromJson(Map<String, dynamic> json) {
    if (json['code'] == '1000') {
      for (var request in json['data']) {
        FriendRequest req = FriendRequest();
        req.id = request['id'];
        req.userName = request['username'];
        req.avatar = request['avatar'];
        req.sameFriends = request['same_friends'];
        req.created = request['created'];
        SuggestedFriend sugFriend = SuggestedFriend();
        sugFriend.friendReq = req;
        sugFriend.addFriend = false;
        listSuggestedFriends.add(sugFriend);
      }
    }
    return GetSuggestedFriendsResponse(code: json['code'], message: json['message']);
  }
}

