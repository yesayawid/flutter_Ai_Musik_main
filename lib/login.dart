import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musik/Audio.dart';
import 'register.dart';

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    void _loginWithEmailPassword() async {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        User? user = userCredential.user;

        if (user != null && user.emailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Successfully logged in: ${user.email}")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AudioClassifierHomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Please verify your email before logging in.")),
          );
          if (user != null && !user.emailVerified) {
            await user.sendEmailVerification();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      "Verification email sent. Please check your inbox.")),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to log in: ${e.message}")),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Genre Genius'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Image.asset(
              'assets/musik.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 15),
            TextFormField(
              key: Key('emailField'),
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              key: Key('passwordField'),
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              key: Key('loginButton'),
              onPressed: _loginWithEmailPassword,
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              key: Key('registerButton'),
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
