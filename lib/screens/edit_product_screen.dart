import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/widgets/toast_message.dart';
import 'package:shopping/utils/validators.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  late TextEditingController titleController;
  late TextEditingController priceController;
  final _formKey = GlobalKey<FormState>(); // Add form key

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.product.title);
    priceController = TextEditingController(text: widget.product.price.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, // Assign form key
          child: Column(
            children: [

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Product Title"),
                validator: Validators.validateRequired, // Add validation
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
                  if (_formKey.currentState!.validate()) { // Validate before saving
                    await ref.read(productActionsProvider).updateProduct(
                      widget.product.id,
                      titleController.text,
                      int.parse(priceController.text),
                    );
                    ToastMessage.show(context, "Product edited successfully!");
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}