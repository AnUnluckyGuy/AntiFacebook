import 'dart:convert';
import 'dart:io';
import 'package:first_app/Model/userInfo.dart';
import 'package:first_app/screen/profile/OtherAllFriendPage.dart';
import 'package:first_app/screen/profile/otherProfileEditPage.dart';
import 'package:first_app/widget/cover.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/main.dart' as appMain;
import '../../Model/AppImage.dart';
import '../../Model/Friend.dart';
import '../../Model/post.dart';
import '../../widget/avatar.dart';
import '../../widget/postContainer.dart';
import '../navbar.dart' as navbar;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

UserInfo userInfo = UserInfo();
final refreshFriendCheck = ValueNotifier(true);
final refreshPostCheck = ValueNotifier<List<Post>>([]);

class OtherProfilePage extends StatefulWidget {
  late String id;
  OtherProfilePage(this.id, {super.key});

  @override
  State<OtherProfilePage> createState() => _OtherProfilePageState();

  void refresh(){
    refreshFriendCheck.value = !refreshFriendCheck.value;
  }
}

class _OtherProfilePageState extends State<OtherProfilePage> {
  bool loading = false;
  String bottomSheetVisible = "none";
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    refreshPostCheck.value.clear();
    scrollController.addListener(() async {
      if (scrollController.position.atEdge){
        if (scrollController.position.pixels != 0)  {
          print('Here');
          await GetListPosts(refreshPostCheck.value.length.toString()).then((value) {});
        }
      }
    });
    GetUserInfo(widget.id).then((value){
      if (value.code == '1000'){
        setState(() {loading = true;});
      }
    });
    super.initState();
  }

  Future<UserInfoResponse> GetUserInfo(String id) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/get_user_info'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        "user_id": id
      }),
    );

    return UserInfoResponse.fromJson(jsonDecode(response.body));
  }

  Future<String> SetUserImage(String changeField, File image) async {
    var req = http.MultipartRequest('POST', Uri.parse('https://it4788.catan.io.vn/set_user_info'));
    req.headers.addAll({
      //'Content-Type': 'multipart/form-data; charset=UTF-8',
      'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
    });
    req.files.add(http.MultipartFile.fromBytes(
        changeField,
        image.readAsBytesSync(),
        filename: basename(image.path),
        contentType: MediaType('image', 'jpg')
    )
    );
    final response = await req.send();
    return response.statusCode.toString();
  }

  void refresh(){
    GetUserInfo(widget.id).then((value){
      if (value.code == '1000'){
        setState(() {loading = true;});
        appMain.cache.currentUser.avatar = userInfo.avatar;
        navbar.menu.avatarChanged();
        navbar.newsFeedsPage.avatarChange();
      }
    });
  }

  Future AddFriend(String id) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/set_request_friend'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        "user_id": id
      }),
    );

    return response.statusCode.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (loading == false){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          if (userInfo.id != appMain.cache.currentUser.id)...[
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
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
            )
          ],
          SliverToBoxAdapter(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Cover(userInfo.coverImage, MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height / 4.5),
                      Padding(
                        padding: EdgeInsets.only(top: (MediaQuery.sizeOf(context).height / 9)),
                        child: Avatar(userInfo.avatar, MediaQuery.sizeOf(context).width / 2.5, online: userInfo.online,),
                      ),
                      if (userInfo.id == appMain.cache.currentUser.id)...[
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.sizeOf(context).width / 1.5,
                              MediaQuery.sizeOf(context).height / 7,
                              0 ,0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width / 10,
                            height: MediaQuery.sizeOf(context).width / 10,
                            margin: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color:Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: (){
                                setState(() {bottomSheetVisible = 'Cover';});
                              },
                              icon: Image.asset(
                                'assets/images/photo_camera.png',
                              ),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height / 9 + MediaQuery.sizeOf(context).width / 3)  ,
                          child: Container(
                            width: MediaQuery.sizeOf(context).width / 10,
                            height: MediaQuery.sizeOf(context).width / 10,
                            margin: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color:Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: (){
                                setState(() {bottomSheetVisible = 'Avatar';});
                              },
                              icon: Image.asset(
                                'assets/images/photo_camera.png',
                              ),
                              color: Colors.black,
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      child: Text(
                        userInfo.username,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                              onPressed: (){
                                if (userInfo.isFriend == '0'){
                                  AddFriend(userInfo.id).then((value){
                                    if (value == '200'){
                                      setState(() {
                                        userInfo.isFriend = '2';
                                      });
                                    }
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: Color(0xff0064ff),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  )
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (userInfo.isFriend == '0')...[
                                    Image.asset(
                                      'assets/images/addfriend.png',
                                      color: Colors.white,
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      'Thêm bạn bè',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                  if (userInfo.isFriend == '1')...[
                                    Image.asset(
                                      'assets/images/isfriend.png',
                                      color: Colors.white,
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      'Bạn bè',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                  if (userInfo.isFriend == '2')...[
                                    Image.asset(
                                      'assets/images/addfriend.png',
                                      color: Colors.white,
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      'Đã gửi lời mời',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                  if (userInfo.isFriend == '3')...[
                                    Image.asset(
                                      'assets/images/isfriend.png',
                                      color: Colors.white,
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      'Trả lời',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ],
                              )
                          ),
                        ),
                        SizedBox(width: 5,),
                        TextButton(
                            onPressed: (){},
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                )
                            ),
                            child: Image.asset(
                              'assets/images/messenger.png',
                              width: 20,
                              height: 20,
                            )
                        ),
                        SizedBox(width: 5,),
                        TextButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfileEditPage(userInfo.id)));
                          },
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              )
                          ),
                          child: Text(
                            '...',
                            style: TextStyle(
                                fontSize: 17.5,
                                color: Colors.black
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                ],
              )
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 1,
              color: Colors.grey[300],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/home.png',
                    width: 30,
                    height: 30,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 15,),
                  RichText(
                    text: TextSpan(
                        text: 'Sống tại ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w400
                        ),
                        children: [
                          TextSpan(
                              text: userInfo.city,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              )
                          )
                        ]
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 1,
              color: Colors.grey[300],
            ),
          ),
          SliverToBoxAdapter(
            child: FriendsContainer(),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 10,
              color: Colors.grey[300],
            ),
          ),
          SliverToBoxAdapter(
              child: ValueListenableBuilder(
                  valueListenable: refreshPostCheck,
                  builder: (context, value, child) {
                    return ProfilePostsContainer();
                  }
              )
          )
        ],
      ),
    );
  }
}

