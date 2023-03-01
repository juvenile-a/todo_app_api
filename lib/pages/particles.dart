import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_flutter.dart';

class CircularParticleScreen extends StatelessWidget {
  const CircularParticleScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height + 100;
    double screenWidth = MediaQuery.of(context).size.width + 100;
    return CircularParticle(
      key: UniqueKey(),
      awayRadius: 80,
      numberOfParticles: 200,
      speedOfParticles: 1,
      height: screenHeight,
      width: screenWidth,
      onTapAnimation: true,
      particleColor: Colors.grey.withAlpha(30),
      awayAnimationDuration: const Duration(milliseconds: 600),
      maxParticleSize: 7,
      isRandSize: true,
      isRandomColor: false,
      awayAnimationCurve: Curves.easeInOutBack,
      enableHover: true,
      hoverColor: Colors.red.withAlpha(100),
      hoverRadius: 80,
      connectDots: true, //not recommended
    );
  }
}
