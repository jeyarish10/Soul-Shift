import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_shift/src/emojiSlider/bloc/emoji_slider_bloc.dart';
import 'package:soul_shift/src/emojiSlider/repo/emoji_slider_repo.dart';

/// Main entry point for the Emoji Slider feature
class EmojiSlider extends StatelessWidget {
  const EmojiSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<EmojiSliderBloc, EmojiSliderState>(
        builder: (context, state) {
          return _EmojiSliderView(
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

/// Container view for the emoji slider that handles the layout
class _EmojiSliderView extends StatelessWidget {
  final double value;
  final String emoji;
  final String word;
  final Color color;

  const _EmojiSliderView({
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
          colors: [
            Color(0xFFBBDEFB),
            Color(0xFFF3E5F5),
          ], // Using color values for better readability
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildMoodCard(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Soul Shift',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _buildMoodCard(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: EnhancedEmojiSlider(
          initialValue: value,
          currentEmoji: emoji,
          currentWord: word,
          currentColor: color,
        ),
      ),
    );
  }
}

/// The enhanced emoji slider component with animations
class EnhancedEmojiSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final String currentEmoji;
  final String currentWord;
  final Color currentColor;

  const EnhancedEmojiSlider({
    Key? key,
    this.min = 0.0,
    this.max = 100.0,
    required this.initialValue,
    required this.currentEmoji,
    required this.currentWord,
    required this.currentColor,
  }) : super(key: key);

  @override
  EnhancedEmojiSliderState createState() => EnhancedEmojiSliderState();
}

class EnhancedEmojiSliderState extends State<EnhancedEmojiSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotationAnimation;

  static const Duration _animationDuration = Duration(milliseconds: 1500);
  static const double _pulseScaleStart = 1.0;
  static const double _pulseScaleEnd = 1.2;
  static const double _rotationStart = -0.05;
  static const double _rotationEnd = 0.05;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isSmallScreen = maxWidth < 300;

        // Adjust font sizes and spacing based on available space
        final emojiSize = isSmallScreen ? 60.0 : 80.0;
        final wordFontSize = isSmallScreen ? 20.0 : 24.0;
        final spacingUnit = isSmallScreen ? 16.0 : 24.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimatedEmoji(emojiSize),
            SizedBox(height: spacingUnit),
            _buildMoodText(wordFontSize),
            SizedBox(height: spacingUnit - 8),
            _buildSlider(),
            SizedBox(height: spacingUnit),
          ],
        );
      },
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
            // Replace the emoji thumb with a standard circular thumb
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 12.0,
              elevation: 4.0,
            ),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
            trackHeight: 8.0,
            trackShape: const GradientSliderTrackShape(),
            activeTrackColor: widget.currentColor,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: widget.currentColor,
          ),
          child: Slider(
            value: state.value,
            min: widget.min,
            max: widget.max,
            // Removed divisions parameter to eliminate dots on the slider
            onChanged: (value) {
              // Dispatch event to update the value
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

/// Custom track shape with gradient and markers
class GradientSliderTrackShape extends SliderTrackShape {
  const GradientSliderTrackShape();

  static const List<Color> _gradientColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
  ];

  // Number of markers to display
  static const int _markerCount = 12;

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

    // Create gradient for track
    final gradientPaint =
        Paint()
          ..shader = const LinearGradient(
            colors: _gradientColors,
          ).createShader(trackRect);

    // Draw rounded track with gradient
    final trackRRect = RRect.fromRectAndRadius(
      trackRect,
      Radius.circular(trackRect.height / 2),
    );
    canvas.drawRRect(trackRRect, gradientPaint);

    // Draw the markers with emojis
    _drawMarkersWithEmojis(canvas, trackRect, textDirection);
  }

  void _drawMarkersWithEmojis(
    Canvas canvas,
    Rect trackRect,
    TextDirection textDirection,
  ) {
    final markerPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final markerTopPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    // Define marker height
    const double markerHeight = 10.0;
    const double emojiSize = 25.0; // Increased emoji size
    const double emojiBottomPadding = 8.0;

    // Calculate interval between markers
    final double trackWidth = trackRect.width;
    final double markerInterval = trackWidth / (_markerCount - 1);

    // Repository to get emoji data
    final emojiRepo = EmojiSliderRepository();

    // Draw markers and ALL emojis (including first and last)
    for (int i = 0; i < _markerCount; i++) {
      final double x = trackRect.left + (i * markerInterval);

      // Only draw line markers for positions 1 to 10 (skipping first and last)
      if (i > 0 && i < _markerCount - 1) {
        // Draw line marker
        canvas.drawLine(
          Offset(x, trackRect.top - markerHeight / 2),
          Offset(x, trackRect.bottom + markerHeight / 2),
          markerPaint,
        );

        // Draw small circle at the top of each marker for better visibility
        canvas.drawCircle(
          Offset(x, trackRect.top - markerHeight / 2),
          1.5,
          markerTopPaint,
        );

        // Draw small circle at the bottom of each marker for symmetry
        canvas.drawCircle(
          Offset(x, trackRect.bottom + markerHeight / 2),
          1.5,
          markerTopPaint,
        );
      }

      // Calculate normalized value for this position (between 0 and 1)
      final markerValue = i / (_markerCount - 1);

      // Get emoji for this position
      final (emoji, _, _) = emojiRepo.getEmojiInfoForValue(
        markerValue * 100, // Convert to range 0-100
        0.0,
        100.0,
      );

      // Draw emoji below the position (for ALL positions including first and last)
      final emojiPainter = TextPainter(
        text: TextSpan(
          text: emoji,
          style: const TextStyle(fontSize: emojiSize),
        ),
        textDirection: textDirection,
        textAlign: TextAlign.center,
      );

      emojiPainter.layout();
      final emojiOffset = Offset(
        x - emojiPainter.width / 2,
        trackRect.bottom + markerHeight + emojiBottomPadding,
      );

      emojiPainter.paint(canvas, emojiOffset);
    }
  }
}
