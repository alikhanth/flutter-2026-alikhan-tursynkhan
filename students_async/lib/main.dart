import 'package:flutter/material.dart';

import 'students_screen.dart';
import 'students_future_screen.dart';
import 'countdown_screen.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen()),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice 10')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async => await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentsScreen()),
              ),
              child: const Text('By Hand (Level 2 & 5)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async => await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentsFutureScreen()),
              ),
              child: const Text('FutureBuilder (Level 3)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async => await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CountdownScreen()),
              ),
              child: const Text('Countdown (Level 4)'),
            ),
          ],
        ),
      ),
    );
  }
}
