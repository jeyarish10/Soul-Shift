import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:soul_shift/src/emojiSlider/repo/emoji_slider_repo.dart';
import 'package:flutter/material.dart';

part 'emoji_slider_event.dart';
part 'emoji_slider_state.dart';

class EmojiSliderBloc extends Bloc<EmojiSliderEvent, EmojiSliderState> {
  final EmojiSliderRepository _repository;
  final log = Logger();
  static const min = 0.0;
  static const max = 100.0;

  EmojiSliderBloc({required EmojiSliderRepository repository})
    : _repository = repository,
      super(EmojiSliderState(value: 50)) {
    on<InitializeEmojiSlider>(_onInitializeEmojiSliderView);
    on<UpdateSliderValueEvent>(_onUpdateEmojiSliderView);
  }

  Future<void> _onInitializeEmojiSliderView(
    InitializeEmojiSlider event,
    Emitter<EmojiSliderState> emit,
  ) async {
    log.d('InitializeEmojiSlider: ${event.initialValue}');
    final (emoji, word, color) = _repository.getEmojiInfoForValue(
      event.initialValue,
      min,
      max,
    );

    emit(state.copyWith(value: 50, emoji: emoji, word: word, color: color));
  }

  Future<void> _onUpdateEmojiSliderView(
    UpdateSliderValueEvent event,
    Emitter<EmojiSliderState> emit,
  ) async {
    final (emoji, word, color) = _repository.getEmojiInfoForValue(
      event.value,
      min,
      max,
    );

    emit(
      state.copyWith(
        value: event.value,
        emoji: emoji,
        word: word,
        color: color,
      ),
    );
  }
}
