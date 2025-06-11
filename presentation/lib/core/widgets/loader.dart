import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SpinKitThreeInOut(
          color: Theme.of(context).colorScheme.secondary,
          size: 100.0,
        ),
      ),
    );
  }
}
