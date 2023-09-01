import 'dart:ui';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GlassBoxWidget extends StatelessWidget {
  GlassBoxWidget(
      {super.key,
      required this.width,
      required this.height,
      required this.child});

  double? width;
  double? height;
  Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 4,
                sigmaY: 4,
              ),
              child: Container(),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.withOpacity(0.1),
                        Colors.green.withOpacity(0.2)
                      ])),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
