import 'package:flutter/cupertino.dart';

class SlideLeftPageTransition extends PageRouteBuilder {
  final Widget child;

  SlideLeftPageTransition({
    required this.child,
  }) : super(
          transitionDuration: Duration(milliseconds: 400),
          reverseTransitionDuration: Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) {
            return child;
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0); // Start from the left
            const end = Offset.zero; // End at the normal position
            const curve = Curves.easeInOut; // Smooth animation curve

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}