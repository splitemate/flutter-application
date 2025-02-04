import 'package:flutter/material.dart';
import 'package:splitemate/composition_root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Splitemate());
}

class Splitemate extends StatelessWidget {
  const Splitemate({super.key});

  @override
  Widget build(BuildContext context) {
    return const CompositionRoot();
  }
}
