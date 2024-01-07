import 'package:first_app/screen/menu/menuPasswordEditPage.dart';
import 'package:first_app/screen/menu/menuNameEditPage.dart';
import 'package:flutter/material.dart';
import 'package:first_app/main.dart' as appMain;

class MenuUserAccountPage extends StatelessWidget {

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
                    'Bảo mật và đăng nhập',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: 15,),
                  Text(
                    'Đăng nhập',
                    style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPasswordEditPage()));
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Đổi mật khẩu',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              Text(
                                'Bạn nên sử dụng mật khẩu mạnh mà chưa sử dụng ở đâu khác',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                            ],
                          ),
                        ),
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
