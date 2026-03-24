import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// Check if the server is reachable
final serverStatusProvider = StreamProvider<bool>((ref) async* {
  final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 3)));
  const baseUrl = "http://192.168.1.39:3000/products"; // Using a light endpoint for health check

  while (true) {
    try {
      final response = await dio.get(baseUrl);
      if (response.statusCode == 200) {
        yield true;
      } else {
        yield false;
      }
    } catch (_) {
      yield false;
    }
    await Future.delayed(const Duration(seconds: 10)); // Check every 10 seconds
  }
});

final connectivityProvider = StreamProvider<bool>((ref) async* {
  // Emit initial state
  final initial = await Connectivity().checkConnectivity();
  yield !initial.contains(ConnectivityResult.none);

  // Emit subsequent changes
  yield* Connectivity().onConnectivityChanged.map((results) {
    return !results.contains(ConnectivityResult.none);
  });
});

// Combined provider to check overall "Online" status (Internet + Server)
final isFullyOnlineProvider = Provider<bool>((ref) {
  final internet = ref.watch(connectivityProvider).value ?? false;
  final server = ref.watch(serverStatusProvider).value ?? false;
  return internet && server;
});
