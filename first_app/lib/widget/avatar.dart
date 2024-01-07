import 'package:flutter/material.dart';

class Avatar extends StatefulWidget {
  late String url;
  late double size;
  String online;
  Avatar(this.url, this.size, {this.online = "0", super.key});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
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
      return Container(
        height: widget.size,
        width: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 2.5,
            color: widget.online == "1" ? Color(0xff00ff34) : Colors.white
          )
        ),
        child: CircleAvatar(
          backgroundImage: widget.url.isNotEmpty ? NetworkImage(widget.url) : Image.asset('assets/images/user.png').image,
        ),
      );
    }
    else {
      return Container(
        height: widget.size,
        width: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          backgroundColor: Colors.grey[200],
        ),
      );
    }
  }
}

