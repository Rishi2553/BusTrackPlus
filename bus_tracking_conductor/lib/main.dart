import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // auto-generated by flutterfire
import 'conductor_home_page.dart'; // your main app screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    
  );

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ConductorHomePage(),
  ));
}
