import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskzapp/splash_screen.dart';
import 'data/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('mybox');

  final todoDatabase = ToDoDataBase();

  runApp(MyApp(todoDatabase: todoDatabase));
}

class MyApp extends StatelessWidget {
  final ToDoDataBase todoDatabase;

  const MyApp({super.key, required this.todoDatabase});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(todoDatabase: todoDatabase), // Pass todoDatabase here
      theme: ThemeData.dark(useMaterial3: true),
    );
  }
}
