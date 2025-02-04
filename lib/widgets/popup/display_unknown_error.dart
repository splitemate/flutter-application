import 'package:flutter/material.dart';

void displayUnknownError(BuildContext context) {
  const snackBar =
  SnackBar(content: Text('Unknown error occurred, Please try again later'));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}