import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'package:responsive_framework/responsive_framework.dart';
import 'package:soul_shift/src/emojiSlider/bloc/emoji_slider_bloc.dart';
import 'package:soul_shift/src/emojiSlider/repo/emoji_slider_repo.dart';
import 'package:soul_shift/src/emojiSlider/view/desktop/emoji_slider_desktop.dart';

class EmojiSliderView extends StatelessWidget {
  final double data;
  final log = Logger();

  // ignore: non_constant_identifier_names
  EmojiSliderView({super.key, this.data = 50.0});

  @override
  Widget build(BuildContext context) {
    log.d('event');
    return BlocProvider(
      create:
          (_) =>
              EmojiSliderBloc(repository: EmojiSliderRepository())
                ..add(InitializeEmojiSlider(initialValue: data)),
      child:
          ResponsiveValue<Widget>(
            context,
            defaultValue: EmojiSlider(),
            conditionalValues: [
              Condition.equals(name: TABLET, value: EmojiSlider()),
              Condition.smallerThan(name: MOBILE, value: EmojiSlider()),
            ],
          ).value,
    );
  }
}
