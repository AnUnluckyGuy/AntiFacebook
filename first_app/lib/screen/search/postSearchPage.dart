import 'dart:convert';
import 'package:first_app/Model/AppVideo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Model/AppImage.dart';
import '../../Model/user.dart';
import 'package:first_app/main.dart' as appMain;

import '../../config/dateTimeConfig.dart';
import '../../widget/avatar.dart';
import '../../widget/postImageContainer.dart';
import '../../widget/videoPlayerWidget.dart';
import '../postPage.dart';
import '../profile/otherProfilePage.dart';

class PostSearchPage extends StatefulWidget {
  const PostSearchPage({super.key});

  @override
  State<PostSearchPage> createState() => _PostSearchPageState();
}

class _PostSearchPageState extends State<PostSearchPage> {
  List<SearchedPost> listSearch = [];
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
    SearchPosts(searchKeyword, listSearch.length.toString()).then((value){
      Map<String, dynamic> decodeResponse = jsonDecode(value);
      if (decodeResponse['code'] == '1000') {
        List<SearchedPost> tmp = List.from(listSearch);
        for (var res in decodeResponse['data']){
          SearchedPost post = SearchedPost();
          post.id = res['id'];
          post.name = res['name'];
          for (var image in res['image']){
            AppImage tmp = AppImage();
            tmp.id = image['id'];
            tmp.url = image['url'];
            post.images.add(tmp);
          }

          if (res['video'] != null){
            post.video..url = res['video']['url'];
          }

          post.described = res['described'];
          post.created = res['created'];
          post.feel = res['feel'];
          post.markComment = res['mark_comment'];
          post.isFelt = res['is_felt'];
          post.state = res['state'];
          post.author.id = res['author']['id'];
          post.author.username = res['author']['name'];
          post.author.avatar = res['author']['avatar'];

          tmp.add(post);
        }
        setState(() {
          listSearch = List.from(tmp);
        });
      }
    });
  }

  void refreshSearchResult(String keyword) async {
    await SearchPosts(keyword, '0').then((value){
      Map<String, dynamic> decodeResponse = jsonDecode(value);
      if (decodeResponse['code'] == '1000'){
        List<SearchedPost> tmp = [];
        for (var res in decodeResponse['data']){
          SearchedPost post = SearchedPost();
          post.id = res['id'];
          post.name = res['name'];
          for (var image in res['image']){
            AppImage tmp = AppImage();
            tmp.id = image['id'];
            tmp.url = image['url'];
            post.images.add(tmp);
          }

          if (res['video'] != null){
            post.video..url = res['video']['url'];
          }

          post.described = res['described'];
          post.created = res['created'];
          post.feel = res['feel'];
          post.markComment = res['mark_comment'];
          post.isFelt = res['is_felt'];
          post.state = res['state'];
          post.author.id = res['author']['id'];
          post.author.username = res['author']['name'];
          post.author.avatar = res['author']['avatar'];

          tmp.add(post);
        }
        setState(() {
          searchKeyword = keyword;
          listSearch = List.from(tmp);
        });
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Kiểm tra đường truyền mạng"),
        ));
      }
    });
  }

  Future SearchPosts(String keyword, String index) async{
    final response = await http.post(
        Uri.parse('https://it4788.catan.io.vn/search'),
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
        },
        body: jsonEncode(<String, String> {
          'keyword': keyword,
          'index': index,
          'count': '5'
        })
    );

    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    print('Here');
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
                    hintText: 'Nhập keyword'
                ),
                onSubmitted: (value) {
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
                for (SearchedPost post in listSearch)...[
                  PostContainer(post)
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SearchedPost {
  String id = "";
  String name = "";
  List<AppImage> images = [];
  AppVideo video = AppVideo();
  String created = "";
  String feel = "";
  String markComment = "";
  String isFelt = "";
  String state = "";
  User author = User();

  String described = "";
  String modified = "";
  String fake = "";
  String trust = "";
  String kudos = "";
  String disappointed = "";
  String isRated = "";
  String isMarked = "";
}

DateTimeConfig dtConfig = DateTimeConfig();
ValueNotifier<int> refreshCheck = ValueNotifier<int>(0);
class PostContainer extends StatefulWidget {
  late SearchedPost post;
  PostContainer(this.post, {super.key});

  @override
  State<PostContainer> createState() => _PostContainerState();
}

class _PostContainerState extends State<PostContainer> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: refreshCheck,
        builder: (context, value, child) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            padding: EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                PostHeader(widget.post),
                SizedBox(height: 20,),
                PostContent(widget.post),
                SizedBox(height: 10,),
                PostStats(widget.post)
              ],
            ),
          );
        }
    );
  }
}

class PostHeader extends StatefulWidget {
  late SearchedPost post;
  PostHeader(this.post, {super.key});

  @override
  State<PostHeader> createState() => _PostHeaderState(post);
}

