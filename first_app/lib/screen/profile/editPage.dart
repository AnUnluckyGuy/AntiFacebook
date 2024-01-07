import 'dart:convert';
import 'dart:io';
import 'package:first_app/Model/userInfo.dart';
import 'package:first_app/screen/profile/editDetailPage.dart';
import 'package:first_app/screen/profile/profilePage.dart';
import 'package:first_app/widget/avatar.dart';
import 'package:first_app/widget/cover.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/main.dart' as appMain;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class EditPage extends StatefulWidget {
  late UserInfo userInfo;
  EditPage(this.userInfo, {super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {

  Future<String> SetUserImage(String changeField, File image) async {
    var req = http.MultipartRequest('POST', Uri.parse('https://it4788.catan.io.vn/set_user_info'));
    req.headers.addAll({
      //'Content-Type': 'multipart/form-data; charset=UTF-8',
      'Authorization': 'Bearer ${appMain.currentUser.token}'
    });
    req.files.add(http.MultipartFile.fromBytes(
        changeField,
        image.readAsBytesSync(),
        filename: basename(image.path),
        contentType: MediaType('image', 'jpg')
    )
    );
    final response = await req.send();
    return response.statusCode.toString();
  }

  Future<String> SetUserCity(String city) async {
    var req = http.MultipartRequest('POST', Uri.parse('https://it4788.catan.io.vn/set_user_info'));
    req.headers.addAll({
      //'Content-Type': 'multipart/form-data; charset=UTF-8',
      'Authorization': 'Bearer ${appMain.currentUser.token}'
    });
    req.fields['city'] = city;
    final response = await req.send();
    return response.statusCode.toString();
  }

  Future GetUserInfo(String id) async {
    final response = await http.post(
      Uri.parse('https://it4788.catan.io.vn/get_user_info'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${appMain.currentUser.token}'
      },
      body: jsonEncode(<String, String>{
        "user_id": id
      }),
    );

    return jsonDecode(response.body);
  }

  Future pickImageFromGallery(String field) async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage?.path != null){
      SetUserImage(field, File(returnedImage!.path)).then((value){
        if (value == '201'){
          GetUserInfo(appMain.currentUser.id).then((value){
            if (field == 'avatar') widget.userInfo.avatar = value['data']['avatar'];
            else widget.userInfo.coverImage = value['data']['cover_image'];
            setState(() {});
          });
        }
      });
    }
    else {
      print('No image picked');
    }
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
                  Navigator.pop(context);
                },
                icon: Image.asset(
                  'assets/images/backarrow.png',
                  width: 25,
                  height: 25,
                ),
              ),
              title: Text(
                'Chỉnh sửa trang cá nhân',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20
                ),
              )
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          'Ảnh đại diện',
                          style: TextStyle(
                            fontSize: 18.5,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        TextButton(
                          onPressed: (){
                            pickImageFromGallery('avatar');
                          }, 
                          child: Text('Chỉnh sửa'))
                      ],
                    ),
                  ),
                  Avatar(widget.userInfo.avatar, MediaQuery.sizeOf(context).width / 3)
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 0.25,
              color: Colors.grey,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          'Ảnh bìa',
                          style: TextStyle(
                              fontSize: 18.5,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        TextButton(
                          onPressed: (){
                            pickImageFromGallery('cover_image');
                          },
                          child: Text('Chỉnh sửa')
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Cover(
                      widget.userInfo.coverImage,
                      MediaQuery.sizeOf(context).width,
                      MediaQuery.sizeOf(context).height / 4
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 0.25,
              color: Colors.grey,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          'Tiểu sử',
                          style: TextStyle(
                              fontSize: 18.5,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        TextButton(onPressed: (){}, child: Text('Thêm'))
                      ],
                    ),
                  ),
                  Text(
                    'Mô tả bản thân...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 0.25,
              color: Colors.grey,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          'Chi tiết',
                          style: TextStyle(
                              fontSize: 18.5,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        TextButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditDetailPage(widget.userInfo.city))).then((res){
                              SetUserCity(res).then((value){
                                if (value == '201'){
                                  widget.userInfo.city = res;
                                  setState(() {});
                                }
                              });
                            });
                          },
                          child: Text('Chỉnh sửa')
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/home.png',
                          width: 30,
                          height: 30,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 15,),
                        RichText(
                          text: TextSpan(
                              text: 'Sống tại ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400
                              ),
                              children: [
                                TextSpan(
                                    text: widget.userInfo.city,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500
                                    )
                                )
                              ]
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 0.25,
              color: Colors.grey,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          'Sở thích',
                          style: TextStyle(
                              fontSize: 18.5,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        TextButton(onPressed: (){}, child: Text('Thêm'))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 0.25,
              color: Colors.grey,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          'Liên kết',
                          style: TextStyle(
                              fontSize: 18.5,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        TextButton(onPressed: (){}, child: Text('Thêm'))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
