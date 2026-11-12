import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});
  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  // Version A: StreamBuilder
  late final Stream<int> _stream = countdown(10);

  // Version B: By hand with listen
  int _left = 10;
  late StreamSubscription<int> _sub;
  bool _showVersionA = true;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) {
      if (mounted) setState(() => _left = i);
    });
  }

  @override
  void dispose() {
    _sub.cancel(); // This is what stops the leak!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Version A (StreamBuilder)'),
                ),
                ButtonSegment(value: false, label: Text('Version B (Listen)')),
              ],
              selected: {_showVersionA},
              onSelectionChanged: (set) =>
                  setState(() => _showVersionA = set.first),
            ),
            const SizedBox(height: 50),
            if (_showVersionA)
              StreamBuilder<int>(
                stream: _stream,
                builder: (context, snapshot) {
                  return Text(
                    '${snapshot.data ?? 10}',
                    style: Theme.of(context).textTheme.displayLarge,
                  );
                },
              )
            else
              Text('$_left', style: Theme.of(context).textTheme.displayLarge),
          ],
        ),
      ),
    );
  }
}
