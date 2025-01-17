import 'package:flutter/cupertino.dart';

class SlideRightPageTransition extends PageRouteBuilder {
  final Widget child;

  SlideRightPageTransition({
    required this.child,
  }) : super(
    transitionDuration: Duration(milliseconds: 800),
    reverseTransitionDuration: Duration(milliseconds: 800),
    pageBuilder: (context, animation, secondaryAnimation) {
      return child;
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);  // Start from the right
      const end = Offset.zero;  // End at the normal position
      const curve = Curves.easeInOut;  // Smooth animation curve

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
