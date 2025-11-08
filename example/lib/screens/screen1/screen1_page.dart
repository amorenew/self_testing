import 'dart:async';

import 'package:flutter/material.dart';
import 'package:self_testing/self_testing.dart';
import 'package:self_testing_example/app_keys.dart';
import 'package:self_testing_example/screens/screen2/screen2_page.dart';

class Screen1Page extends StatelessWidget {
  const Screen1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: KeyedSubtree(
          key: AppKeys.screen1Title.key,
          child: const Text('Screen 1'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KeyedSubtree(
              key: AppKeys.screen1Greeting.key,
              child: const Text(
                'Hello World Wrong Text',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: AppKeys.navigateButton.key,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Screen2Page()),
                );
              },
              child: const Text('Go to Screen 2'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                unawaited(
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TestingReportPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.assessment),
              label: const Text('View Test Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
