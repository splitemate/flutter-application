String? nameValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Name is required';
  } else if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(value)) {
    return 'Enter a valid name (letters and spaces only)';
  }
  return null;
}
