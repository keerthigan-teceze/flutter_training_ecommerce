class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email cannot be empty";
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return "Enter a valid email";
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password cannot be empty";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  // Generic required field
  static String? validateRequired(String? value, {String fieldName = "Field"}) {
    if (value == null || value.isEmpty) return "$fieldName cannot be empty";
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {String fieldName = "Number"}) {
    if (value == null || value.isEmpty) return "$fieldName cannot be empty";
    if (int.tryParse(value) == null) return "$fieldName must be a number";
    return null;
  }
}