import 'dart:convert';
import 'package:first_app/Model/friendRequest.dart';
import 'package:first_app/screen/friend/allFriendPage.dart';
import 'package:first_app/screen/friend/suggestedFriendsPage.dart';
import 'package:first_app/screen/search/friendSearchPage.dart';
import 'package:flutter/material.dart';
import 'package:first_app/main.dart' as appMain;
import 'package:http/http.dart' as http;
import  '../../config/dateTimeConfig.dart';
import '../../widget/avatar.dart';

List<FriendRequest> listFriendRequest = [];
bool loading = false;
DateTimeConfig dtConfig = DateTimeConfig();
class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  @override
  void initState() {
    super.initState();
    GetRequestedFriends('0').then((value) {
      loading = true;
      setState(() {});
    });
  }

  Future<void> GetRequestedFriends(String index) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/get_requested_friends'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'index': index,
        'count': "20",
      }),
    );

    if (response.statusCode == 200){
      GetRequestedFriendsResponse.fromJson(jsonDecode(response.body));
    }
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
            title: Text(
              'Bạn bè',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25.5,
                fontWeight: FontWeight.w500,
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
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FriendSearchPage()));
                  },
                  icon: Icon(Icons.search, size: 25,),
                  color: Colors.black,
                ),
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SuggestedFriendPage()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        'Gợi ý',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      alignment: Alignment.center,
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                      )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AllFriendPage()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        'Bạn bè',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    style: TextButton.styleFrom(
                        alignment: Alignment.center,
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)
                        )
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Divider(
                color: Colors.grey[300],
                thickness: 0.5,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                FriendRequestHeader(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class FriendRequestHeader extends StatefulWidget {
  const FriendRequestHeader({super.key});

  @override
  State<FriendRequestHeader> createState() => _FriendRequestHeaderState();
}

class _FriendRequestHeaderState extends State<FriendRequestHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: !loading ? CircularProgressIndicator() :
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Lời mời kết bạn',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ),
            for (FriendRequest req in listFriendRequest)
              FriendRequestContainer(req)
          ]
        ),
    );
  }
}

class FriendRequestContainer extends StatefulWidget {
  late FriendRequest req;
  FriendRequestContainer(this.req, {super.key});

  @override
  State<FriendRequestContainer> createState() => _FriendRequestContainerState();
}

class _FriendRequestContainerState extends State<FriendRequestContainer> {
  String check = "none";

  Future<SetAcceptedFriendsResponse> SetAcceptedFriend(String userId, String accepted) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/set_accept_friend'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'user_id': userId,
        'is_accept': accepted
      }),
    );

    return SetAcceptedFriendsResponse.fromJson(jsonDecode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        //color: Colors.red,
        width: MediaQuery.sizeOf(context).width,
        child: LayoutBuilder(builder: (context, constraints) {
          return Row(
            children: [
              Avatar(widget.req.avatar, constraints.maxWidth / 5),
              SizedBox(width: 10,),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: [
                            Text(
                              widget.req.userName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15
                              ),
                            ),
                            Expanded(child: Container()),
                            Text(
                              dtConfig.showDateTimeDiff(widget.req.created),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                                fontSize: 15
                              ),
                            )
                          ],
                        ),
                      ),
                      if (widget.req.sameFriends != '0')
                        Text(
                          '${widget.req.sameFriends} bạn chung',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      if (check == 'none')
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () async {
                                    bool result = false;
                                    await CustomDialog.showConfirmationDialog(context, widget.req, 'Chấp nhận lời mời kết bạn', onChanged: (value){
                                      result = value;
                                    });
                                    if (result) {
                                      SetAcceptedFriendsResponse responseData = await SetAcceptedFriend(widget.req.id, "1");
                                      if (responseData.code == '1000')
                                        setState((){check = "accepted";});
                                      else print('Error');
                                    }
                                  },
                                  child: Text(
                                    'Xác nhận',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                      backgroundColor: Color(0xff0064ff),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)
                                      )
                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: TextButton(
                                  onPressed: () async{
                                    bool result = false;
                                    await CustomDialog.showConfirmationDialog(context, widget.req, 'Gỡ lời mời kết bạn', onChanged: (value){
                                      result = value;
                                    });
                                    if (result) {
                                      SetAcceptedFriendsResponse responseData = await SetAcceptedFriend(widget.req.id, "0");
                                      if (responseData.code == '1000')
                                        setState((){check = "reject";});
                                      else print('Error');
                                    }
                                  },
                                  child: Text(
                                    'Xóa',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                    )
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      if (check != 'none')
                        Container(
                          child: check == 'accepted'
                            ? Text('Đã chấp nhận lời mời')
                            : Text('Đã gỡ lời mời')
                        )
                    ],
                  ),
                ),
              )
            ],
          );
        })
      ),
    );
  }
}

class GetRequestedFriendsResponse {
  late String code;
  late String message;

  GetRequestedFriendsResponse({required this.code, required this.message});

  factory GetRequestedFriendsResponse.fromJson(Map<String, dynamic> json) {
    if (json['code'] == '1000') {
      for (var request in json['data']['requests']) {
        FriendRequest req = FriendRequest();
        req.id = request['id'];
        req.userName = request['username'];
        req.avatar = request['avatar'];
        req.sameFriends = request['same_friends'];
        req.created = request['created'];

        listFriendRequest.add(req);
      }
    }
    return GetRequestedFriendsResponse(code: json['code'], message: json['message']);
  }
}

class SetAcceptedFriendsResponse {
  late String code;
  late String message;

  SetAcceptedFriendsResponse({required this.code, required this.message});

  factory SetAcceptedFriendsResponse.fromJson(Map<String, dynamic> json) {
    return SetAcceptedFriendsResponse(code: json['code'], message: json['message']);
  }
}

class CustomDialog{
  static showConfirmationDialog(BuildContext context, FriendRequest req, String title,
      {required ValueChanged onChanged}) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                width: MediaQuery
                    .sizeOf(context)
                    .width / 2,
                height: MediaQuery
                    .sizeOf(context)
                    .height / 2,
                child: LayoutBuilder(builder: (context, constraint) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Avatar(req.avatar, constraint.maxWidth / 2),
                        Text(
                          req.userName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    onChanged(true);
                                  },
                                  child: Text(
                                    'Xác nhận',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                      backgroundColor: Color(0xff0064ff),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10)
                                      )
                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Hủy',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10)
                                      )
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ]
                  );
                })
            ),
          );
        }
    );
  }

}

