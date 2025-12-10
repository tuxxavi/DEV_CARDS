import 'package:flutter/material.dart';

class DestructibleWidget extends StatefulWidget {
  final bool isDestroyed;
  final Widget child;
  const DestructibleWidget({
    super.key,
    required this.isDestroyed,
    required this.child,
  });
  @override
  State<DestructibleWidget> createState() => _DestructibleWidgetState();
}

class _DestructibleWidgetState extends State<DestructibleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _rotateAnim = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant DestructibleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDestroyed && !oldWidget.isDestroyed) {
      _controller.forward();
    } else if (!widget.isDestroyed && oldWidget.isDestroyed) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnim,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: Transform.rotate(
              angle: _rotateAnim.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
