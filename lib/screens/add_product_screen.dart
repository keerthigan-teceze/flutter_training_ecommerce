import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/utils/validators.dart';
import 'package:shopping/widgets/toast_message.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add a form key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form( // Wrap in a Form
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Product Title"),
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    Validators.validateNumber(value, fieldName: "Price"),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) { // Validate before submit
                    await ref.read(productActionsProvider).addProduct(
                      titleController.text,
                      int.parse(priceController.text),
                    );

                    ToastMessage.show(
                      context,
                      "Product added successfully!",
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text("Create Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}