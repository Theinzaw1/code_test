import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract final class Palette {
  static const blue = Color(0xff55cce5);
  static const pink = Color(0xfff34c9d);
  static const blush = Color(0xfffcebf2);
  static const paper = Color(0xfff9f6f7);
  static const fog = Color(0xffedf0f0);
  static const ink = Color(0xff242123);
  static const orange = Color(0xffff801e);
  static const lavender = Color(0xff6560aa);
  static const gold = Color(0xfff5db83);
  static const peach = Color(0xffffead7);
  static const rose = Color(0xfff6c8da);
}

abstract final class Motion {
  static const quick = Duration(milliseconds: 180);
  static const page = Duration(milliseconds: 330);
  static const entrance = Duration(milliseconds: 550);
  static const progress = Duration(milliseconds: 1050);
  static const stagger = Duration(milliseconds: 85);
  static const carousel = Duration(seconds: 5);
  static const curve = Curves.easeOutCubic;

  static Duration use(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

abstract final class Space {
  static const gutter = 20.0;
  static const radius = 20.0;
  static const small = 8.0;
}

ThemeData get donutTheme => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Palette.fog,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Palette.blue,
    primary: Palette.blue,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: Palette.ink,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w900,
      height: 1.08,
    ),
    titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
    titleMedium: TextStyle(fontWeight: FontWeight.w800),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Palette.blue, width: 2),
    ),
  ),
);

final _numberFormat = NumberFormat.decimalPattern('en');
String number(int value) => _numberFormat.format(value);
String mmk(int value) => '${number(value)} MMK';

class FoodImage extends StatelessWidget {
  const FoodImage(this.image, {super.key, this.fit = BoxFit.cover});
  final String image;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/$image.webp',
    width: double.infinity,
    height: double.infinity,
    fit: fit,
    excludeFromSemantics: true,
    frameBuilder: (context, child, frame, sync) =>
        sync || frame != null ? child : const ColoredBox(color: Palette.fog),
    errorBuilder: (context, error, stack) => const ColoredBox(
      color: Palette.fog,
      child: Center(child: Icon(Icons.broken_image_outlined)),
    ),
  );
}

class DonutButton extends StatefulWidget {
  const DonutButton(
    this.label, {
    super.key,
    this.onPressed,
    this.busy = false,
    this.color = Palette.blue,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final Color color;
  @override
  State<DonutButton> createState() => _DonutButtonState();
}

class _DonutButtonState extends State<DonutButton> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.busy;
    return Listener(
      onPointerDown: enabled ? (_) => setState(() => pressed = true) : null,
      onPointerUp: (_) => setState(() => pressed = false),
      onPointerCancel: (_) => setState(() => pressed = false),
      child: AnimatedScale(
        scale: pressed && enabled ? .96 : 1,
        duration: Motion.use(context, Motion.quick),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: widget.color,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
          onPressed: enabled ? widget.onPressed : null,
          child: AnimatedSwitcher(
            duration: Motion.use(context, Motion.quick),
            child: widget.busy
                ? const SizedBox.square(
                    dimension: 19,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.label, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class Entry extends StatelessWidget {
  const Entry({
    super.key,
    required this.index,
    required this.child,
    this.offset = 20,
  });
  final int index;
  final Widget child;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final delay = Motion.stagger.inMilliseconds * index;
    final duration = Motion.entrance.inMilliseconds + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.use(context, Duration(milliseconds: duration)),
      curve: Interval(delay / duration, 1, curve: Motion.curve),
      child: child,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, offset * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  RingPainter(
    this.progress, {
    this.color = Palette.pink,
    this.width = 10,
    this.round = true,
    this.sweep = math.pi * 2,
    this.start = -math.pi / 2,
    this.sprinkles = false,
  });
  final double progress;
  final Color color;
  final double width;
  final bool round;
  final double sweep;
  final double start;
  final bool sprinkles;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - width) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..color = Palette.fog
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = round ? StrokeCap.round : StrokeCap.butt;
    canvas.drawArc(rect, start, sweep, false, paint);
    paint.color = color;
    canvas.drawArc(rect, start, sweep * progress.clamp(0, 1), false, paint);
    if (!sprinkles) return;
    final sprinkle = Paint()
      ..color = Palette.rose
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    const count = 31;
    for (var i = 0; i < count * progress; i++) {
      final angle = start + sweep * i / count;
      final r = radius + (i % 3 - 1) * width / 4;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * r;
      canvas.drawLine(
        point,
        point + Offset(math.cos(i), math.sin(i)) * 5,
        sprinkle,
      );
    }
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.width != width ||
      old.sweep != sweep ||
      old.round != round ||
      old.start != start ||
      old.sprinkles != sprinkles;
}
