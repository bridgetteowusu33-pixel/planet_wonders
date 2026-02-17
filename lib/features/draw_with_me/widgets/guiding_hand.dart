// File: lib/features/draw_with_me/widgets/guiding_hand.dart
import 'package:flutter/material.dart';

import '../engine/hand_animator.dart';

class GuidingHand extends StatefulWidget {
  const GuidingHand({
    super.key,
    required this.path,
    required this.visible,
    required this.cycle,
  });

  final Path? path;
  final bool visible;
  final int cycle;

  @override
  State<GuidingHand> createState() => _GuidingHandState();
}

class _GuidingHandState extends State<GuidingHand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final HandAnimator _handAnimator = const HandAnimator();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );
    _syncAnimationState();
  }

  @override
  void didUpdateWidget(covariant GuidingHand oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cycle != oldWidget.cycle &&
        widget.visible &&
        widget.path != null) {
      _controller
        ..reset()
        ..repeat();
    }
    _syncAnimationState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.path;
    if (path == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 240),
        opacity: widget.visible ? 1 : 0,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final pose = _handAnimator.poseAt(path, _controller.value);
            return Stack(
              children: [
                Positioned(
                  left: pose.position.dx - 16,
                  top: pose.position.dy - 16,
                  child: Transform.rotate(
                    angle: pose.radians,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.touch_app_rounded,
                        size: 22,
                        color: Color(0xFF2F3A4A),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _syncAnimationState() {
    final shouldAnimate = widget.visible && widget.path != null;
    if (shouldAnimate) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
      return;
    }
    if (_controller.isAnimating) {
      _controller.stop(canceled: false);
    }
  }
}
