// validators.dart
class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
  );

  static final RegExp _phoneRegExp = RegExp(r'^\d{10}$');

  static final RegExp _nameRegExp = RegExp(r'^[a-zA-Z ]+$');

  // Email Validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password Validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  // Confirm Password Validator
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Full Name Validator
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (!_nameRegExp.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    // Check if the name has at least two parts (first and last name)
    final nameParts = value.trim().split(' ');
    if (nameParts.length < 2) {
      return 'Please enter both first and last name';
    }
    if (nameParts.any((part) => part.length < 2)) {
      return 'Each name part must be at least 2 characters long';
    }
    return null;
  }

  // Phone Number Validator
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove any non-digit characters
    String cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!_phoneRegExp.hasMatch(cleanPhone)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Username Validator
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (value.length > 30) {
      return 'Username must be less than 30 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  // Age Validator
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    if (age < 18) {
      return 'You must be 18 or older';
    }
    if (age > 120) {
      return 'Please enter a valid age';
    }
    return null;
  }
}
