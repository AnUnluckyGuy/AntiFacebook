import 'package:flutter/material.dart';
import '../screen/navbar.dart' as navbar;

class MenuCustomButton extends StatelessWidget {
  final String text;
  final Image icon;

  const MenuCustomButton({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: (){},
        style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: icon
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
