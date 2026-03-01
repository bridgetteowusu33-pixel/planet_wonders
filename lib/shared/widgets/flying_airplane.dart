import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class FlyingAirplane extends StatefulWidget {
  const FlyingAirplane({super.key});

  @override
  State<FlyingAirplane> createState() => _FlyingAirplaneState();
}

class _FlyingAirplaneState extends State<FlyingAirplane>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  final _random = Random();
  bool _flyingRight = true;
  double _topOffset = 40;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _visible = false);
        _scheduleNext();
      }
    });
    _timer = Timer(const Duration(seconds: 3), _startFlight);
  }

  void _scheduleNext() {
    _timer?.cancel();
    final delay = 8 + _random.nextInt(5); // 8–12 seconds
    _timer = Timer(Duration(seconds: delay), _startFlight);
  }

  void _startFlight() {
    if (!mounted) return;
    setState(() {
      _flyingRight = _random.nextBool();
      _topOffset = 30 + _random.nextDouble() * 50; // 30–80 px from top
      _visible = true;
    });
    _controller.duration = Duration(seconds: 4 + _random.nextInt(3)); // 4–6s
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    const planeWidth = 72.0;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final screenWidth = MediaQuery.sizeOf(context).width;
          final t = _controller.value;
          final totalTravel = screenWidth + planeWidth * 2;
          final dx = _flyingRight
              ? -planeWidth + totalTravel * t
              : screenWidth + planeWidth - totalTravel * t;

          return Padding(
            padding: EdgeInsets.only(top: _topOffset),
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: Opacity(
                opacity: 0.85,
                child: Transform.flip(
                  flipX: !_flyingRight,
                  child: Image.asset(
                    'assets/animations/airplane.webp',
                    width: planeWidth,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
