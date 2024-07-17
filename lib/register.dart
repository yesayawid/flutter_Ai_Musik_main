import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.blue, // Customize with desired color
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow, Colors.white], // Yellow and white colors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20), // Space above the image
              Image.asset(
                'assets/musik.png', // Replace with your image path
                width: 200,
                height: 200,
              ),
              SizedBox(height: 20), // Space between image and inputs
              // Email input
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20), // Space between inputs
              // Password input
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20), // Space between inputs
              // Confirm password input
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20), // Space between input and button
              // Register button
              ElevatedButton(
                onPressed: () async {
                  String enteredEmail = emailController.text;
                  String enteredPassword = passwordController.text;
                  String enteredConfirmPassword = confirmPasswordController.text;

                  // Check if password and confirm password match
                  if (enteredPassword == enteredConfirmPassword) {
                    try {
                      // Show loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Registering...'),
                        duration: Duration(seconds: 1), // Loading indicator duration
                        backgroundColor: Colors.blue,
                      ));

                      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: enteredEmail,
                        password: enteredPassword,
                      );

                      // Send email verification
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null && !user.emailVerified) {
                        await user.sendEmailVerification();
                        // Inform the user to check their email
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Verification email sent! Please check your email.'),
                          backgroundColor: Colors.orange,
                        ));
                      }

                      // Registration successful
                      print('Registration successful!');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Registration successful!'),
                        backgroundColor: Colors.green,
                      ));
                      Navigator.pop(context); // Navigate back after successful registration
                    } catch (e) {
                      // Handle error
                      print('Registration failed! ${e.toString()}');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Registration failed! ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  } else {
                    // Password and confirm password do not match
                    print('Registration failed! Passwords do not match.');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Registration failed! Passwords do not match.'),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 100,
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
