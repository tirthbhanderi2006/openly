import 'package:flutter/cupertino.dart';

class SlideUpNavigationAnimation extends PageRouteBuilder {
  final Widget child;

  SlideUpNavigationAnimation({
    required this.child,
  }) : super(
          transitionDuration: Duration(milliseconds: 400),
          reverseTransitionDuration: Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) {
            return child;
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Start from bottom
            const end = Offset.zero; // End at the normal position
            const curve = Curves.easeInOut; // Smooth animation curve
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        );
}
