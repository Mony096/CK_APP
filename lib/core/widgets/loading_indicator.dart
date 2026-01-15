import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingCircle extends StatelessWidget {
  const LoadingCircle({super.key, this.enableShadow = true});

  final bool enableShadow;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade200.withOpacity(0.0),
          ),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: enableShadow
              ? const [
                  BoxShadow(
                    color: Color.fromARGB(160, 235, 235, 235),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                    offset: Offset(0.0, 0.0),
                  )
                ]
              : null,
        ),
        child: LoadingAnimationWidget.threeArchedCircle(
          color: Colors.blue,
          size: 50,
        ),
      ),
    );
  }
}

class LoadingCircle2 extends StatelessWidget {
  const LoadingCircle2({super.key, this.enableShadow = true});

  final bool enableShadow;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // border: Border.all(
          //   color: Colors.grey.shade200.withOpacity(0.0),
          // ),
          borderRadius: BorderRadius.circular(16),
          // color: Colors.white,
          boxShadow: enableShadow
              ? const [
                  BoxShadow(
                    color: Color.fromARGB(160, 235, 235, 235),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                    offset: Offset(0.0, 0.0),
                  )
                ]
              : null,
        ),
        child: LoadingAnimationWidget.hexagonDots(
          color: const Color.fromARGB(255, 110, 115, 118),
          size: 40,
        ),
      ),
    );
  }
}
