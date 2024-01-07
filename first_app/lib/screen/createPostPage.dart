import 'dart:convert';
import 'dart:io';
import 'package:first_app/widget/avatar.dart';
import 'package:first_app/main.dart' as appMain;
import 'navbar.dart' as navbar;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

List<File> imageFiles = [];
List<File> videoFile = [];
final imageNotifier = ValueNotifier(0);
final videoNotifier = ValueNotifier(0);
final textNotifier = ValueNotifier(0);
final postableNotifier = ValueNotifier(0);
String newPostId = "";
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool typed = false;
  TextEditingController textController = TextEditingController();

  initState(){
    textController.text = appMain.cache.postSaveText;
    if (textController.text.trim().isNotEmpty) {
      textNotifier.value = 1;
      postableNotifier.value = 1;
    }
    else {
      textNotifier.value = 0;
      if (imageNotifier.value > 0 || videoNotifier.value > 0)
        postableNotifier.value = 1;
      else postableNotifier.value = 0;
    }
  }

  Future<String> AddPost() async {
    final dio = Dio();
    var formData = FormData();
    if (textController.text.isNotEmpty)
      formData.fields.add(MapEntry('described', textController.text));

    if (imageFiles.isNotEmpty)
      imageFiles.forEach((element) {
        formData.files.addAll([
          MapEntry('image', MultipartFile.fromFileSync(element.path, filename: basename(element.path), contentType: MediaType('image', 'jpg')))
        ]);
      });

    if (videoFile.isNotEmpty)
      formData.files.add(MapEntry(
          'video',
          MultipartFile.fromBytes(
            await videoFile[0].readAsBytes(),
            filename: basename(videoFile[0].path),
            contentType: MediaType('video', 'mp4')
          )
      ));

    final response = await dio.postUri(
      Uri.parse('https://it4788.catan.io.vn/add_post'),
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer ${appMain.currentUser.token}'
        }
      )
    );
    if (response.data['code'] == '1000'){
      newPostId = response.data['data']['id'];
    }
    return response.statusCode.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.grey[200],
            leading: IconButton(
              onPressed: () async {
                if (postableNotifier.value == 0){
                  Navigator.pop(context, 'none');
                  return;
                }

                var response = await showDialog(
                  context: context,
                  builder: (context){
                    return Dialog(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed:(){
                                  Navigator.pop(context, 'Save');
                                },
                                child: Text(
                                  'Lưu bản nháp',
                                  style: TextStyle(
                                    color: Colors.black
                                  ),
                                )
                              ),
                              Divider(),
                              TextButton(
                                  onPressed:(){
                                    Navigator.pop(context, 'Delete');
                                  },
                                  child: Text(
                                    'Bỏ bài viết',
                                    style: TextStyle(
                                      color: Colors.red
                                    ),
                                  )
                              ),
                              Divider(),
                              TextButton(
                                  onPressed:(){
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Tiếp tục chỉnh sửa',
                                    style: TextStyle(
                                      color: Colors.black
                                    ),
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                );

                if (response != null){
                  if (response == 'Delete'){
                    imageFiles.clear();
                    videoFile.clear();
                    imageNotifier.value = 0;
                    videoNotifier.value = 0;
                    textNotifier.value = 0;
                    postableNotifier.value = 0;
                    appMain.cache.postSaveText = "";
                    Navigator.pop(context, 'none');
                  }
                  else {
                    appMain.cache.saveCreatePost(textController.text);
                    textNotifier.value = 0;
                    Navigator.pop(context, 'none');
                  }
                }
              },
              icon: Image.asset(
                'assets/images/backarrow.png',
                width: 25,
                height: 25,
              ),
            ),
            title: Text(
              'Tạo bài viết',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 18
              ),
            ),
            actions: [
              ValueListenableBuilder(
                valueListenable: postableNotifier,
                builder: (context, value, child){
                  return TextButton(
                      onPressed: (){
                        if (postableNotifier.value > 0){
                          AddPost().then((value){
                            if (value == '200'){
                              Navigator.pop(context, newPostId);
                            }
                          });
                        }
                      },
                      child: Text(
                        'Đăng',
                        style: TextStyle(
                            color: (postableNotifier.value > 0) ? Colors.black:Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 18
                        ),
                      )
                  );
                },
                //PostImage()
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                children: [
                  // Ava + Name
                  Row(
                    children: [
                      Avatar(appMain.currentUser.avatar, MediaQuery.sizeOf(context).width / 7.5, online: '1',),
                      SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appMain.currentUser.username,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: 5,),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border(
                                top: BorderSide(width: 0.5, color: Colors.grey),
                                bottom: BorderSide(width: 0.5, color: Colors.grey),
                                left: BorderSide(width: 0.5, color: Colors.grey),
                                right: BorderSide(width: 0.5, color: Colors.grey),
                              ),
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/globe.png',
                                    width: 15,
                                    height: 15,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 5,),
                                  Text(
                                    'Công khai',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ]
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: textController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Bạn đang nghĩ gì?',
                      hintStyle: TextStyle(
                        color: Colors.grey
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    cursorWidth: 1.5,
                    onChanged: (value){
                      if (value.trim().isNotEmpty) {
                        textNotifier.value = 1;
                        postableNotifier.value = 1;
                      }
                      else {
                        textNotifier.value = 0;
                        if (imageNotifier.value > 0 || videoNotifier.value > 0)
                          postableNotifier.value = 1;
                        else postableNotifier.value = 0;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ValueListenableBuilder(
              valueListenable: imageNotifier,
              builder: (context, value, child){
                return PostImage();
              },
              //PostImage()
            ),
          ),
          SliverToBoxAdapter(
            child: ValueListenableBuilder(
              valueListenable: videoNotifier,
              builder: (context, value, child){
                return PostVideo();
              }
            ),
          )
        ],
      ),
      //bottomNavigationBar: CreatePostBottomTabBar(),
      bottomSheet: !(MediaQuery.viewInsetsOf(context).vertical > 0)
      ? Container(
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid),
                left: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid),
                right: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid),
                bottom: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid)
            ),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5)
            )
        ),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextButton(
                onPressed: (){
                  pickMediaFromGallery();
                },
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
      )
      : Container(
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
                onPressed: (){
                  pickMediaFromGallery();
                },
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
      )
    );
  }

  Future pickMediaFromGallery() async {
    final returnedMedia = await ImagePicker().pickMedia();
    print(returnedMedia!.path);

    if (returnedMedia.path.endsWith('mp4')){
      if (videoFile.length == 1 || imageFiles.isNotEmpty) return;
      videoFile.add(File(returnedMedia!.path));
      videoNotifier.value = 1;
      postableNotifier.value = 1;
    }
    else {
      if (imageFiles.length == 4 || videoFile.isNotEmpty) return;
      imageFiles.add(File(returnedMedia!.path));
      imageNotifier.value += 1;
      postableNotifier.value = 1;
    }
  }
}

