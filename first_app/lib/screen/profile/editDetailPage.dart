import 'package:flutter/material.dart';

class EditDetailPage extends StatelessWidget {
  late String city;
  EditDetailPage(this.city, {super.key});

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
                Navigator.pop(context);
              },
              icon: Image.asset(
                'assets/images/backarrow.png',
                width: 25,
                height: 25,
              ),
            ),
            shape: RoundedRectangleBorder(
                side: BorderSide(width: 0.1)
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.blue, width: 3),
                            borderRadius: BorderRadius.circular(10)),
                        hintText: 'Thành phố'
                    ),
                    onSubmitted: (value){
                      if (value.trim().isNotEmpty) Navigator.pop(context, value);
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
