import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionProvider = StateProvider<bool>((ref) => false); // false = logged out