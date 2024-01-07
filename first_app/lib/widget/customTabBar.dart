import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final List<IconData> icons;
  final int selected;
  final Function(int) onTap;

  const CustomTabBar({super.key, required this.icons, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorPadding: EdgeInsets.zero,
      indicator: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.blue,
            width: 3.0
          ),
        )
      ),
      tabs: icons.asMap()
          .map((i, e) => MapEntry(i, Tab(
                icon: Icon(
                  e,
                  color: i==selected?Colors.blue:Colors.black45,
                  size: 30
                )
              )
            )
          ).values
          .toList(),
      onTap: onTap,
    );
  }
}
