import 'package:first_app/Model/userInfo.dart';
import 'package:first_app/screen/search/profileSearchPage.dart';
import 'package:flutter/material.dart';
import 'editPage.dart';

class ProfileEditingPage extends StatefulWidget {
  late UserInfo userInfo;
  ProfileEditingPage(this.userInfo, {super.key});

  @override
  State<ProfileEditingPage> createState() => _ProfileEditingPageState();
}

class _ProfileEditingPageState extends State<ProfileEditingPage> {

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
            title: Text(
              'Cài đặt trang cá nhân',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20
              ),
            )
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 10,
              color: Colors.grey[400],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditPage(widget.userInfo)));
                    },
                    child: Text(
                      'Chỉnh sửa trang cá nhân',
                      style: TextStyle(
                        color: Colors.black
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white
                    ),
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: (){},
                    child: Text(
                      'Kho lưu trữ tin',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white
                    ),
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: (){},
                    child: Text(
                      'Mục đã lưu',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 10,
              color: Colors.grey[400],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: (){},
                    child: Text(
                      'Chế độ xem',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white
                    ),
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: (){},
                    child: Text(
                      'Nhật ký hoạt động',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white
                    ),
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: (){},
                    child: Text(
                      'Quản lý bài viết',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white
                    ),
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: (){},
                    child: Text(
                      'Xem lại dòng thời gian',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white
                    ),
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: (){},
                    child: Text(
                      'Xem lối tắt quyên riêng tư',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white
                    ),
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSearchPage(widget.userInfo.id)));
                    },
                    child: Text(
                      'Tìm kiếm trên trang cá nhân',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 10,
              color: Colors.grey[400],
            ),
          ),
        ]
      )
    );
  }
}
