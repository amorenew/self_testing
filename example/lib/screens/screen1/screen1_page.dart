import 'package:flutter/material.dart';
import 'package:self_testing_example/app_keys.dart';
import 'package:self_testing_example/screens/screen2/screen2_page.dart';

class Screen1Page extends StatelessWidget {
  const Screen1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: KeyedSubtree(
          key: AppKeys.screen1Title,
          child: const Text('Screen 1'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KeyedSubtree(
              key: AppKeys.screen1Greeting,
              child: const Text('Hello World', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: AppKeys.navigateButton,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Screen2Page()),
                );
              },
              child: const Text('Go to Screen 2'),
            ),
          ],
        ),
      ),
    );
  }
}
