import 'dart:async';
import 'package:flutter/material.dart';

/// A widget that creates a flashing animation effect before executing a callback.
///
/// The [FlashingWidget] wraps any child widget and provides a tap gesture that
/// triggers a flashing animation (5 flashes at 100ms intervals) before calling
/// the provided [onTap] callback.
///
/// Example:
/// ```dart
/// FlashingWidget(
///   onTap: () => print('Flashing complete!'),
///   beforeFlashing: () => print('Starting flash...'),
///   child: Container(
///     padding: EdgeInsets.all(16),
///     color: Colors.blue,
///     child: Text('Tap me!'),
///   ),
/// )
/// ```
class FlashingWidget extends StatefulWidget {
  /// The widget to be wrapped and animated
  final Widget child;

  /// Callback executed after the flashing animation completes
  final VoidCallback onTap;

  /// Optional callback executed before the flashing animation starts
  final VoidCallback? beforeFlashing;

  /// Duration of each flash cycle (default: 100ms)
  final Duration flashDuration;

  /// Number of flashes before calling onTap (default: 5)
  final int flashCount;

  /// Duration of the opacity animation (default: 200ms)
  final Duration animationDuration;

  const FlashingWidget({
    super.key,
    required this.child,
    required this.onTap,
    this.beforeFlashing,
    this.flashDuration = const Duration(milliseconds: 100),
    this.flashCount = 5,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<FlashingWidget> createState() => _FlashingWidgetState();
}

class _FlashingWidgetState extends State<FlashingWidget> {
  bool isFlashing = false;
  Timer? _flashTimer;

  void _startFlashing() {
    if (isFlashing) return;

    setState(() {
      isFlashing = true;
    });

    // Call beforeFlashing callback if provided
    widget.beforeFlashing?.call();

    int currentFlashCount = 0;
    _flashTimer = Timer.periodic(widget.flashDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        isFlashing = !isFlashing;
        currentFlashCount++;
      });

      if (currentFlashCount >= widget.flashCount) {
        timer.cancel();
        _flashTimer = null;

        // Ensure widget is visible before calling onTap
        if (mounted) {
          setState(() {
            isFlashing = false;
          });

          // Call onTap after a brief delay to ensure animation completes
          Future.delayed(widget.animationDuration, () {
            if (mounted) {
              widget.onTap();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isFlashing ? null : _startFlashing,
      child: AnimatedOpacity(
        opacity: isFlashing ? 0.0 : 1.0,
        duration: widget.animationDuration,
        child: widget.child,
      ),
    );
  }
}

/// Legacy widget name for backward compatibility
///
/// This is maintained for existing code that uses [FlashingWidgetScreen].
/// New implementations should use [FlashingWidget] directly.
@Deprecated('Use FlashingWidget instead. This will be removed in v2.0.0')
class FlashingWidgetScreen extends FlashingWidget {
  const FlashingWidgetScreen({
    super.key,
    required super.child,
    required super.onTap,
    super.beforeFlashing,
    super.flashDuration,
    super.flashCount,
    super.animationDuration,
  });
}