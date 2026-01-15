import 'package:flutter/material.dart';

enum PlayerEnum {
  x(Icons.close),
  o(Icons.radio_button_unchecked),
  none(Icons.question_mark);

  final IconData value;

  const PlayerEnum(this.value);
}
