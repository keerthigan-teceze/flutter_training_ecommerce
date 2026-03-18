import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/providers/session_provider.dart';
import 'package:shopping/screens/home_screen.dart';
import 'package:shopping/widgets/toast_message.dart';
import '../providers/auth_provider.dart';
import 'product_list_screen.dart';
import 'package:shopping/utils/validators.dart'; // import validators

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add form key
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, // assign form key
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: Validators.validateEmail, // use email validator
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: Validators.validateRequired, // required validator
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  if (!_formKey.currentState!.validate()) return; // check validation

                  setState(() => isLoading = true);
                  try {
                    await ref.read(authProvider.notifier).login(
                      emailController.text,
                      passwordController.text,
                    );

                    ref.read(sessionProvider.notifier).state = true; // user logged in
                    ToastMessage.show(context, "Login Successful!");

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                  } catch (e) {
                    ToastMessage.show(context, "Invalid email or password", success: false);

                  } finally {
                    setState(() => isLoading = false);
                  }
                },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
              const SizedBox(height: 16),

              // Link to registration
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}