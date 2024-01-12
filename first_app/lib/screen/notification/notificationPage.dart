import 'dart:convert';
import 'package:first_app/main.dart' as appMain;
import 'package:first_app/screen/postPage.dart';
import 'package:first_app/screen/profile/otherProfilePage.dart';
import 'package:first_app/widget/avatar.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/Model/user.dart';
import 'package:flutter/material.dart';
import '../navbar.dart' as navbar;
import 'package:first_app/config/dateTimeConfig.dart' as dtConfig;

ValueNotifier<List<Notification>> listNoti = ValueNotifier<List<Notification>>([]);
ScrollController scrollController = ScrollController();
dtConfig.DateTimeConfig dt = dtConfig.DateTimeConfig();
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();

  void scrollToTop(){
    scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }
}

class _NotificationPageState extends State<NotificationPage> {

  Future<void> _refresh() async {
    List<Notification> tmp = [];
    listNoti.value = tmp;
    await GetNotification('0');
    return Future.delayed(Duration(seconds: 2));
  }

  Future GetNotification(String index) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/get_notification'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        'index': index,
        'count': "20",
      }),
    );

    Map<String, dynamic> decodeResponse = jsonDecode(response.body);

    if (decodeResponse['code'] == '1000'){
      List<Notification> lp = [...listNoti.value];
      for (var noti in decodeResponse['data']){
        Notification notification = Notification();
        notification.type = noti['type'];
        notification.objectId = noti['object_id'];
        notification.user.username = noti['user']['username'];
        notification.user.avatar = noti['user']['avatar'];
        notification.user.id = noti['user']['id'];
        notification.created = noti['created'];
        lp.add(notification);
      }
      listNoti.value = lp;
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Kiểm tra đường truyền mạng"),
      ));
    }

    return decodeResponse['code'];
  }

  @override
  void initState() {
    listNoti.value.clear();
    scrollController.addListener(() {
      if (scrollController.position.atEdge){
        if (scrollController.position.pixels != 0)  {
          GetNotification(listNoti.value.length.toString()).then((value) {
            setState(() {});
          });
        }
      }
    });
    GetNotification('0').then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              title: Text(
                'Thông báo',
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
              child: ValueListenableBuilder(
                valueListenable: listNoti,
                builder: (context, value, chile){
                  return NotificationContainer();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NotificationContainer extends StatefulWidget {
  const NotificationContainer({super.key});

  @override
  State<NotificationContainer> createState() => _NotificationContainerState();
}

class _NotificationContainerState extends State<NotificationContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (Notification noti in listNoti.value)
          NotiContainer(noti)
      ],
    );
  }
}

class NotiContainer extends StatelessWidget {
  late Notification noti;
  NotiContainer(this.noti, {super.key});

  @override
  Widget build(BuildContext context) {
    String content = '';

    switch (noti.type){
      case '1':
        content = ' đã gửi lời mời kết bạn';
        break;
      case '2':
        content = ' đã chấp nhận lời mời kết bạn';
        break;
      case '3':
        content = ' đã thêm bài viết mới';
        break;
      case '4':
        content = ' đã cập nhật bài viết';
        break;
      case '5':
        content = ' đã thả cảm xúc cho bài viết của bạn';
        break;
      case '6':
        content = ' đã gắn mark cho bài viết của bạn';
        break;
      case '7':
        content = ' đã bình luận mark';
        break;
      case '8':
        content = ' đã thêm một video mới';
        break;
      case '9':
        content = ' đã bình luận bài viết của bạn';
        break;
    }

    return GestureDetector(
      onTap: (){
        if (noti.type == '1'){
          navbar.selectedIndex.value = 1;
        }
        else if (noti.type == '2'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfilePage(noti.objectId)));
        }
        else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PostPage(noti.objectId)));
        }
      },
      child: Container(
        color: Colors.transparent,
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Avatar(noti.user.avatar, 70),
            SizedBox(width: 10,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: noti.user.username,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold
                      ),
                      children: [
                        TextSpan(
                          text: content,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17.5,
                            fontWeight: FontWeight.w300
                          )
                        )
                      ]
                    )
                  ),
                  Text(
                    dt.showDateTimeDiff(noti.created),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w300
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}



class Notification {
  String type = "";
  String objectId = "";
  String created = "";
  User user = User();
}
