import 'package:flutter/material.dart';

class Cover extends StatefulWidget {
  late String url;
  late double width;
  late double height;
  Cover(this.url, this.width, this.height, {super.key});

  @override
  State<Cover> createState() => _CoverState();
}

class _CoverState extends State<Cover> {
  bool loading = false;

  @override
  void initState() {
    if (widget.url.isEmpty) {
      loading = true;
    }
    else {
      NetworkImage(widget.url).resolve(ImageConfiguration()).addListener(
          ImageStreamListener((image, synchronousCall) {
            setState(() {
              loading = true;
            });
          })
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      //print("Get avatar " + widget.url);
      return Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              image: widget.url.isNotEmpty ? NetworkImage(widget.url) : Image.asset('assets/images/user.png').image
          )
        ),
      );
    }
    else {
      return Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
            color: Colors.grey
        ),
      );
    }
  }
}