class _PostHeaderState extends State<PostHeader> {
  late SearchedPost post;
  _PostHeaderState(this.post);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        print('Header tap');
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostPage(post.id))).then((value){
          refreshCheck.value = value;
          post.feel = value.toString();
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              GestureDetector(
                  onTap: (){
                    if (post.author.id != appMain.cache.currentUser.id){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfilePage(post.author.id)));
                    }
                    print('Avatar tap');
                  },
                  child: Avatar(post.author.avatar, 40)
              ),
              SizedBox(width: 15,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: (){
                      if (post.author.id != appMain.cache.currentUser.id){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfilePage(post.author.id)));
                      }
                      print('Name tap');
                    },
                    child: Text(
                      post.author.username,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  SizedBox(height: 2.5,),
                  Container(
                    child: Row(
                      children: [
                        Text(
                          dtConfig.showDateTimeDiff(post.created),
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey
                          ),
                        ),
                        SizedBox(width: 10,),
                        Image.asset(
                          'assets/images/globe.png',
                          color: Colors.grey,
                          width: 12.5,
                          height: 12.5,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostContent extends StatelessWidget {
  late SearchedPost post;

  PostContent(this.post);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.red,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.described.trim().isNotEmpty)...[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(post.described)
            ),
            SizedBox(height: 5,)
          ],
          if (post.images.isNotEmpty)
            PostImage(post.images),
          if (post.video.url.isNotEmpty)
            Center(child: VideoPlayerWidget(post.video.url)),
        ],
      ),
    );
  }
}


class PostImage extends StatefulWidget {
  late List<AppImage> images;
  PostImage(this.images, {super.key});

  @override
  State<PostImage> createState() => _PostImageState(this.images);
}

class _PostImageState extends State<PostImage> {
  late List<AppImage> images;
  double d = 5;
  _PostImageState(this.images);

  @override
  Widget build(BuildContext context) {
    if (images.length == 1){
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: PostImageContainer(
              MediaQuery.sizeOf(context).width,
              MediaQuery.sizeOf(context).width,
              images[0].url
          )
      );
    }
    else if (images.length == 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            PostImageContainer(
              MediaQuery.sizeOf(context).width,
              (MediaQuery.sizeOf(context).width - d) / 2,
              images[0].url,
            ),
            SizedBox(width: d,),
            PostImageContainer(
              MediaQuery.sizeOf(context).width,
              (MediaQuery.sizeOf(context).width - d) / 2,
              images[1].url,
            ),
          ],
        ),
      );
    }
    else if (images.length == 3){
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            PostImageContainer(
              MediaQuery.sizeOf(context).width,
              (MediaQuery.sizeOf(context).width - d) / 2,
              images[0].url,
            ),
            SizedBox(width: d,),
            Column(
              children: [
                PostImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  images[1].url,
                ),
                SizedBox(height: d,),
                PostImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  images[2].url,
                ),
              ],
            )
          ],
        ),
      );
    }
    else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Column(
              children: [
                PostImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  images[0].url,
                ),
                SizedBox(height: d,),
                PostImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  images[1].url,
                ),
              ],
            ),
            SizedBox(width: d,),
            Column(
              children: [
                PostImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d)/ 2,
                  images[2].url,
                ),
                SizedBox(height: d,),
                PostImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d)/ 2,
                  images[3].url,
                ),
              ],
            )
          ],
        ),
      );
    }
  }
}


class PostStats extends StatefulWidget {
  late SearchedPost post;
  PostStats(this.post, {super.key});

  @override
  State<PostStats> createState() => _PostStatsState(post);
}


class _PostStatsState extends State<PostStats> {
  late SearchedPost post;
  _PostStatsState(this.post);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                child: Row(
                    children: [
                      Image.asset(
                        'assets/images/likerounded.png',
                        color: Colors.blue,
                        width: 20,
                        height: 20,
                      ),
                      Image.asset(
                        'assets/images/dislikerounded.png',
                        color: Colors.red,
                        width: 20,
                        height: 20,
                      ),
                    ]
                ),
              ),
              SizedBox(width: 5,),
              Text(
                post.feel,
                style: TextStyle(
                    color: Colors.grey[700]
                ),
              ),
              Expanded(child: Container()),
              Text(
                post.markComment,
                style: TextStyle(
                    color: Colors.grey[700]
                ),
              ),
              SizedBox(width: 5,),
              Text(
                'Bình luận',
                style: TextStyle(
                    color: Colors.grey[700]
                ),
              )
            ],
          ),
          Divider(),
          Row(
            children: [
              _PostButton(
                image: Image.asset(
                  'assets/images/like.png',
                  width: 20,
                  height: 20,
                  color: Colors.grey,
                ),
                label: 'Thích',
                onTap: () {},
                onLongPress: (){},
              ),
              _PostButton(
                image: Image.asset(
                  'assets/images/comment.png',
                  width: 20,
                  height: 20,
                  color: Colors.grey,
                ),
                label: 'Bình luận',
                onTap: () => {print('Comment')},
                onLongPress: (){},
              ),
              _PostButton(
                image: Image.asset(
                  'assets/images/share.png',
                  width: 20,
                  height: 20,
                  color: Colors.grey,
                ),
                label: 'Chia sẻ',
                onTap: () => {print('Share')},
                onLongPress: (){},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostButton extends StatelessWidget {
  final Image image;
  final String label;
  final void Function() onTap;
  final void Function() onLongPress;

  const _PostButton({super.key, required this.image, required this.label, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onLongPress: onLongPress,
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                image,
                const SizedBox(width: 10,),
                Text(label)
              ],
            ),
          ),
        ),
      ),
    );
  }
}



