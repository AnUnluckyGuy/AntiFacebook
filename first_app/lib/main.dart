import 'dart:io';
import 'package:first_app/Model/suggestedFriend.dart';
import 'package:first_app/screen/auth/signInPage.dart';
import 'package:first_app/Model/user.dart';
import 'package:flutter/material.dart';

//User currentUser = User();
CustomCache cache = CustomCache();
void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.grey.withOpacity(0.5)
      )
    ),
    home: SignInPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class CustomCache {
  List<SuggestedFriend> suggestedFriend = [];
  User currentUser = User();
  String postSaveText = '';
  List<File> postSaveImageFiles = [];
  List<File> postSaveVideoFile = [];

  void saveSuggestedFriend(List<SuggestedFriend> list){
    suggestedFriend.clear();
    list.forEach((element) {
      suggestedFriend.add(element);
    });
  }

  void saveCreatePost(String text){
    postSaveText = text;
  }
}