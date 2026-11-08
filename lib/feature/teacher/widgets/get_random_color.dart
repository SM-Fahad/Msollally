import 'dart:math';
import 'package:flutter/material.dart';

final _random = Random();

Color getRandomColor() {
  return Color.fromARGB(
    5, // opacity
    _random.nextInt(256), // red 0-255
    _random.nextInt(256), // green 0-255
    _random.nextInt(256), // blue 0-255
  );
}
