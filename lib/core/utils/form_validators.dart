class FormValidators {
  FormValidators._();

  static String? required(
    String? value, {
    required String fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  static String? fullName(String? value) {
    final requiredError = required(
      value,
      fieldName: 'Full name',
    );

    if (requiredError != null) {
      return requiredError;
    }

    if (value!.trim().length < 2) {
      return 'Full name must be at least 2 characters.';
    }

    return null;
  }

  static String? email(String? value) {
    final requiredError = required(
      value,
      fieldName: 'Email',
    );

    if (requiredError != null) {
      return requiredError;
    }

    final email = value!.trim();

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  static String? password(String? value) {
    final requiredError = required(
      value,
      fieldName: 'Password',
    );

    if (requiredError != null) {
      return requiredError;
    }

    if (value!.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final phone = value.trim();

    final phoneRegex = RegExp(
      r'^\+?[0-9]{7,15}$',
    );

    if (!phoneRegex.hasMatch(phone)) {
      return 'Please enter a valid phone number.';
    }

    return null;
  }
}