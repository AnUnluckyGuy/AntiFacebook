import 'package:first_app/Model/AppImage.dart';
import 'package:first_app/Model/AppVideo.dart';
import 'package:first_app/Model/user.dart';

class Post{
  String id = "";
  String name = "";
  String created = "";
  String described = "";
  String modified = "";
  String fake = "";
  String trust = "";
  String kudos = "";
  String disappointed = "";
  String isRated = "";
  String isMarked = "";
  List<AppImage> images = [];
  AppVideo video = AppVideo();
  User author = User();
  String state = "";
  String isBlocked = "";
  String canEdit = "";
  String banned = "";
  String canMark = "";
  String canRate = "";
  String url = "";
  String message = "";
  String feel = "";
  String commentMark = "";
}