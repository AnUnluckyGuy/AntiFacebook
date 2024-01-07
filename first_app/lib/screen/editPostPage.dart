import 'package:flutter/material.dart';

import '../Model/post.dart';

class EditPostPage extends StatefulWidget {
  late Post post;
  EditPostPage(this.post, {super.key});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
