import 'package:flutter/material.dart';

class SlideInToView extends StatelessWidget {
  SlideInToView(this.controller, this.child);
  final AnimationController controller;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(controller),
            child: SlideTransition(
              position: Tween<Offset>(begin: Offset(0, -1), end: Offset(0, 0))
                  .animate(controller),
              child: child,
            ),
          );
        },
        child: child,
    );
  }
}
