import 'package:flutter/material.dart';


class PostImageContainer extends StatelessWidget {
  late double height;
  late double width;
  late String url;
  PostImageContainer(this.height, this.width, this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        image: DecorationImage(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            image: NetworkImage(url)
        )
      ),
    );
  }
}
