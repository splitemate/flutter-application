String? passwordValidator(String? password, [String? confirmPassword]) {
  if (password == null || password.isEmpty) {
    return 'Password is required';
  } else if (password.length < 8) {
    return 'Password must be at least 8 characters long';
  } else if (confirmPassword != null && password != confirmPassword) {
    return 'Passwords do not match';
  }
  return null;
}