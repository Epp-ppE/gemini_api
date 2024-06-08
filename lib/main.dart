import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemini_api/screens/homepage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  try {
    final file = File('.env');
    if (await file.exists()) {
      final contents = await file.readAsString();
      print('File Contents: $contents');  // Log the contents to ensure it's being read
    } else {
      print('The .env file does not exist');
    }
  } catch (e) {
    print('Error reading .env file: $e');
  }

  await dotenv.load(fileName: ".env");  
  // fix the screen orientation to portrait
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xff0064FF),
          primary: Color(0xff4890FF),
          secondary: Color(0xffF5F5F5),
          tertiary: Color(0xff0064FF),
        ),
        useMaterial3: true,
        primaryColor: Color(0xff0064FF),
        secondaryHeaderColor: Color(0xffF5F5F5),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xff0064FF),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xff0064FF),
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
      home: Homepage(),
    );
  }
}

