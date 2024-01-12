import 'dart:convert';
import 'package:first_app/main.dart' as appMain;
import 'package:first_app/screen/profile/otherProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widget/avatar.dart';
import '../widget/postImageContainer.dart';
import '../widget/videoPlayerWidget.dart';
import 'package:first_app/config/dateTimeConfig.dart';

PostInfo post = PostInfo();
DateTimeConfig dtConfig = DateTimeConfig();
ValueNotifier<String> typeOfComment = ValueNotifier("mark");
class PostPage extends StatefulWidget {
  late String id;
  PostPage(this. id, {super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {

  bool loading = false;
  @override
  void initState() {
    typeOfComment.value = 'mark';
    post.image.clear();
    post.video = '';
    GetPost().then((value){
      if (value == '200'){
        setState(() {
          loading = true;
        });
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Kiểm tra đường truyền mạng"),
        ));
      }
    });
    super.initState();
  }

  void refresh(){
    typeOfComment.value = 'mark';
    post.image.clear();
    post.video = '';
    GetPost().then((value){
      if (value == '200'){
        setState(() {
          loading = true;
        });
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Kiểm tra đường truyền mạng"),
        ));
      }
    });
  }

  Future GetPost() async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/get_post'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'id': widget.id,
      }),
    );

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);
    if (decodeResponse['code'] == '1000'){
      post.id = decodeResponse['data']['id'];
      post.name = decodeResponse['data']['name'];
      post.created = decodeResponse['data']['created'];
      post.described = decodeResponse['data']['described'];
      post.modified = decodeResponse['data']['modified'];
      post.fake = decodeResponse['data']['fake'];
      post.trust = decodeResponse['data']['trust'];
      post.kudos = decodeResponse['data']['kudos'];
      post.disappointed = decodeResponse['data']['disappointed'];
      post.isFelt = decodeResponse['data']['is_felt'];
      post.isMark = decodeResponse['data']['is_marked'];

      if (decodeResponse['data']['image'] != null){
        for (var im in decodeResponse['data']['image']){
          post.image.add(im['url']);
        }
      }

      if (decodeResponse['data']['video'] != null){
        post.video = decodeResponse['data']['video']['url'];
      }

      post.author.id = decodeResponse['data']['author']['id'];
      post.author.avatar = decodeResponse['data']['author']['avatar'];
      post.author.name = decodeResponse['data']['author']['name'];

      post.state = decodeResponse['data']['state'];
      post.isBlocked = decodeResponse['data']['is_blocked'];
      post.canEdit = decodeResponse['data']['can_edit'];
      post.banned = decodeResponse['data']['banned'];
      post.canMark = decodeResponse['data']['can_mark'];
      post.canRate = decodeResponse['data']['can_rate'];
      post.messages = decodeResponse['data']['messages'];
    }

    return response.statusCode.toString();
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
                int feels = int.parse(post.kudos) + int.parse(post.disappointed);
                Navigator.pop(context, feels);
              },
              icon: Image.asset(
                'assets/images/backarrow.png',
                width: 25,
                height: 25,
              ),
            ),
          ),
          if (!loading)...[
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          ]
          else...[
            SliverToBoxAdapter(
              child: Container(
                child: Column(
                  children: [
                    PostPageHeader(),
                    SizedBox(height: 20,),
                    PostPageContent(),
                    SizedBox(height: 10,),
                    PostPageStats(),
                    Divider(height: 0,),
                    ValueListenableBuilder(
                      valueListenable: listMarks,
                      builder: (context, value, child){
                        return PostPageComment();
                      }
                    ),
                    SizedBox(height: 100,)
                  ],
                ),
              ),
            )
          ]
        ],
      ),
      bottomSheet: CreateCommentBlock(refresh)
    );
  }
}

class CreateCommentBlock extends StatefulWidget {
  late Function() refresh;
  CreateCommentBlock(this.refresh, {super.key});

  @override
  State<CreateCommentBlock> createState() => _CreateCommentBlockState();
}

class _CreateCommentBlockState extends State<CreateCommentBlock> {
  TextEditingController textController = TextEditingController();

