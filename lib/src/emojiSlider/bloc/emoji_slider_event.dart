part of 'emoji_slider_bloc.dart';

sealed class EmojiSliderEvent extends Equatable {
  const EmojiSliderEvent();

  @override
  List<Object> get props => [];
}

class InitializeEmojiSlider extends EmojiSliderEvent {
  final double initialValue;

  const InitializeEmojiSlider({required this.initialValue});

  @override
  List<Object> get props => [initialValue];
}

class UpdateSliderValueEvent extends EmojiSliderEvent {
  final double value;
  const UpdateSliderValueEvent({required this.value});

  @override
  List<Object> get props => [value];
}

