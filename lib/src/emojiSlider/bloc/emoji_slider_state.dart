part of 'emoji_slider_bloc.dart';


class EmojiSliderState {
  final double value;
  final String? emoji;
  final String? word;
  final Color? color;
  
  EmojiSliderState({
    required this.value,
    this.emoji,
    this.word,
    this.color,
  });
  
  EmojiSliderState copyWith({
    double? value,
    String? emoji,
    String? word,
    Color? color,
  }) {
    return EmojiSliderState(
      value: value ?? this.value,
      emoji: emoji ?? this.emoji,
      word: word ?? this.word,
      color: color ?? this.color,
    );
  }
}
