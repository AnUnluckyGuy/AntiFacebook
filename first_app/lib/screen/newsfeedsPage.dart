import 'dart:convert';
import 'package:first_app/Model/AppImage.dart';
import 'package:first_app/screen/reportPage.dart';
import 'package:first_app/screen/search/postSearchPage.dart';
import 'package:first_app/widget/postContainer.dart' as pc;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Model/post.dart';
import 'package:first_app/main.dart' as appMain;
import 'navbar.dart' as navbar;
import '../widget/avatar.dart';
import 'createPostPage.dart';

//List<Post> listPosts = [];
ValueNotifier<List<Post>> listPosts = ValueNotifier<List<Post>>([]);

class NewsFeedsPage extends StatefulWidget {
  CreatePostContainer createPostContainer = CreatePostContainer();

  @override
  State<NewsFeedsPage> createState() => _NewsFeedsPageState();

  void avatarChange(){
    createPostContainer.avatarChange();
  }
  
  void refresh(){
    List<Post> tmp = [];
    listPosts.value = tmp;
  }
}

class _NewsFeedsPageState extends State<NewsFeedsPage> {
  ScrollController scrollController = ScrollController();

  bool loading = true;
  @override
  void initState() {
    listPosts.value.clear();
    scrollController.addListener(() {
      if (scrollController.position.atEdge){
        if (scrollController.position.pixels != 0) {
          addPost();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  void addPost(){
    GetListPosts(listPosts.value.length.toString()).then((value){
      if (value.code == '1000'){
        setState(() {});
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
      backgroundColor: Colors.grey[300],
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Anti Facebook',
              style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.2
              ),
            ),
            centerTitle: false,
            floating: true,
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PostSearchPage()));
                  },
                  icon: Icon(Icons.search, size: 25,),
                  color: Colors.black,
                ),
              )
            ],
          ),
          SliverToBoxAdapter(
            child: widget.createPostContainer
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
              child: ValueListenableBuilder(
                valueListenable: listPosts,
                builder: (context, value, child) {
                  return ListPostContainer();
                }
              ),
            )
        ],
      ),
    );
  }

}

Future DelPost(String id) async{
  final response = await http.post(
    Uri.parse('https://it4788.catan.io.vn/delete_post'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${appMain.currentUser.token}'
    },
    body: jsonEncode(<String, String>{
      "id": id
    }),
  );

  Map<String, dynamic> decodeResponse = jsonDecode(response.body);
  if (decodeResponse['code'] == '1000'){
    appMain.currentUser.coins = int.parse(decodeResponse['data']['coins']);
    navbar.menu.coinsChanged();
  }
  return response.statusCode.toString();
}

class ListPostContainer extends StatefulWidget {
  const ListPostContainer({super.key});

  @override
  State<ListPostContainer> createState() => _ListPostContainerState();
}

class _ListPostContainerState extends State<ListPostContainer> {
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
    if (listPosts.value.length == 0){
      GetListPosts('0').then((value){
        if (value.code == '1000') {
          setState(() {});
        }
      });

    }
    return Column(
      children: [
        for (Post post in listPosts.value)
          pc.PostContainer(post, _showBottomSheet)
      ],
    );
  }

  void _showBottomSheet(Post post) async {
    if (post.author.id == appMain.currentUser.id){
      await showDialog(
          context: context,
          builder: (context){
            return Dialog(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/notificationbell.png',
                                width: 30,
                                height: 30,
                              ),
                              SizedBox(width: 5,),
                              Text(
                                'Tắt thông báo về bài viết này',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                            ],
                          )
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/saved1.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 5,),
                            Text(
                              'Lưu bài viết',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context, 'delete');
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/bin.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 5,),
                            Text(
                              'Xóa',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context, 'edit');
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/editpen.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 5,),
                            Text(
                              'Chỉnh sửa bài viết',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/link.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 5,),
                            Text(
                              'Sao chép liên kết',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
      ).then((value) async {
        if (value != null){
          if (value == 'delete'){
            await DelPost(post.id).then((value){
              if (value == '200'){
                List<Post> tmp = [];
                listPosts.value = tmp;
                navbar.profilePage.refresh();
              }
              else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Không thể xóa bài viết"),
                ));
              }
            });
          }
          else {
            //await Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostPage(post)));
          }
        }
      });
    }
    else {
      await showDialog(
          context: context,
          builder: (context){
            return Dialog(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/saved1.png',
                                width: 30,
                                height: 30,
                              ),
                              SizedBox(width: 5,),
                              Text(
                                'Lưu bài viết',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                            ],
                          )
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context, 'report');
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/cancel.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 5,),
                            Text(
                              'Báo cáo bài viết',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/notificationbell.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 5,),
                            Text(
                              'Bâ thông báo về bài viết này',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/link.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 5,),
                            Text(
                              'Sao chép liên kết',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
      ).then((value) async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => ReportPage(post)));
      });
    }
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
      'index': index,
      'count': "10",
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
      List<Post> tmp = [...listPosts.value];
      for(var post in json['data']['post']){
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

        tmp.add(_post);
      }
      listPosts.value = tmp;
      return GetListPostsResponse(code: json['code'], message: json['message']);
    }
    else {
      return GetListPostsResponse(code: json['code'], message: json['message']);
    }
  }
}

final avatarUrl = ValueNotifier(appMain.currentUser.avatar);

class CreatePostContainer extends StatefulWidget {

  @override
  State<CreatePostContainer> createState() => _CreatePostContainerState();

  void avatarChange(){
    avatarUrl.value = appMain.currentUser.avatar;
  }
}

class _CreatePostContainerState extends State<CreatePostContainer> {

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostPage())).then((value){
                      if (value != 'none'){
                        List<Post> tmp = [];
                        listPosts.value = tmp;
                        navbar.profilePage.refresh();
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
    );
  }
}


