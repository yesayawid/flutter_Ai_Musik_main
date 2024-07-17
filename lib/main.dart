import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:musik/Audio.dart';
import 'firebase_options.dart';
import 'register.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CheckAuthState(),
      routes: {
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/audio': (context) => AudioClassifierHomePage(),
      },
      debugShowCheckedModeBanner: false, // Disable the debug banner
    );
  }
}

class CheckAuthState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null && user.emailVerified) {
      // User is logged in and email is verified
      return AudioClassifierHomePage(); // Replace with the post-login page
    } else {
      // User is not logged in or email is not verified
      return LoginPage();
    }
  }
}
