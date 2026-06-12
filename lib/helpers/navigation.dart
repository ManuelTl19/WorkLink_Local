import 'package:flutter/material.dart';
import '../utils/extensions/transitions.dart';

// Function to push a page to the navigator
void push(BuildContext context, Widget page, {bool replace = false, PageRouteBuilder Function(Widget)? transition}) {
  final route = transition != null ? transition(page) : Transitions.fadeTransition(page);
  
  if (replace) {
    Navigator.pushReplacement(context, route);
  } else {
    Navigator.push(context, route);
  }
}

// Function to pop the current page from the navigator
void pop(BuildContext context) {
  Navigator.pop(context);
}
