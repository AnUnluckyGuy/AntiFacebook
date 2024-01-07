import 'package:first_app/screen/menu/menuBlockPage.dart';
import 'package:first_app/screen/menu/menuUserAccountPage.dart';
import 'package:first_app/screen/menu/menuUserInfoPage.dart';
import 'package:flutter/material.dart';

class MenuEditPage extends StatelessWidget {
  const MenuEditPage({super.key});

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
            shape: RoundedRectangleBorder(
                side: BorderSide(width: 0.1)
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cài đặt tài khoản',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      Text(
                        'Quản lý thông tin về bạn, các tài khoản thanh toán và danh bạ của bạn, cũng như tài khoản nói chung.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15,),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MenuUserInfoPage()));
                    },
                    child: Row(
                      children: [
                        Image.asset('assets/images/user1.png', width: 40, height: 40,),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thông tin cá nhân',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              Text(
                                'Cập nhật tến, số điện thoại và địa chỉ email của bạn.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 5,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bảo mật',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      Text(
                        'Đổi mật khẩu và thực hiện các hành động khác để tăng cường bảo mật cho tài khoản của bạn.',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15,),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MenuUserAccountPage()));
                    },
                    child: Row(
                      children: [
                        Image.asset('assets/images/shield.png', width: 40, height: 40,),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bảo mật và đăng nhập',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              Text(
                                'Đổi mật khẩu và thực hiện các hành động khác để tăng cường bảo mật cho tài khoản của bạn.',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 5,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quyền riêng tư',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15,),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MenuBlockPage()));
                    },
                    child: Row(
                      children: [
                        Image.asset('assets/images/blockuser.png', width: 40, height: 40,),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chặn',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              Text(
                                'Xem lại những người bạn đã chặn trước đó.',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
