import 'package:flutter/material.dart';

import '../../../../core/theme/pw_theme.dart';
import '../../domain/step_reward.dart';

class RewardPopup extends StatefulWidget {
  const RewardPopup({super.key, required this.reward, required this.onDismiss});

  final StepReward reward;
  final VoidCallback onDismiss;

  @override
  State<RewardPopup> createState() => _RewardPopupState();
}

class _RewardPopupState extends State<RewardPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();

    Future<void>.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      _controller.reverse().then((_) {
        if (mounted) widget.onDismiss();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = Curves.elasticOut.transform(
            _controller.value.clamp(0.0, 1.0),
          );
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: _controller.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.white,
                  PWColors.yellow.withValues(alpha: 0.22),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: PWColors.yellow.withValues(alpha: 0.7),
                width: 2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: PWColors.yellow.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(widget.reward.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '⭐ You earned:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PWColors.navy.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      widget.reward.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: PWColors.navy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
