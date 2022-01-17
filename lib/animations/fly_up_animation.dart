import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum _AniProps { OPACITY, TRANSLATE_Y }

class FlyUpAnimation extends StatelessWidget {
  final double duration;
  final Widget child;

  FlyUpAnimation(this.duration, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<_AniProps>()
      ..add(_AniProps.OPACITY, Tween(begin: 0.0, end: 1.0))
      ..add(_AniProps.TRANSLATE_Y, Tween(begin: 60.0, end: 0.0));

    return PlayAnimation<MultiTweenValues<_AniProps>>(
      duration: Duration(milliseconds: (duration * 1000).round()),
      delay: Duration(milliseconds: 250),
      tween: tween,
      child: child,
      builder: (context, child, value) => Opacity(
        opacity: value.get(_AniProps.OPACITY),
        child: Transform.translate(
          offset: Offset(0, value.get(_AniProps.TRANSLATE_Y)),
          child: child,
        ),
      ),
    );
  }
}