  Future SendMark(String content, String type) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/set_mark_comment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'id': post.id,
        'content': content,
        'index': '0',
        'count': '3',
        'type': type
      }),
    );

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);
    if (decodeResponse['code'] == '1000'){
      List<Mark> tmp = [];
      for (var data in decodeResponse['data']){
        Mark mark = Mark();
        mark.id = data['id'];
        mark.markContent = data['mark_content'];
        mark.typeOfMark = data['type_of_mark'];
        mark.created = data['created'];
        mark.poster.id = data['poster']['id'];
        mark.poster.name = data['poster']['name'];
        mark.poster.avatar = data['poster']['avatar'];
        for (var cmt in data['comments']){
          Comment comment = Comment();
          comment.content = cmt['content'];
          comment.created = cmt['created'];
          comment.poster.id = cmt['poster']['id'];
          comment.poster.name = cmt['poster']['name'];
          comment.poster.avatar = cmt['poster']['avatar'];
          mark.comments.add(comment);
        }
        tmp.add(mark);
      }
      listMarks.value = tmp;
    }

    return response.statusCode.toString();
  }

  Future SendComment(String content, String count) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/set_mark_comment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'id': post.id,
        'content': content,
        'index': '0',
        'count': (int.parse(count) + 1).toString(),
        'mark_id': listMarks.value[int.parse(count)].id
      }),
    );

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);
    if (decodeResponse['code'] == '1000'){
      List<Mark> tmp = [];
      for (var data in decodeResponse['data']){
        Mark mark = Mark();
        mark.id = data['id'];
        mark.markContent = data['mark_content'];
        mark.typeOfMark = data['type_of_mark'];
        mark.created = data['created'];
        mark.poster.id = data['poster']['id'];
        mark.poster.name = data['poster']['name'];
        mark.poster.avatar = data['poster']['avatar'];
        for (var cmt in data['comments']){
          Comment comment = Comment();
          comment.content = cmt['content'];
          comment.created = cmt['created'];
          comment.poster.id = cmt['poster']['id'];
          comment.poster.name = cmt['poster']['name'];
          comment.poster.avatar = cmt['poster']['avatar'];
          mark.comments.add(comment);
        }
        tmp.add(mark);
      }
      listMarks.value = tmp;
    }

    return response.statusCode.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey
          )
        )
      ),
      child: Wrap(
        direction: Axis.horizontal,
        children: [
            ValueListenableBuilder(
              valueListenable: typeOfComment,
              builder: (context, value, child) {
                return Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (typeOfComment.value != 'mark')...[
                          Row(
                            children: [
                              Text(
                                'Trả lời bình luận của ${listMarks.value[int.parse(typeOfComment.value)].poster.name}'
                              ),
                              SizedBox(width: 5,),
                              Text('.'),
                              SizedBox(width: 5,),
                              InkWell(
                                onTap:(){
                                  typeOfComment.value = 'mark';
                                },
                                child: Text(
                                  'Hủy'
                                )
                              )
                            ],
                          ),
                          SizedBox(height: 10,)
                        ],
                        Container(
                          width: MediaQuery
                              .sizeOf(context)
                              .width / 4 * 3,
                          child: TextField(
                            controller: textController,
                            style: TextStyle(
                                fontSize: 15
                            ),
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(50)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(50)
                                ),
                                hintText: 'Viết bình luận'
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    TextButton(
                        onPressed: () async {
                          if (textController.text.trim().isNotEmpty) {
                            if (typeOfComment.value == 'mark' && post.canMark == '1') {
                              await showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(1000, 1000, 0, 0),
                                items: [
                                  PopupMenuItem(value: '1', child: Text('Trust')),
                                  PopupMenuItem(value: '0', child: Text('Fake')),
                                ]
                              ).then((value){
                                if (value != null){
                                  SendMark(textController.text, value).then((value){
                                    if (value == '200') {
                                      widget.refresh();
                                    }
                                    else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text("Không thể bình luận"),
                                      ));
                                    }
                                  });
                                  textController.text = "";
                                }
                              });
                            }
                            else if (typeOfComment.value == 'mark' && post.canMark != '1'){
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("Không thể bình luận"),
                              ));
                            }
                            else {
                              SendComment(textController.text, typeOfComment.value).then((value){
                                if (value == '200') {
                                  widget.refresh();
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text("Không thể bình luận"),
                                  ));
                                }
                              });
                              textController.text = "";
                            }
                          }
                        },
                        child: Text(
                            'Gửi'
                        )
                    )
                  ],
                );
              }
            ),

        ],
      ),
          /*TextButton(
              onPressed: (){},
              child: Text(
                  'Gửi'
              )
          )*/
    );
  }
}


class PostPageHeader extends StatelessWidget {
  const PostPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    post.author.name,
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
    );
  }
}

class PostPageContent extends StatelessWidget {
  const PostPageContent({super.key});

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
          if (post.image.isNotEmpty)
            PostPageImage(),
          if (post.video.isNotEmpty)
            Center(child: VideoPlayerWidget(post.video)),
        ],
      ),
    );
  }
}

class PostPageImage extends StatelessWidget {
  double d = 5;
  PostPageImage({super.key});

