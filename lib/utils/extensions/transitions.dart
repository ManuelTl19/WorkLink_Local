import 'package:flutter/material.dart';

class Transitions {

  // Function to get the page transition animation // // // // //

  // Scale Transition
  /// Returns a [PageRoute] with a scale transition animation.
  ///
  /// The [fadeTransition] or [slideUpTransition], etc. method takes a [Widget] parameter called [page] and
  /// creates a [PageRouteBuilder] with a [pageBuilder] function that returns
  /// the [page] widget. It also defines a [transitionsBuilder] function that
  /// returns a [ScaleTransition] widget. The [ScaleTransition] widget uses the
  /// [animation] parameter to control the scale of the [child] widget.
  ///
  /// Example usage:
  /// ```dart
  /// Widget page = MyPage();
  /// Route route = Transitions.scaleTransition(page);
  /// Navigator.push(context, route);
  /// ```
  ///
  /// Inputs:
  /// - [Widget page]: The page widget that will be transitioned to.
  ///
  /// Outputs:
  /// The output of the [fadeTransition] or [slideUpTransition], etc. method is a [PageRoute] with a the desired
  /// transition animation.

  // Fade Transition
  static Route fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  // Slide Up Transition
  static Route slideUpTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  // Slide Down Transition
  static Route slideDownTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  // Slide Right Transition
  static Route slideRightTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  // Slide Left Transition
  static Route slideLeftTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }
  
  static Route scaleTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    );
  }
}