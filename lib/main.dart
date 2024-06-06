import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:taskzapp/splash_screen.dart';

void main() async {
  // init the hive
  await Hive.initFlutter();

  // open a box
  var box = await Hive.openBox('mybox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData.dark(useMaterial3: true),
    );
  }
}