class PostImage extends StatefulWidget {
  PostImage({super.key});

  @override
  State<PostImage> createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  double d = 5;

  @override
  Widget build(BuildContext context) {
    if (imageFiles.length == 0)
      return Container();
    if (imageFiles.length == 1){
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: ImageContainer(
              MediaQuery.sizeOf(context).width,
              MediaQuery.sizeOf(context).width,
              imageFiles[0],
              removeImageFile
          )
      );
    }
    else if (imageFiles.length == 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            ImageContainer(
              MediaQuery.sizeOf(context).width,
              (MediaQuery.sizeOf(context).width - d) / 2,
              imageFiles[0],
              removeImageFile
            ),
            SizedBox(width: d,),
            ImageContainer(
              MediaQuery.sizeOf(context).width,
              (MediaQuery.sizeOf(context).width - d) / 2,
              imageFiles[1],
              removeImageFile
            ),
          ],
        ),
      );
    }
    else if (imageFiles.length == 3){
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            ImageContainer(
              MediaQuery.sizeOf(context).width,
              (MediaQuery.sizeOf(context).width - d) / 2,
              imageFiles[0],
              removeImageFile
            ),
            SizedBox(width: d,),
            Column(
              children: [
                ImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  imageFiles[1],
                  removeImageFile
                ),
                SizedBox(height: d,),
                ImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  imageFiles[2],
                  removeImageFile
                ),
              ],
            )
          ],
        ),
      );
    }
    else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Column(
              children: [
                ImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  imageFiles[0],
                  removeImageFile
                ),
                SizedBox(height: d,),
                ImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  imageFiles[1],
                  removeImageFile
                ),
              ],
            ),
            SizedBox(width: d,),
            Column(
              children: [
                ImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d)/ 2,
                  imageFiles[2],
                  removeImageFile
                ),
                SizedBox(height: d,),
                ImageContainer(
                  (MediaQuery.sizeOf(context).width - d) / 2,
                  (MediaQuery.sizeOf(context).width - d)/ 2,
                  imageFiles[3],
                  removeImageFile
                ),
              ],
            )
          ],
        ),
      );
    }
  }

  removeImageFile(File file){
    print('Delete file: ' + file.toString());
    imageFiles.remove(file);
    imageNotifier.value -= 1;
    if (imageFiles.isEmpty){
      postableNotifier.value = textNotifier.value;
    }
  }
}

class ImageContainer extends StatelessWidget {
  late double height;
  late double width;
  late File imageFile;
  late Function(File) onPress;
  ImageContainer(this.height, this.width, this.imageFile, this.onPress, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              image: MemoryImage(imageFile.readAsBytesSync())
          )
      ),
      child: IconButton(
        onPressed: (){
          onPress(imageFile);
        },
        icon: Icon(
          Icons.cancel_rounded,
          color: Colors.white,
        ),
      ),
      alignment: Alignment.topRight,
    );
  }
}

class PostVideo extends StatefulWidget {
  const PostVideo({super.key});

  @override
  State<PostVideo> createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo> {
  @override
  Widget build(BuildContext context) {
    if (videoFile.isEmpty) return Container();
    return Stack(
      alignment: Alignment.topRight,
      children: [
        VideoPlayerWidget(videoFile[0]),
        IconButton(
          onPressed: (){
            videoFile.clear();
            videoNotifier.value = 0;
            postableNotifier.value = textNotifier.value;
          },
          icon: Icon(
            Icons.cancel_rounded,
            color: Colors.grey[400],
          ),
        )
      ]
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  late File file;
  VideoPlayerWidget(this.file, {super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: false,
          looping: false,
        );
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        height: MediaQuery.sizeOf(context).width,
        width: MediaQuery.sizeOf(context).width,
        child: _videoPlayerController.value.isInitialized
            ? FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).width,
                  child: Chewie(controller: chewieController,)
              ),
            )
            : Center(
                child: CircularProgressIndicator(),
              )
    );
  }
}




