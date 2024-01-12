import 'dart:io';
import 'package:first_app/Model/AppImage.dart';
import 'package:first_app/widget/avatar.dart';
import 'package:first_app/main.dart' as appMain;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../Model/post.dart';
import 'package:path_provider/path_provider.dart';

List<MediaFile> imageFiles = [];
List<MediaFile> videoFile = [];
final imageNotifier = ValueNotifier(0);
final videoNotifier = ValueNotifier(0);
final textNotifier = ValueNotifier(0);
final postableNotifier = ValueNotifier(0);
List<int> del = [];
class EditPostPage extends StatefulWidget {
  late Post post;
  EditPostPage(this. post, {super.key});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  bool typed = false;
  TextEditingController textController = TextEditingController();

  initState() {
  del.clear();
  postableNotifier.value = 1;
  textController.text = widget.post.described;
    if (textController.text.trim().isNotEmpty) {
      textNotifier.value = 1;
    }
    else {
      textNotifier.value = 0;
    }

    GetPostData().then((value) {
      imageNotifier.value = imageFiles.length;
      videoNotifier.value = videoFile.length;
      setState(() {});
    });
  }

  Future GetPostData() async {
    if (widget.post.images.isNotEmpty){
      for (var i = 0; i < widget.post.images.length; ++i){
        await urlToImageFile(widget.post.images[i].url, i).then((value) {
          imageFiles.add(MediaFile('old', value));
        });
      }
    }

    if (widget.post.video.url.isNotEmpty){
      await urlToVideoFile(widget.post.video.url, 5).then((value) {
        videoFile.add(MediaFile('old', value));
      });
    }
  }

  Future<File> urlToImageFile(String url, int rand) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File(tempPath + rand.toString() + '.png');
    http.Response response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<File> urlToVideoFile(String url, int rand) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File(tempPath + rand.toString() + '.mp4');
    http.Response response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<String> EditPost() async {
    final dio = Dio();
    var formData = FormData();
    if (textController.text.isNotEmpty)
      formData.fields.add(MapEntry('described', textController.text));

    print(imageFiles.length);
    if (imageFiles.isNotEmpty) {
      imageFiles.forEach((element) {
        if (element.check != 'old') {
          formData.files.addAll([
            MapEntry('image', MultipartFile.fromFileSync(
                element.file.path, filename: basename(element.file.path),
                contentType: MediaType('image', 'jpg')))
          ]);
        }
      });
    }

    if (videoFile.isNotEmpty) {
      if (videoFile[0].check != 'old') {
        formData.files.add(MapEntry(
            'video',
            MultipartFile.fromBytes(
                await videoFile[0].file.readAsBytes(),
                filename: basename(videoFile[0].file.path),
                contentType: MediaType('video', 'mp4')
            )
        ));
      }
    }

    if (del.isNotEmpty) {
      del.sort();
      String imageDel = '';
      for (var i = 0; i < del.length; ++i){
        imageDel += del[i].toString();
        if (i < del.length - 1) imageDel += ',';
      }
      print(imageDel);
      formData.fields.add(MapEntry('image_del', imageDel));
    }

    formData.fields.add(MapEntry('id', widget.post.id));

    final response = await dio.postUri(
        Uri.parse('https://it4788.catan.io.vn/edit_post'),
        data: formData,
        options: Options(
            headers: {
              'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
            }
        )
    );
    print(response.data);
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
                                  Text('Bỏ thay dổi'),
                                  Row(
                                    children: [
                                      TextButton(
                                          onPressed:(){
                                            Navigator.pop(context, 'Continue');
                                          },
                                          child: Text(
                                            'TIẾP TỤC CHỈNH SỬA',
                                            style: TextStyle(
                                                color: Colors.black
                                            ),
                                          )
                                      ),
                                      SizedBox(width: 10,),
                                      TextButton(
                                          onPressed:(){
                                            Navigator.pop(context, 'Delete');
                                          },
                                          child: Text(
                                            'BỎ',
                                            style: TextStyle(
                                                color: Colors.red
                                            ),
                                          )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  );
                  if (response == 'Delete'){
                    imageFiles.clear();
                    videoFile.clear();
                    imageNotifier.value = 0;
                    videoNotifier.value = 0;
                    textNotifier.value = 0;
                    postableNotifier.value = 0;
                    Navigator.pop(context, 'none');
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
                            EditPost().then((value){
                              if (value == '200'){
                                imageFiles.clear();
                                videoFile.clear();
                                imageNotifier.value = 0;
                                videoNotifier.value = 0;
                                textNotifier.value = 0;
                                postableNotifier.value = 0;
                                Navigator.pop(context, 'new');
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
                          Avatar(appMain.cache.currentUser.avatar, MediaQuery.sizeOf(context).width / 7.5, online: '1',),
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appMain.cache.currentUser.username,
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
      videoFile.add(MediaFile('new', File(returnedMedia!.path)));
      videoNotifier.value = 1;
      postableNotifier.value = 1;
    }
    else {
      if (imageFiles.length == 4 || videoFile.isNotEmpty) return;
      imageFiles.add(MediaFile('new', File(returnedMedia!.path)));
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

  removeImageFile(MediaFile file){
    if (file.check == 'old'){
      del.add(imageFiles.indexOf(file) + 1);
    }
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
  late MediaFile imageFile;
  late Function(MediaFile) onPress;
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
              image: MemoryImage(imageFile.file.readAsBytesSync())
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
          VideoPlayerWidget(videoFile[0].file),
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

class MediaFile {
  late String check;
  late File file;

  MediaFile(this.check, this.file);
}





