import 'package:flutter_test/flutter_test.dart';

class Counter {
  int value = 0;

  void increment() => value++;
  void decrement() => value--;
}

void main() {
  test('counter increment test', () {
    final counter = Counter();
    counter.increment();
    expect(counter.value, 1);
  });

  test('counter decrement test', () {
    final counter = Counter();
    counter.decrement();
    expect(counter.value, -1);
  });
}