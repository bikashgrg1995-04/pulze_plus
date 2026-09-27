class FormValidators {
  FormValidators._();

  static String? required(
    String? value, {
    required String fieldName,
    required String errorMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }

    return null;
  }

  static String? fullName(
    String? value, {
    required String requiredMessage,
    required String minLengthMessage,
  }) {
    final requiredError = required(
      value,
      fieldName: '',
      errorMessage: requiredMessage,
    );

    if (requiredError != null) {
      return requiredError;
    }

    if (value!.trim().length < 2) {
      return minLengthMessage;
    }

    return null;
  }

  static String? email(
    String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    final requiredError = required(
      value,
      fieldName: '',
      errorMessage: requiredMessage,
    );

    if (requiredError != null) {
      return requiredError;
    }

    final email = value!.trim();

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return invalidMessage;
    }

    return null;
  }

  static String? password(
    String? value, {
    required String requiredMessage,
    required String minLengthMessage,
  }) {
    final requiredError = required(
      value,
      fieldName: '',
      errorMessage: requiredMessage,
    );

    if (requiredError != null) {
      return requiredError;
    }

    if (value!.length < 8) {
      return minLengthMessage;
    }

    return null;
  }

  static String? phone(
    String? value, {
    required String invalidMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final phone = value.trim();

    final phoneRegex = RegExp(
      r'^\+?[0-9]{7,15}$',
    );

    if (!phoneRegex.hasMatch(phone)) {
      return invalidMessage;
    }

    return null;
  }
}