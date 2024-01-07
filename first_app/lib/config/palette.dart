
import 'package:flutter/material.dart';

class Palette {
  InputDecoration inputBorderDecoration = InputDecoration(
      labelStyle: const TextStyle(
        color: Color(0xFF7B7878),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 3),
          borderRadius: BorderRadius.circular(15)));
}