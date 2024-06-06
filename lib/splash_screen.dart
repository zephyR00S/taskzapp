import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:taskzapp/home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 2500,
      splash: Center(
        child: SizedBox(
          height: 300, // Adjust the height as per your requirement
          width: 300, // Adjust the width as per your requirement
          child: LottieBuilder.asset(
            "assets/Lottie/Animation - 1717667985450.json",
            fit:
                BoxFit.contain, // Ensure the animation fits within the SizedBox
          ),
        ),
      ),
      nextScreen: const HomePage(),
      splashIconSize: 400,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }
}