class ProfilePostsContainer extends StatefulWidget {
  const ProfilePostsContainer({super.key});

  @override
  State<ProfilePostsContainer> createState() => _ProfilePostsContainerState();
}

class _ProfilePostsContainerState extends State<ProfilePostsContainer> {
  bool loading = false;


  @override
  void initState() {
    super.initState();
    GetListPosts('0').then((value) {
      if (value.code == '1000')
        setState(() {loading = true;});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loading)
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            )
        ),
      );

    return Column(
      children: [
        for (Post post in refreshPostCheck.value)
          PostContainer(post, _showBottomSheet)
      ],
    );
  }

  void _showBottomSheet(Post post){
    /*if (post.author.id == appMain.currentUser.id){
      showBottomSheet(
          context: context,
          builder: (context){
            return Container(
              color: Colors.white,
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height / 2,
              child: Column(
                children: [
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context, 'Tắt thông báo');
                      },
                      child: Row(
                        children: [
                          Image.asset('assets/images/notificationbell.png'),
                          SizedBox(width: 5,),
                          Text(
                              'Tắt thông báo về bài viết này'
                          )
                        ],
                      )
                  )
                ],
              ),
            );
          }
      ).closed.then((value){
        print(value);
      });
    }
    else {

    }*/
  }
}

Future<GetListPostsResponse> GetListPosts(String index) async {
  final response = await http.post(
    Uri.parse('https://it4788.catan.io.vn/get_list_posts'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
    },
    body: jsonEncode(<String, String>{
      'user_id': userInfo.id,
      'index': index,
      'count': "5",
    }),
  );

  if (response.statusCode == 200){
    return GetListPostsResponse.fromJson(jsonDecode(response.body));
  }
  else if (response.statusCode == 403){
    return GetListPostsResponse.fromJson(jsonDecode(response.body));
  }
  else{
    throw Exception('Error');
  }
}

class GetListPostsResponse {
  late String code;
  late String message;

  GetListPostsResponse({required this.code, required this.message});

