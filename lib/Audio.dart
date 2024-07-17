import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:musik/login.dart';



class AudioClassifierApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AudioClassifierHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class AudioClassifierHomePage extends StatefulWidget {
  @override
  _AudioClassifierHomePageState createState() =>
      _AudioClassifierHomePageState();
}

class _AudioClassifierHomePageState extends State<AudioClassifierHomePage>
    with SingleTickerProviderStateMixin {
  String _prediction = "No prediction yet";
  bool _isLoading = false;
  String _errorMessage = "";
  bool _isPickingFile = false;

  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _buttonAnimation =
        Tween<double>(begin: 1.0, end: 1.2).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (_isPickingFile) return;
    setState(() {
      _isPickingFile = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        await _uploadFile(file);
      }
    } finally {
      setState(() {
        _isPickingFile = false;
      });
    }
  }

  Future<void> _uploadFile(File file) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _animationController.repeat();
    });

    try {
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'http://192.168.43.186:5000/predict')); // Ensure this IP is correct
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        setState(() {
          _prediction = jsonData['predicted_class'];
        });
      } else {
        setState(() {
          _errorMessage = "Error in prediction: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error uploading file: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
        _animationController.stop();
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut(); // Log out from Firebase
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Navigate to login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Classifier'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow, Colors.white], // Background colors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_isLoading)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                  ],
                ),
              if (!_isLoading && _errorMessage.isEmpty)
                Text(
                  'Prediction: $_prediction',
                  // style: Theme.of(context).textTheme.headline6,
                ),
              if (_errorMessage.isNotEmpty)
                Text(
                  '$_errorMessage',
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 20),
              AnimatedBuilder(
                animation: _buttonAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonAnimation.value,
                    child: ElevatedButton(
                      onPressed: _isPickingFile ? null : _pickFile,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 15.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic),
                          SizedBox(width: 10),
                          Text('Pick Audio File'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
