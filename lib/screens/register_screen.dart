import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/widgets/toast_message.dart';
import 'package:shopping/utils/validators.dart'; // import validators
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: Validators.validateEmail, // email validation
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: Validators.validateRequired, // required
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  if (!_formKey.currentState!.validate()) return; // validate

                  setState(() => isLoading = true);
                  try {
                    await ref.read(authProvider.notifier).register(
                      emailController.text,
                      passwordController.text,
                    );
                    ToastMessage.show(context, "Register Successful!");
                    Navigator.pushReplacementNamed(context, '/login');

                  } catch (e) {
                    ToastMessage.show(context, "Registration failed", success: false);

                  } finally {
                    setState(() => isLoading = false);
                  }
                },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Register"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}