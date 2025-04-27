import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_shift/src/emojiSlider/bloc/emoji_slider_bloc.dart';

/// Mobile-optimized Emoji Slider feature
class EmojiSliderMobile extends StatelessWidget {
  const EmojiSliderMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Soul Shift',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<EmojiSliderBloc, EmojiSliderState>(
        builder: (context, state) {
          return _EmojiSliderMobileView(
            value: state.value,
            emoji: state.emoji ?? '😐',
            word: state.word ?? 'Neutral',
            color: state.color ?? Colors.amber,
          );
        },
      ),
    );
  }
}

/// Mobile-optimized container view
class _EmojiSliderMobileView extends StatelessWidget {
  final double value;
  final String emoji;
  final String word;
  final Color color;

  const _EmojiSliderMobileView({
    required this.value,
    required this.emoji,
    required this.word,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFBBDEFB), Color(0xFFF3E5F5)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildMoodCard(context),
        ),
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 24.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MobileEmojiSlider(
          initialValue: value,
          currentEmoji: emoji,
          currentWord: word,
          currentColor: color,
        ),
      ),
    );
  }
}

/// Mobile-optimized emoji slider component
class MobileEmojiSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final String currentEmoji;
  final String currentWord;
  final Color currentColor;

  const MobileEmojiSlider({
    Key? key,
    this.min = 0.0,
    this.max = 100.0,
    required this.initialValue,
    required this.currentEmoji,
    required this.currentWord,
    required this.currentColor,
  }) : super(key: key);

  @override
  MobileEmojiSliderState createState() => MobileEmojiSliderState();
}

class MobileEmojiSliderState extends State<MobileEmojiSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotationAnimation;

  static const Duration _animationDuration = Duration(milliseconds: 1500);
  static const double _pulseScaleStart = 1.0;
  static const double _pulseScaleEnd = 1.15;
  static const double _rotationStart = -0.04;
  static const double _rotationEnd = 0.04;

  @override
  void initState() {
    super.initState();

    // Initialize slider with the initial value
    context.read<EmojiSliderBloc>().add(
      InitializeEmojiSlider(initialValue: widget.initialValue),
    );

    // Setup animations
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: _pulseScaleStart,
      end: _pulseScaleEnd,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(
      begin: _rotationStart,
      end: _rotationEnd,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 320;

    // Responsive sizing
    final emojiSize = isVerySmallScreen ? 48.0 : 60.0;
    final wordFontSize = isVerySmallScreen ? 18.0 : 20.0;
    final spacingUnit = isVerySmallScreen ? 12.0 : 16.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedEmoji(emojiSize),
        SizedBox(height: spacingUnit),
        _buildMoodText(wordFontSize),
        SizedBox(height: spacingUnit),
        _buildSlider(),
        SizedBox(height: spacingUnit / 2),
      ],
    );
  }

  Widget _buildAnimatedEmoji(double fontSize) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Text(
              widget.currentEmoji,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoodText(double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        widget.currentWord,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: widget.currentColor,
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return BlocBuilder<EmojiSliderBloc, EmojiSliderState>(
      builder: (context, state) {
        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: MobileEmojiSliderThumbShape(
              emoji: widget.currentEmoji,
              color: widget.currentColor,
            ),
            overlayShape: SliderComponentShape.noOverlay,
            trackHeight: 6.0,
            trackShape: const MobileGradientSliderTrackShape(),
            activeTrackColor: widget.currentColor,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: Slider(
            value: state.value,
            min: widget.min,
            max: widget.max,
            divisions: ((widget.max - widget.min) / 2).round(),
            onChanged: (value) {
              context.read<EmojiSliderBloc>().add(
                UpdateSliderValueEvent(value: value),
              );
            },
          ),
        );
      },
    );
  }

}

/// Mobile-optimized thumb shape for slider
class MobileEmojiSliderThumbShape extends SliderComponentShape {
  final String emoji;
  final Color color;
  final TextStyle emojiStyle;

  const MobileEmojiSliderThumbShape({
    required this.emoji,
    required this.color,
    this.emojiStyle = const TextStyle(fontSize: 28),
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(50, 50);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    // _drawThumbShadow(canvas, center);
    // _drawThumbGlow(canvas, center);
    // _drawThumbBackground(canvas, center);
    // _drawThumbBorder(canvas, center);
    _drawEmoji(canvas, center, textDirection, textScaleFactor);
  }

  void _drawEmoji(
    Canvas canvas,
    Offset center,
    TextDirection textDirection,
    double textScaleFactor,
  ) {
    final adjustedEmojiStyle = TextStyle(
      fontSize: (emojiStyle.fontSize ?? 28) * textScaleFactor,
    );

    final emojiPainter = TextPainter(
      text: TextSpan(text: emoji, style: adjustedEmojiStyle),
      textDirection: textDirection,
      textAlign: TextAlign.center,
    );

    emojiPainter.layout();
    final emojiOffset = Offset(
      center.dx - emojiPainter.width / 2,
      center.dy - emojiPainter.height / 2,
    );

    emojiPainter.paint(canvas, emojiOffset);
  }
}

/// Mobile-optimized track shape with gradient
class MobileGradientSliderTrackShape extends SliderTrackShape {
  const MobileGradientSliderTrackShape();

  static const List<Color> _gradientColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
  ];

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final canvas = context.canvas;
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final gradientPaint =
        Paint()
          ..shader = const LinearGradient(
            colors: _gradientColors,
          ).createShader(trackRect);

    final trackRRect = RRect.fromRectAndRadius(
      trackRect,
      Radius.circular(trackRect.height / 2),
    );
    canvas.drawRRect(trackRRect, gradientPaint);
  }
}
