import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class OperationCompletionViewRepositoryException implements Exception {}

class EmojiSliderRepository {
  final log = Logger();

  (String, String, Color) getEmojiInfoForValue(
    double value,
    double min,
    double max,
  ) {
    double percentage = (value - min) / (max - min);

    if (percentage < 1 / 12) {
      return ('😡', 'Angry', Colors.red.shade900);
    } else if (percentage < 2 / 12) {
      return ('🤢', 'Disgusted', Colors.red.shade700);
    } else if (percentage < 3 / 12) {
      return ('😰', 'Afraid', Colors.red.shade500);
    } else if (percentage < 4 / 12) {
      return ('😱', 'Surprised', Colors.orange.shade700);
    } else if (percentage < 5 / 12) {
      return ('☹️', 'Sad', Colors.orange.shade400);
    } else if (percentage < 6 / 12) {
      return ('😔', 'Ashamed', Colors.amber);
    } else if (percentage < 7 / 12) {
      return ('🫂', 'Trusting', Colors.lightGreen.shade400);
    } else if (percentage < 8 / 12) {
      return ('🧐', 'Intrigued', Colors.lightGreen.shade600);
    } else if (percentage < 9 / 12) {
      return ('😁', 'Joyful', Colors.green);
    } else if (percentage < 10 / 12) {
      return ('🥳', 'Proud', Colors.teal);
    } else if (percentage < 11 / 12) {
      return ('🥰', 'Loving', Colors.blue);
    } else {
      return ('😇', 'Peaceful', Colors.indigo);
    }
  }
}