  @override
  Widget build(BuildContext context) {
    if (post.image.length == 1){
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: PostImageContainer(
              MediaQuery.sizeOf(context).width,
              MediaQuery.sizeOf(context).width,
              post.image[0]
          )
      );
    }
    else if (post.image.length == 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            PostImageContainer(
              MediaQuery.sizeOf(context).width,
              (MediaQuery.sizeOf(context).width - d) / 2,
              post.image[0],
            ),
            SizedBox(width: d,),
            PostImageContainer(
              MediaQuery.sizeOf(context).width,
              (MediaQuery.sizeOf(context).width - d) / 2,
              post.image[1],
            ),
          ],
        ),
      );
    }
    else if (post.image.length == 3){
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            PostImageContainer(
              MediaQuery.sizeOf(context).width,
              (MediaQuery.sizeOf(context).width - d) / 2,
              post.image[0],
            ),
            SizedBox(width: d,),
            Column(
              children: [
                PostImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  post.image[1],
                ),
                SizedBox(height: d,),
                PostImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  post.image[2],
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
                  post.image[0],
                ),
                SizedBox(height: d,),
                PostImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  post.image[1],
                ),
              ],
            ),
            SizedBox(width: d,),
            Column(
              children: [
                PostImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d)/ 2,
                  post.image[2],
                ),
                SizedBox(height: d,),
                PostImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d)/ 2,
                  post.image[3],
                ),
              ],
            )
          ],
        ),
      );
    }
  }
}

class PostPageStats extends StatefulWidget {
  const PostPageStats({super.key});

  @override
  State<PostPageStats> createState() => _PostPageStatsState();
}

class _PostPageStatsState extends State<PostPageStats> {
  bool likeShow = false;

  Future Feel(String feelType) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/feel'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'id': post.id,
        'type': feelType
      }),
    );

    return response.statusCode.toString();
  }

  Future DeleteFeel() async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/delete_feel'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'id': post.id,
      }),
    );

    return response.statusCode.toString();
  }

  @override
  Widget build(BuildContext context) {
    String likeImage = "";
    Color likeColor = Colors.grey;
    String likeText = "Thích";
    if (post.isFelt == '-1'){
      likeImage = 'assets/images/like.png';
    }
    if (post.isFelt == '0'){
      likeImage = 'assets/images/dislikerounded.png';
      likeColor = Colors.red;
      likeText = 'Ghét';
    }
    if (post.isFelt == '1'){
      likeImage = 'assets/images/likerounded.png';
      likeColor = Colors.blue;
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/likerounded.png',
                color: Colors.blue,
                width: 20,
                height: 20,
              ),
              SizedBox(width: 5,),
              Text(
                post.kudos
              ),
              SizedBox(width: 10,),
              Image.asset(
                'assets/images/dislikerounded.png',
                color: Colors.red,
                width: 20,
                height: 20,
              ),
              SizedBox(width: 5,),
              Text(
                  post.disappointed
              ),
              Expanded(child: SizedBox()),
              Text(
                  'Trust: ${post.trust}'
              ),
              SizedBox(width: 10,),
              Text(
                  'Fake: ${post.fake}'
              ),
            ]
          ),
          Divider(),
          Row(
            children: [
              PostPageButton(
                Image.asset(
                  likeImage,
                  width: 20,
                  height: 20,
                  color: likeColor,
                ),
                likeText,
                (){
                  if (post.isFelt == '-1'){
                    Feel('1').then((value){
                      if (value == '200'){
                        setState(() {
                          post.isFelt = '1';
                          post.kudos = (int.parse(post.kudos) + 1).toString();
                        });
                      }
                    });
                  }
                  else {
                    DeleteFeel().then((value){
                      if (value == '200'){
                        setState(() {
                          post.isFelt = '-1';
                          post.kudos = (int.parse(post.kudos) - 1).toString();
                        });
                      }
                    });
                  }
                },
                () {}
              ),
              PostPageButton(
                Image.asset(
                  'assets/images/comment.png',
                  width: 20,
                  height: 20,
                  color: Colors.grey,
                ),
                'Bình luận',
                (){},
                (){},
              ),
              PostPageButton(
                Image.asset(
                  'assets/images/share.png',
                  width: 20,
                  height: 20,
                  color: Colors.grey,
                ),
                'Chia sẻ',
                (){},
                (){},
              ),
            ],
          )
        ],
      ),
    );
  }
}

class PostPageButton extends StatefulWidget {
  late Image image;
  late String label;
  late void Function() onTap;
  late void Function() onLongPress;
  PostPageButton(this.image, this.label, this.onTap, this.onLongPress, {super.key});

  @override
  State<PostPageButton> createState() => _PostPageButtonState();
}

