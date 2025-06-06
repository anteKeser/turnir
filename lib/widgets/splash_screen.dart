import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tomislav/screens/year_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  bool _isAppReady = false;

  @override
  void initState() {
    super.initState();

    // Fade in effect
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Start Firebase initialization
    initializeApp();
  }

  Future<void> initializeApp() async {
    await Firebase.initializeApp();
    setState(() {
      _isAppReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        duration: const Duration(seconds: 1),
        opacity: _opacity,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color.fromARGB(97, 39, 102, 180), // Darker Blue
                Color.fromARGB(232, 232, 232, 255), // Lighter Blue
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/slika.jpg',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isAppReady
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const YearScreen()),
                          );
                        },
                        child: const Text(
                          "Enter",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.only(bottom: 32.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
