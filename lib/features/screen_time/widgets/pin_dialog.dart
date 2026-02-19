import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';

enum PinMode { set, verify }

/// Shows a 4-digit PIN entry dialog.
///
/// Returns `true` if the PIN was successfully set or verified, `false` if
/// cancelled.
Future<bool> showPinDialog({
  required BuildContext context,
  required PinMode mode,
  required bool Function(String pin) onVerify,
  required void Function(String pin) onSet,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PinDialog(
      mode: mode,
      onVerify: onVerify,
      onSet: onSet,
    ),
  );
  return result ?? false;
}

class _PinDialog extends StatefulWidget {
  const _PinDialog({
    required this.mode,
    required this.onVerify,
    required this.onSet,
  });

  final PinMode mode;
  final bool Function(String pin) onVerify;
  final void Function(String pin) onSet;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog>
    with SingleTickerProviderStateMixin {
  String _entered = '';
  String? _firstEntry; // For set mode: stores the first entry for confirmation
  String? _error;
  late final AnimationController _shakeController;

  bool get _isConfirmStep => widget.mode == PinMode.set && _firstEntry != null;

  String get _title {
    if (widget.mode == PinMode.verify) return 'Enter PIN';
    return _isConfirmStep ? 'Confirm PIN' : 'Set a PIN';
  }

  String get _subtitle {
    if (widget.mode == PinMode.verify) return 'Enter your 4-digit PIN';
    return _isConfirmStep ? 'Enter the same PIN again' : 'Choose a 4-digit PIN';
  }

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_entered.length >= 4) return;
    setState(() {
      _entered += digit;
      _error = null;
    });

    if (_entered.length == 4) {
      _handleComplete();
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    setState(() {
      _entered = _entered.substring(0, _entered.length - 1);
      _error = null;
    });
  }

  void _handleComplete() {
    if (widget.mode == PinMode.verify) {
      if (widget.onVerify(_entered)) {
        Navigator.of(context).pop(true);
      } else {
        _shakeController.forward(from: 0);
        setState(() {
          _error = 'Wrong PIN. Try again.';
          _entered = '';
        });
      }
    } else {
      // Set mode
      if (_firstEntry == null) {
        setState(() {
          _firstEntry = _entered;
          _entered = '';
        });
      } else {
        if (_entered == _firstEntry) {
          widget.onSet(_entered);
          Navigator.of(context).pop(true);
        } else {
          _shakeController.forward(from: 0);
          setState(() {
            _error = "PINs don't match. Try again.";
            _firstEntry = null;
            _entered = '';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = PWThemeColors.of(context);

    return Dialog(
      backgroundColor: tc.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: tc.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _subtitle,
              style: TextStyle(fontSize: 14, color: tc.textMuted),
            ),
            const SizedBox(height: 24),

            // PIN dots
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final dx = _shakeController.isAnimating
                    ? math.sin(_shakeController.value * math.pi * 4) * 10.0
                    : 0.0;
                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _entered.length;
                  return Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? PWColors.blue : Colors.transparent,
                      border: Border.all(
                        color: filled
                            ? PWColors.blue
                            : tc.textMuted.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(
                  color: PWColors.coral,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Numpad
            _buildNumpad(tc),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: tc.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad(PWThemeColors tc) {
    const digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Column(
      children: digits.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: 72, height: 56);
            }
            if (key == 'back') {
              return SizedBox(
                width: 72,
                height: 56,
                child: IconButton(
                  onPressed: _onBackspace,
                  icon: Icon(
                    Icons.backspace_rounded,
                    color: tc.textMuted,
                    size: 22,
                  ),
                ),
              );
            }
            return SizedBox(
              width: 72,
              height: 56,
              child: TextButton(
                onPressed: () => _onDigit(key),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  key,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: tc.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
