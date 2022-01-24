import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum _AniProps { OPACITY }

class FadeAnimation extends StatelessWidget {
  final double duration;
  final Widget child;

  FadeAnimation(this.duration, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<_AniProps>()..add(_AniProps.OPACITY, Tween(begin: 0.0, end: 1.0));

    return PlayAnimation<MultiTweenValues<_AniProps>>(
      delay: Duration(milliseconds: (duration * 100).round()),
      duration: Duration(milliseconds: 600),
      tween: tween,
      child: child,
      builder: (context, child, value) => Opacity(
        opacity: value.get(_AniProps.OPACITY),
        child: child,
      ),
    );
  }
}
