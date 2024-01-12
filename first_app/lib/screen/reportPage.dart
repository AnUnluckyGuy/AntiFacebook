import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:first_app/main.dart' as appMain;
import 'package:http/http.dart' as http;
import '../Model/post.dart';

class ReportPage extends StatefulWidget {
  late Post post;
  ReportPage(this.post, {super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late int page = 0;
  late List<String> Subject;
  late List<List<String>> Detail;
  String subject = '';
  String detail = '';

  Future Block(String id) async {
    final response = await http.post(
        Uri.parse('https://it4788.catan.io.vn/set_block'),
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
        },
        body: jsonEncode(<String, String> {
          'user_id': id
        })
    );

    return response.statusCode.toString();
  }

  Future Report() async {
    final response = await http.post(
        Uri.parse('https://it4788.catan.io.vn/report_post'),
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${appMain.cache.currentUser.token}'
        },
        body: jsonEncode(<String, String> {
          "id":widget.post.id,
          "subject": subject,
          "details": detail
        })
    );

    return response.statusCode.toString();
  }

  @override
  void initState() {
    page = 0;
    Subject = ['subject','Ảnh khỏa thân', 'Bạo lực', 'Quấy rối', 'Tự tử hoặc tự gây thương tích' , 'Thông tin sai sự thật', 'Spam', 'Bán hàng trái phép', 'Ngôn từ gây thù ghét',
                            'Rối loạn ăn uống', 'Liên quan đến trẻ em', 'Khủng bố', 'Vấn đề khác'];
    List<String> Detail1 = ['detail', 'Ảnh khỏa thân người lớn', 'Gợi dục', 'Hoạt động tình dục', 'Bóc lột tình dục', 'Dịch vụ tình dục',
                            'Ảnh khỏa thân trẻ em', 'Chia sẻ hình ảnh riêng tư'];
    List<String> Detail2 = ['detail', 'Hình ảnh bạo lực', 'Tử vong hoăc bị thương nặng', 'Mối đe dọa bạo lực', 'Ngược đãi động vật',
                            'Ba lực tình dục', 'Vấn đề khác'];
    List<String> Detail3 = ['detail'];
    List<String> Detail4 = ['detail'];
    List<String> Detail5 = ['detail', 'Sức khỏe', 'Chính trị', 'Vấn đề xã hội', 'Nội dung khác'];
    List<String> Detail6 = ['detail'];
    List<String> Detail7 = ['detail', 'Chất cấm', 'Chất cấm, chất gây nghiện', 'Vũ khí', 'Động vật có nguy cơ bị tuyệt chủng',
                            'Động vật khác', 'Vấn đề khác'];
    List<String> Detail8 = ['detail', 'Chủng tộc hoặc sắc tộc', 'Nguồn gốc quốc gia', 'Thành phần tôn giáo', 'Phân chia giai cấp xã hội',
                            'Thiên hướng tính dục', 'Giới tính hoặc bản dạng giới', 'Tình trạng khuyết tật hoặc bệnh tật', 'Hạng mức khác'];
    List<String> Detail9 = ['detail'];
    List<String> Detail10 = ['detail', 'Ảnh khỏa thân trẻ em', 'Lạm dụng trẻ em', 'Nội dung khác'];
    List<String> Detail11 = ['detail'];
    List<String> Detail12 = ['detail', 'Quyền sở hữu trí tuệ', 'Gian lận hoặc lừa đảo', 'Chế giễu nạn nhân', 'Bắt nạt', 'Lạm dụng trẻ em',
                            'Quảng bá hành vi sử dụng ma túy'];
    
    Detail = [[], Detail1, Detail2, Detail3, Detail4, Detail5, Detail6, Detail7, Detail8, Detail9, Detail10, Detail11, Detail12];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: (){
                if (page != 0){
                  setState(() {
                    subject = '';
                    detail = '';
                    page = 0;
                  });
                }
              },
              icon: Image.asset(
                'assets/images/backarrow.png',
                width: 25,
                height: 25,
              ),
            ),
            title: Text(
              'Báo cáo',
              style: TextStyle(
                color: Colors.black
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text(
                  'X',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                  ),
                )
              )
            ],
          ),
          if (page != 20)...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Hãy chọn vấn đề',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.5,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            )
          ],
          if (page == 0)...[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  for (var i = 1; i < Subject.length; ++i)...[
                    TextButton(
                      onPressed: (){
                        setState(() {
                          subject = Subject[i];
                          if (Detail[i].length == 1)page = 20;
                          else page = i;
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            Subject[i],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Image.asset(
                            'assets/images/arrowright.png',
                            width: 30,
                            height: 30,
                          )
                        ],
                      )
                    ),
                    Divider(thickness: 0.5, height: 0,)
                  ]
                ],
              ),
            )
          ]
          else if (page != 20)...[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  for (var i = 1; i < Detail[page].length; ++i)...[
                    TextButton(
                        onPressed: (){
                          setState(() {
                            detail = Detail[page][i];
                            page = 20;
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              Detail[page][i],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Image.asset(
                              'assets/images/arrowright.png',
                              width: 30,
                              height: 30,
                            )
                          ],
                        )
                    ),
                    Divider(thickness: 0.5, height: 0,)
                  ]
                ],
              ),
            )
          ]
          else...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Text(
                      'Bạn đã chọn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    SizedBox(height: 15,),
                    if (!subject.contains('khác'))...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            subject,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        )
                      ),
                      SizedBox(height: 15,),
                    ],
                    if (!detail.contains('khác'))
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              detail,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          )
                      ),
                    SizedBox(height: 15,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Bạn có thể báo cáo nếu cho rằng nộ dung này vị phạm Tiêu chuẩn cộng đồng của chúng tôi. Xin lưu ý rằng đội ngũ xét duyệt của chúng tôi hiện có it nhân lực hơn',
                        style: TextStyle(
                          color: Colors.grey
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Divider(),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Text(
                    'Các bước khác mà bạn có thể thực hiện',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextButton(
                    onPressed: () async {
                      await Block(widget.post.author.id).then((value){
                        if (value == '200'){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Đã chặn người dùng"),
                          ));
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Không thể chặn người dùng"),
                          ));
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Image.asset('assets/images/blockuser.png', width: 40, height: 40,),
                        SizedBox(width: 15,),
                        Text(
                          'Chặn ${widget.post.author.username}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500
                          ),
                        )
                      ],
                    )
                  )
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    await Report().then((value){
                      if (value == '200'){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Đã báo cáo bài viết"),
                        ));
                        Navigator.pop(context);
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Không thể báo cáo bài viết"),
                        ));
                      }
                    });
                  },
                  child: Text(
                    'Gửi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}
