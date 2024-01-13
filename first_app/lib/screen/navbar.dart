import 'package:first_app/screen/notification/notificationPage.dart';
import 'package:first_app/screen/profile/profilePage.dart';
import 'package:first_app/screen/videoPage.dart';
import 'package:flutter/material.dart';
import 'friend/friendPage.dart';
import 'menu/menuPage.dart';
import 'newsfeedsPage.dart';
import 'package:first_app/main.dart' as appMain;

NewsFeedsPage newsFeedsPage = NewsFeedsPage();
FriendPage friendPage = FriendPage();
VideoPage videoPage = VideoPage();
ProfilePage profilePage = ProfilePage(appMain.cache.currentUser.id);
NotificationPage notificationPage = NotificationPage();
MenuPage menu = MenuPage();
final List<IconData> icons = [
  Icons.home,
  Icons.group,
  Icons.ondemand_video,
  Icons.account_circle_outlined,
  Icons.notifications_outlined,
  Icons.menu
];
final selectedIndex = ValueNotifier(0);

class NavBar extends StatefulWidget {

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {

  @override
  void initState() {
    selectedIndex.value = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 6,
        child: ValueListenableBuilder(
          valueListenable: selectedIndex,
          builder: (context, value, child) {
            return Scaffold(
              body: IndexedStack(
                index: selectedIndex.value,
                children: [
                  newsFeedsPage,
                  friendPage,
                  videoPage,
                  profilePage,
                  notificationPage,
                  menu
                ],
              ),
              bottomNavigationBar: TabBar(
                indicatorPadding: EdgeInsets.zero,
                indicator: BoxDecoration(
                  color: Colors.transparent
                ),
                tabs: icons.asMap()
                    .map((i, e) => MapEntry(i, Tab(
                    icon: Icon(
                        e,
                        color: i == selectedIndex.value ? Colors.blue:Colors.black45,
                        size: 30
                    )))
                ).values.toList(),
                onTap: (index){
                  if (selectedIndex.value == index){
                    if (index == 0 ){
                      newsFeedsPage.scrollToTop();
                    }
                    if (index == 1){
                      friendPage.scrollToTop();
                    }
                    if (index == 2){
                      videoPage.scrollToTop();
                    }
                    if (index == 3){
                      profilePage.scrollToTop();
                    }
                    if (index == 4){
                      notificationPage.scrollToTop();
                    }
                  }
                  selectedIndex.value = index;
                },
              ),
            );
          }
        )
    );
  }
}


