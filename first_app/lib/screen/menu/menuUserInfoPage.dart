import 'package:first_app/screen/menu/menuNameEditPage.dart';
import 'package:flutter/material.dart';
import 'package:first_app/main.dart' as appMain;

class MenuUserInfoPage extends StatelessWidget {
  const MenuUserInfoPage({super.key});

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
                Navigator.pop(context);
              },
              icon: Image.asset(
                'assets/images/backarrow.png',
                width: 25,
                height: 25,
              ),
            ),
            shape: RoundedRectangleBorder(
                side: BorderSide(width: 0.1)
            )
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin cá nhân',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: 15,),
                  Text(
                    'Chung',
                    style: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MenuNameEditPage()));
                    },
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tên',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500
                              )
                            ),
                            Text(
                              appMain.currentUser.username,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500
                              ),
                            )
                          ],
                        ),
                        Expanded(child: SizedBox()),
                        Image.asset('assets/images/arrowright.png')
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(height: 1, thickness: 0.5,),
          )
        ],
      ),
    );
  }
}
