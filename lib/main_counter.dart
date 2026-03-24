import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingCounterApp());
}

class ShoppingCounterApp extends StatelessWidget {
  const ShoppingCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int counter = 0;

  void increment() {
    setState(() {
      counter++;
    });
  }

  void decrement() {
    setState(() {
      counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Counter')),
      body: Center(
        child: Text(
          '$counter',
          key: const Key('counterText'),
          style: const TextStyle(fontSize: 40),
        ),
      ),

      // ✅ FIXED FAB AREA (INCREASED HEIGHT TO AVOID OVERFLOW)
      floatingActionButton: SizedBox(
        height: 130,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'inc',
              key: const Key('incrementBtn'),
              onPressed: increment,
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'dec',
              key: const Key('decrementBtn'),
              onPressed: decrement,
              child: const Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }
}