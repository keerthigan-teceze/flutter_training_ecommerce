import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/providers/session_provider.dart';
import 'package:shopping/services/storage_service.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier(ref);
});

//parsing token every time.
final currentUserIdProvider = Provider<int?>((ref) {
  final token = ref.watch(authProvider);
  if (token == null || token.isEmpty || !token.startsWith("mock_token_")) {
    return null;
  }
  final idStr = token.replaceFirst("mock_token_", "");
  return int.tryParse(idStr);
});

class AuthNotifier extends StateNotifier<String?> {
  final Ref ref;

  Future<void> _loadToken() async {
    final savedToken = await storage.readToken();
    print("AuthNotifier: Token loaded: $savedToken");
    if (savedToken != null) {
      state = savedToken; // user is logged in
      ref.read(sessionProvider.notifier).state = true;
    }else {
      // no token → user not logged in
      state = '';
      ref.read(sessionProvider.notifier).state = false;
    }
  }
  final storage = StorageService();
  AuthNotifier(this.ref) : super(null){
    _loadToken(); // load token when provider is created
  }


  // login
  Future<void> login(String email, String password) async {
    final token = await ref.read(apiServiceProvider).login(email, password);
    if (token == null) throw Exception("Invalid credentials");

    await storage.saveToken(token); // save token securely
    state = token;
  }

  // register
  Future<void> register(String email, String password) async {
    final token = await ref.read(apiServiceProvider).register(email, password);
    if (token == null) throw Exception("Email already exists");

    await storage.saveToken(token);  // save token in secure storage
    state = token;
  }


  // logout
  Future<void> logout() async {
    await storage.deleteToken();
    state = '';   // ← instead of null
    ref.read(sessionProvider.notifier).state = false;
  }
}