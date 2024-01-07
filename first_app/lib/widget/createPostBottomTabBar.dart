import 'package:flutter/material.dart';

class CreatePostBottomTabBar extends StatefulWidget {
  const CreatePostBottomTabBar({super.key});

  @override
  State<CreatePostBottomTabBar> createState() => _CreatePostBottomTabBarState();
}

class _CreatePostBottomTabBarState extends State<CreatePostBottomTabBar> {
  @override
  Widget build(BuildContext context) {
    bool keyboardOpened = MediaQuery.viewInsetsOf(context).vertical > 0;
    if (!keyboardOpened) {
      return Container(
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid),
                left: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid),
                right: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid),
                bottom: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid)
            ),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5))
        ),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextButton(
                onPressed: (){},
                child: Row(
                    children: [
                      Image.asset(
                        'assets/images/photos.png',
                        color: Colors.green,
                        width: 30,
                        height: 30,
                      ),
                      SizedBox(width: 5,),
                      Text(
                        'Ảnh/video',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15
                        ),
                      )
                    ]
                ),
              ),
            ),
            Divider(thickness: 2, height: 0,),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextButton(
                onPressed: (){},
                child: Row(
                    children: [
                      Image.asset(
                        'assets/images/happy.png',
                        color: Colors.yellow,
                        width: 23,
                        height: 23,
                      ),
                      SizedBox(width: 12,),
                      Text(
                        'Cảm xúc/Hoạt động',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15
                        ),
                      )
                    ]
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid),
              left: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid),
              right: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid),
              bottom: BorderSide(width: 0, color: Colors.grey, style: BorderStyle.solid)
          ),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5))
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Thêm vào bài viết của bạn',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: (){}, 
              icon: Image.asset(
                'assets/images/photos.png',
                color: Colors.green,
              )
            ),
            IconButton(
                onPressed: (){},
                icon: Image.asset(
                  'assets/images/happy.png',
                  color: Colors.yellow,
                  width: 25,
                  height: 25,
                )
            )
          ],
        ),
      );
    }
  }
}
