import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  

  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Planner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.jpg',
              width: 300, 
              height: 300
            ),
            
            Text('Welcome to the travel planner app!'),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}