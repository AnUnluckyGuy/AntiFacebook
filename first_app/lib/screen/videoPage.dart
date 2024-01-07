import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:first_app/screen/postPage.dart';
import 'package:first_app/screen/profile/otherProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:first_app/main.dart' as appMain;
import '../Model/AppImage.dart';
import '../Model/post.dart';
import '../config/dateTimeConfig.dart';
import '../widget/avatar.dart';
import '../widget/postImageContainer.dart';
import '../widget/videoPlayerWidget.dart';

ValueNotifier<List<Post>> listPosts = ValueNotifier<List<Post>>([]);

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  bool loading = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    listPosts.value.clear();
    scrollController.addListener(() {
      if (scrollController.position.atEdge){
        if (scrollController.position.pixels != 0) {
          addVideo();
        }
      }
    });
    super.initState();
    GetListVideos('0').then((value) {
      if (value.code == '1000')
        setState(() {loading = true;});
    });
    super.initState();
  }

  void addVideo(){
    GetListVideos(listPosts.value.length.toString()).then((value){
      if (value.code == '1000'){
        //setState(() {});
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
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Watch',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
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
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 10,
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
              child: ValueListenableBuilder(
                  valueListenable: listPosts,
                  builder: (context, value, child) {
                    return Column(
                      //children: postsWidget
                      children: [
                        for (Post post in listPosts.value)...[
                          PostContainer(post),
                          Divider(thickness: 10,)
                        ]
                      ],
                    );
                  }
              ),
            )
        ],
      ),
    );
  }
}

Future<GetListPostsResponse> GetListVideos(String index) async {
  final response = await http.post(
    Uri.parse('https://it4788.catan.io.vn/get_list_videos'),
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

        tmp.add(_post);
      }
      print(tmp);
      listPosts.value = tmp;
      return GetListPostsResponse(code: json['code'], message: json['message']);
    }
    else {
      return GetListPostsResponse(code: json['code'], message: json['message']);
    }
  }
}

DateTimeConfig dtConfig = DateTimeConfig();
ValueNotifier<int> refreshCheck = ValueNotifier<int>(0);
class PostContainer extends StatefulWidget {
  late Post post;
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
  late Post post;
  PostHeader(this.post,{super.key});

  @override
  State<PostHeader> createState() => _PostHeaderState(post);
}

class _PostHeaderState extends State<PostHeader> {
  late Post post;
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
                    if (post.author.id != appMain.currentUser.id){
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
                      if (post.author.id != appMain.currentUser.id){
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
  late Post post;

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
  late Post post;
  PostStats(this.post, {super.key});

  @override
  State<PostStats> createState() => _PostStatsState(post);
}


class _PostStatsState extends State<PostStats> {
  late Post post;
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
                post.commentMark,
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