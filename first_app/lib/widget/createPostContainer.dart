import 'package:first_app/screen/createPostPage.dart';
import 'package:first_app/widget/avatar.dart';
import 'package:flutter/material.dart';
import 'package:first_app/main.dart' as appMain;

final avatarUrl = ValueNotifier(appMain.cache.currentUser.avatar);

class CreatePostContainer extends StatefulWidget {

  @override
  State<CreatePostContainer> createState() => _CreatePostContainerState();

  void avatarChange(){
    avatarUrl.value = appMain.cache.currentUser.avatar;
  }
}

class _CreatePostContainerState extends State<CreatePostContainer> {


  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ValueListenableBuilder(
              valueListenable: avatarUrl,
              builder: (context, value, child) {
                return Avatar(avatarUrl.value, 40);
              })
          ),
          Expanded(
            child: Container(
              //alignment: AlignmentDirectional.topStart,
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostPage())).then((value){
                      if (value != 'none'){

                      }
                    });
                  },
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bạn đang nghĩ gì',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 15
                        ),
                      )
                  ),
                )
            ),
          ),
          IconButton(
            onPressed: (){},
            icon: Icon(
              Icons.photo_library,
              color: Colors.green,
            ),
          ),
        ],
      ), //Divider(height: 15, thickness: 10,)
    );
  }
}

