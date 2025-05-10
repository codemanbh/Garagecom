class Validators {
  static String? username(String? value) {
    // username validation
    if (value == null || value.isEmpty) {
      return "Can't be empty";
    }
    if (value.length < 3) {
      return 'Must be at least 3 characters.';
    }

    if (value.length > 20) {
      return 'Must be at most 20 characters.';
    }

    if (RegExp(r'^[0-9]').hasMatch(value)) {
      return "Must start with a letter";
    }
    if (RegExp(r'[^a-zA-Z0-9_.]').hasMatch(value)) {
      return "Only letters, number, dots and underscores are allowed";
    }
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Can't be empty";
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return "Must contain at least one charachter";
    }
    if (value.length < 6) {
      return "Must be at least 6 charachters long";
    }
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return "Can't be empty";
    }
    if (RegExp(r'\d').hasMatch(value)) {
      return "Can't contain numbers";
    }
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "Can't be empty";
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      return "Unvalid email";
    }
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return "Can't be empty";
    }
    if (!RegExp(r"^(\+\d{1,3}[- ]?)?\d{8,10}$").hasMatch(value)) {
      return "Unvalid phone number";
    }
  }
}
