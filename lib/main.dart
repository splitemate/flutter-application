import 'package:flutter/material.dart';
import 'package:splitemate/composition_root.dart';
import 'package:splitemate/utils/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase configuration
  await FirebaseConfig.initialize();
  
  runApp(const Splitemate());
}

class Splitemate extends StatelessWidget {
  const Splitemate({super.key});

  @override
  Widget build(BuildContext context) {
    return const CompositionRoot();
  }
}
