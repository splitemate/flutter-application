String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  } else if (!RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b').hasMatch(value)) {
    return 'Enter a valid email';
  }
  return null;
}

