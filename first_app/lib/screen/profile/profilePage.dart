import 'dart:convert';
import 'dart:io';
import 'package:first_app/Model/userInfo.dart';
import 'package:first_app/screen/profile/profileAllFriendPage.dart';
import 'package:first_app/screen/profile/profileEditingPage.dart';
import 'package:first_app/widget/cover.dart';
import 'package:first_app/widget/createPostContainer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/main.dart' as appMain;
import 'package:image_picker/image_picker.dart';
import '../../Model/AppImage.dart';
import '../../Model/Friend.dart';
import '../../Model/post.dart';
import '../../widget/avatar.dart';
import '../../widget/postContainer.dart';
import '../createPostPage.dart';
import '../navbar.dart' as navbar;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

UserInfo userInfo = UserInfo();
final refreshFriendCheck = ValueNotifier(true);
final refreshPostCheck = ValueNotifier<List<Post>>([]);

class ProfilePage extends StatefulWidget {
  late String id;
  ProfilePage(this.id, {super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();

  void refresh(){
    List<Post> tmp = [];
    refreshPostCheck.value = tmp;
  }
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = false;
  String bottomSheetVisible = "none";
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    refreshPostCheck.value.clear();
    scrollController.addListener(() {
      if (scrollController.position.atEdge){
        if (scrollController.position.pixels != 0)  {
          print('Here');
          GetListPosts(refreshPostCheck.value.length.toString()).then((value) {
            setState(() {});
          });
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
        'Authorization': 'Bearer ${appMain.currentUser.token}'
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
      'Authorization': 'Bearer ${appMain.currentUser.token}'
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
        appMain.currentUser.avatar = userInfo.avatar;
        navbar.menu.avatarChanged();
        navbar.newsFeedsPage.avatarChange();
        setState(() {refreshPostCheck.value = refreshPostCheck.value; loading = true;});
      }
    });
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
          if (userInfo.id != appMain.currentUser.id)...[
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
                    if (userInfo.id == appMain.currentUser.id)...[
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
                if (userInfo.id == appMain.currentUser.id)...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: (){},
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xff0064ff),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                )
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/plus.png',
                                    color: Colors.white,
                                    width: 15,
                                    height: 15,
                                  ),
                                  SizedBox(width: 10,),
                                  Text(
                                    'Thêm vào tin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ],
                              )
                            ),
                          ),
                          SizedBox(width: 5,),
                          TextButton(
                              onPressed: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditingPage(userInfo)))
                                  .then((value){
                                    refresh();
                                });
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
                  ]
                  else...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                                onPressed: (){},
                                style: TextButton.styleFrom(
                                    backgroundColor: Color(0xff0064ff),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    )
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (userInfo.isFriend == '0')...[],
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
                                    ]
                                    /*Image.asset(
                                      'assets/images/plus.png',
                                      color: Colors.white,
                                      width: 15,
                                      height: 15,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      'Thêm vào tin',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),*/
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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditingPage(userInfo)))
                                    .then((value){
                                  setState(() {
                                    loading = false;
                                  });
                                  refresh();
                                });
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
                  ]
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
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bài viết',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: ValueListenableBuilder(
                                  valueListenable: avatarUrl,
                                  builder: (context, value, child) {
                                    return Avatar(avatarUrl.value, 40);
                                  })
                          ),
                          Expanded(
                            child: Container(
                              //alignment: AlignmentDirectional.topStart,
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostPage())).then((value){
                                      if (value != 'none'){
                                        List<Post> tmp = [];
                                        refreshPostCheck.value = tmp;
                                      }
                                    });
                                  },
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Bạn đang nghĩ gì',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15
                                        ),
                                      )
                                  ),
                                )
                            ),
                          ),
                          IconButton(
                            onPressed: (){},
                            icon: Icon(
                              Icons.photo_library,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ), //Divider(height: 15, thickness: 10,)
                    ),
                  ],
                ),
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
            child: ValueListenableBuilder(
              valueListenable: refreshPostCheck,
              builder: (context, value, child) {
                return ProfilePostsContainer();
              }
            )
          )
        ],
      ),
      bottomSheet: (bottomSheetVisible != 'none')
      ? Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: (){
                setState(() {
                  bottomSheetVisible = 'none';
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
            child: bottomSheetVisible == 'Cover'
            ? Column(
              children: [
                TextButton(
                  onPressed: (){},
                  child: Text('Xem ảnh bìa', style: TextStyle(color: Colors.black),)
                ),
                TextButton(
                    onPressed: (){
                      pickImageFromGallery('cover_image');
                    },
                    child: Text('Tải ảnh lên', style: TextStyle(color: Colors.black))
                ),
                TextButton(
                    onPressed: (){},
                    child: Text('Chọn ảnh trên facebook', style: TextStyle(color: Colors.black))
                ),
                TextButton(
                    onPressed: (){},
                    child: Text('Tạo nhóm ảnh bìa', style: TextStyle(color: Colors.black))
                ),
                TextButton(
                    onPressed: (){},
                    child: Text('Chọn ảnh nghệ thuật', style: TextStyle(color: Colors.black))
                )
              ],
            )
            : Column(
              children: [
                TextButton(
                    onPressed: (){},
                    child: Text('Thêm khung', style: TextStyle(color: Colors.black),)
                ),
                TextButton(
                    onPressed: (){},
                    child: Text('Quay video đại diện mới', style: TextStyle(color: Colors.black))
                ),
                TextButton(
                    onPressed: (){},
                    child: Text('Chọn video đại diện mới', style: TextStyle(color: Colors.black))
                ),
                TextButton(
                    onPressed: (){
                      pickImageFromGallery('avatar');
                    },
                    child: Text('Chọn ảnh đại diện', style: TextStyle(color: Colors.black))
                )
              ],
            ),
          ),
        ],
      )
      : null,
    );
  }

  Future pickImageFromGallery(String field) async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage?.path != null){
      SetUserImage(field, File(returnedImage!.path)).then((value){
        if (value == '201'){
          GetUserInfo(widget.id).then((value){
            if (value.code == '1000'){
              if (field == 'avatar') {
                appMain.currentUser.avatar = userInfo.avatar;
                navbar.newsFeedsPage.avatarChange();
              }
              setState(() {bottomSheetVisible = 'none'; loading = true;});
            }
          });
        }
      });
    }
    else {
      print('No image picked');
    }
  }
}

class ProfilePostsContainer extends StatefulWidget {
  ProfilePostsContainer({super.key});

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
        setState(() {
          loading = true;
        });
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
    if (refreshPostCheck.value.length == 0){
      GetListPosts('0').then((value){
        if (value.code == '1000'){
          if (refreshPostCheck.value.length != 0){
            setState(() {});
          }
        }
      });
    }
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
      'Authorization': 'Bearer ${appMain.currentUser.token}'
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
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'index': '0',
        'count': '6'
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
                  Expanded(child: SizedBox()),
                  TextButton(
                    onPressed: (){
                      navbar.selectedIndex.value = 1;
                    },
                    child: Text(
                      'Tìm bạn bè',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500
                      ),
                    )
                  )
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
                                color: Colors.red,
                                image: DecorationImage(
                                  image: Image.network(friendList[i].avatar).image,
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
                                        image: Image.network(friendList[i].avatar).image,
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileAllFriendPage()));
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