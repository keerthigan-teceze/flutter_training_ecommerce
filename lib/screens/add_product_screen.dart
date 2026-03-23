import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shopping/utils/validators.dart';
import 'package:shopping/widgets/toast_message.dart';

import '../providers/product_provider.dart';
import '../providers/connectivity_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Column(
        children: [

          // 🔥 OFFLINE WARNING BAR
          connectivity.when(
            data: (isOnline) => !isOnline
                ? Container(
              width: double.infinity,
              color: Colors.yellow,
              padding: const EdgeInsets.all(8),
              child: const Text(
                "You are offline - saving locally",
                textAlign: TextAlign.center,
              ),
            )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Product Title",
                      ),
                      validator: Validators.validateRequired,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: "Price",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          Validators.validateNumber(
                            value,
                            fieldName: "Price",
                          ),
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            // addProduct now returns true if synced to API, false if saved to Hive
                            final wasSynced = await ref
                                .read(productActionsProvider)
                                .addProduct(
                              titleController.text,
                              int.parse(priceController.text),
                            );

                            if (mounted) {
                              ToastMessage.show(
                                context,
                                wasSynced
                                    ? "Product added successfully!"
                                    : "Saved offline (Server unreachable). Will sync later.",
                              );

                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (mounted) {
                              ToastMessage.show(context, "Error: $e");
                            }
                          }
                        }
                      },
                      child: const Text("Create Product"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}