  factory GetListPostsResponse.fromJson(Map<String, dynamic> json) {
    if (json['code'] == '1000') {
      List<Post> lp = [...refreshPostCheck.value];
      for(var post in json['data']['post']){
        //print(post);
        Post _post = Post();
        _post.id = post['id'];
        _post.name = post['name'];
        _post.created = post['created'];
        _post.described = post['described'];
        _post.feel = post['feel'];
        _post.commentMark = post['comment_mark'];
        _post.isMarked = post['is_felt'];
        _post.isBlocked = post['is_blocked'];
        _post.canEdit = post['can_edit'];
        _post.banned = post['banned'];
        _post.state = post['state'];
        _post.author.username = post['author']['name'];
        _post.author.id = post['author']['id'];
        _post.author.avatar = post['author']['avatar'];
        if (post['image'] != null){
          for (var image in post['image']){
            AppImage _image = AppImage();
            _image.id = image['id'];
            _image.url = image['url'];
            _post.images.add(_image);
          }
        }
        if (post['video'] != null){
          _post.video.url = post['video']['url'];
        }

        lp.add(_post);
      }
      refreshPostCheck.value = lp;
      return GetListPostsResponse(code: json['code'], message: json['message']);
    }
    else {
      return GetListPostsResponse(code: json['code'], message: json['message']);
    }
  }
}

class FriendsContainer extends StatefulWidget {
  const FriendsContainer({super.key});

  @override
  State<FriendsContainer> createState() => _FriendsContainerState();
}

class _FriendsContainerState extends State<FriendsContainer> {
  bool loading = true;
  List<Friend> friendList = [];

  Future GetFriends() async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/get_user_friends'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'index': '0',
        'count': '6',
        'user_id': userInfo.id
      }),
    );

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);
    if (decodeResponse['code'] == '1000'){
      for (var request in decodeResponse['data']['friends']) {
        Friend friend = Friend();
        friend.id = request['id'];
        friend.username = request['username'];
        friend.avatar = request['avatar'];
        friend.sameFriends = request['same_friends'];
        friend.created = request['created'];

        friendList.add(friend);
      }
    }
    return response.statusCode.toString();
  }

  @override
  void initState() {
    GetFriends().then((value){
      if (value == '200'){
        setState(() {
          loading = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Container(child: CircularProgressIndicator(),);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Bạn bè',
                  style: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
            if (userInfo.listing != '0') ...[
              Text(
                '${userInfo.listing} bạn bè',
                style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w500
                ),
              ),
              SizedBox(height: 10,)
            ],
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < 3; ++i)...[
                    if (i < friendList.length)
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.sizeOf(context).width / 3.5,
                              height: MediaQuery.sizeOf(context).width / 3.5,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  image: DecorationImage(
                                      image: friendList[i].avatar.isNotEmpty
                                          ? Image.network(friendList[i].avatar).image
                                          : Image.asset('assets/images/user.png').image
                                      ,
                                      fit: BoxFit.cover
                                  )
                              ),
                            ),
                            Text(
                              friendList[i].username,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      )
                  ]
                ]
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 3; i < 6; ++i)...[
                    if (i < friendList.length)
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.sizeOf(context).width / 3.5,
                              height: MediaQuery.sizeOf(context).width / 3.5,
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  image: DecorationImage(
                                      image: friendList[i].avatar.isNotEmpty
                                          ? Image.network(friendList[i].avatar).image
                                          : Image.asset('assets/images/user.png').image
                                      ,
                                      fit: BoxFit.cover
                                  )
                              ),
                            ),
                            Text(
                              friendList[i].username,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      )
                  ]
                ]
            ),
            SizedBox(height: 10,),
            Container(
              width: double.infinity,
              child: TextButton(
                onPressed: (){
                  Friend user = Friend();
                  user.id = userInfo.id;
                  user.username = userInfo.username;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OtherAllFriendPage(user)));
                },
                child: Text(
                  'Xem tất cả bạn bè',
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
                style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[300]
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


class UserInfoResponse {
  late String code;
  late String message;

  UserInfoResponse({required this.code, required this.message});

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    if (json['code'] == '1000') {
      userInfo.id = json['data']['id'];
      userInfo.username = json['data']['username'];
      userInfo.created = json['data']['created'];
      userInfo.description = json['data']['description'];
      userInfo.avatar = json['data']['avatar'];
      userInfo.coverImage = json['data']['cover_image'];
      userInfo.link = json['data']['link'];
      userInfo.address = json['data']['address'];
      userInfo.city = json['data']['city'];
      userInfo.country = json['data']['country'];
      userInfo.listing = json['data']['listing'];
      userInfo.isFriend = json['data']['is_friend'];
      userInfo.online = json['data']['online'];
      userInfo.coins = json['data']['coins'];
    }
    return UserInfoResponse(code: json['code'], message: json['message']);
  }
}

class SetUserInfoResponse {
  late String code;
  late String message;

  SetUserInfoResponse({required this.code, required this.message});

  factory SetUserInfoResponse.fromJson(Map<String, dynamic> json) {
    return SetUserInfoResponse(code: json['code'], message: json['message']);
  }
}