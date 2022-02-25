import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ValueListenableBuilder3<A, B, C> extends StatelessWidget {
  ValueListenableBuilder3(
    this.first,
    this.second,
    this.third, {
    Key? key,
    required this.builder,
  }) : super(key: key);

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final ValueListenable<C> third;
  final Widget Function(BuildContext context, A a, B b, C c, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (_, a, __) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, __) {
            return ValueListenableBuilder<C>(
                valueListenable: third,
                builder: (context, c, __) {
                  return builder(
                    context,
                    a,
                    b,
                    c,
                    SizedBox(),
                  );
                });
          },
        );
      },
    );
  }
}
