import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final Widget child;
  final ValueNotifier<bool> loading;
  final Color color;

  const Loading({
    Key? key,
    required this.child,
    required this.loading,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: loading,
      builder: (context, loading, _) => Stack(
        children: [
          child,
          if (loading)
            Container(
              color: Colors.black.withAlpha(200),
              child: Center(
                child: StyledProgressBar(color: color),
              ),
            ),
        ],
      ),
    );
  }
}

class StyledProgressBar extends StatelessWidget {
  final Color color;

  const StyledProgressBar({Key? key, this.color = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(color),
    );
  }
}