class _PostPageButtonState extends State<PostPageButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onLongPress: widget.onLongPress,
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.image,
                const SizedBox(width: 10,),
                Text(widget.label)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

ValueNotifier<List<Mark>> listMarks = ValueNotifier<List<Mark>>([]);

class PostPageComment extends StatefulWidget {
  const PostPageComment({super.key});

  @override
  State<PostPageComment> createState() => _PostPageCommentState();
}

class _PostPageCommentState extends State<PostPageComment> {

  Future GetMarkComment(String index) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/get_mark_comment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'id': post.id,
        'index': index,
        'count': '3'
      }),
    );

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);
    if (decodeResponse['code'] == '1000'){
      List<Mark> tmp = [...listMarks.value];
      for (var data in decodeResponse['data']){
        Mark mark = Mark();
        mark.id = data['id'];
        mark.markContent = data['mark_content'];
        mark.typeOfMark = data['type_of_mark'];
        mark.created = data['created'];
        mark.poster.id = data['poster']['id'];
        mark.poster.name = data['poster']['name'];
        mark.poster.avatar = data['poster']['avatar'];
        for (var cmt in data['comments']){
          Comment comment = Comment();
          comment.content = cmt['content'];
          comment.created = cmt['created'];
          comment.poster.id = cmt['poster']['id'];
          comment.poster.name = cmt['poster']['name'];
          comment.poster.avatar = cmt['poster']['avatar'];
          mark.comments.add(comment);
        }
        tmp.add(mark);
      }
      listMarks.value = tmp;
    }

    return response.statusCode.toString();
  }

  void addMark() async {
    await GetMarkComment(listMarks.value.length.toString()).then((value){
      setState(() {});
    });
  }

  @override
  void initState() {
    listMarks.value.clear();
    GetMarkComment('0').then((value){
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextButton(
              onPressed: (){
                addMark();
              },
              child: Text(
                'Hiển thị thêm bình luận'
              )
            ),
          ),
          for (var i = listMarks.value.length - 1; i >= 0; --i)...[
            MarkContainer(i)
          ]
        ],
      ),
    );
  }
}

class MarkContainer extends StatefulWidget {
  late int index;
  MarkContainer(this.index, {super.key});

  @override
  State<MarkContainer> createState() => _MarkContainerState();
}

class _MarkContainerState extends State<MarkContainer> {
  @override
  Widget build(BuildContext context) {
    Mark mark = listMarks.value[widget.index];
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          MarkBlock(mark.poster.avatar, mark.poster.name, mark.markContent, mark.created, widget.index),
          for (Comment cmt in mark.comments)...[
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 0, 0),
              child: CommentBlock(cmt.poster.avatar, cmt.poster.name, cmt.content, cmt.created),
            )
          ]
        ],
      ),
    );
  }
}

class MarkBlock extends StatelessWidget {
  late String avatar;
  late String name;
  late String content;
  late String time;
  late int index;
  MarkBlock(this.avatar, this.name, this.content, this.time, this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Avatar(avatar, 40),
        SizedBox(width: 5,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    Text(
                      content,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dtConfig.showDateTimeDiff(time),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400
                  ),
                ),
                SizedBox(width: 10,),
                InkWell(
                  onTap: (){
                    typeOfComment.value = index.toString();
                  },
                  child: Text(
                    'Phản hồi',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600
                    ),
                  )
                )
              ],
            )
          ],
        )
      ],
    );
  }
}


class CommentBlock extends StatelessWidget {
  late String avatar;
  late String name;
  late String content;
  late String time;
  CommentBlock(this.avatar, this.name, this.content, this.time, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Avatar(avatar, 40),
        SizedBox(width: 5,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    Text(
                      content,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.5,),
            Text(
              dtConfig.showDateTimeDiff(time),
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400
              ),
            ),
          ],
        )
      ],
    );
  }
}


class PostInfo {
  String id = "";
  String name = "";
  String created = "";
  String described = "";
  String modified = "";
  String fake = "";
  String trust = "";
  String kudos = "";
  String disappointed = "";
  String isFelt = "";
  String isMark = "";
  List<String> image = [];
  String video = "";
  Author author = Author();
  String state = "";
  String isBlocked = "";
  String canEdit = "";
  String banned = "";
  String canMark = "";
  String canRate = "";
  String messages = "";
}

class Author {
  String id = "";
  String name = "";
  String avatar = "";
}

class Mark {
  String id = "";
  String markContent = "";
  String typeOfMark = "";
  String created = "";
  Author poster = Author();
  List<Comment> comments = [];
}

class Comment {
  String content = "";
  String created = "";
  Author poster = Author();
}
