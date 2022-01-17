
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum _AniProps { opacity, translateX }

class FlyFromLeftAnimation extends StatelessWidget {
  final int delay;
  final Widget child;

  FlyFromLeftAnimation(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<_AniProps>()
      ..add(_AniProps.opacity, Tween(begin: 0.0, end: 1.0))
      ..add(_AniProps.translateX, Tween(begin: -200.0, end: 0.0));

    return PlayAnimation<MultiTweenValues<_AniProps>>(
      delay: Duration(milliseconds: delay),
      duration: Duration(milliseconds: 300),
      tween: tween,
      child: child,
      builder: (context, child, value) => Opacity(
        opacity: value.get(_AniProps.opacity),
        child: Transform.translate(
          offset: Offset(value.get(_AniProps.translateX), 0),
          child: child,
        ),
      ),
    );
  }
}