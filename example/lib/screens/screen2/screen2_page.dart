import 'package:flutter/material.dart';
import 'package:self_testing_example/app_keys.dart';

class Screen2Page extends StatefulWidget {
  const Screen2Page({super.key});

  @override
  State<Screen2Page> createState() => _Screen2PageState();
}

class _Screen2PageState extends State<Screen2Page> {
  final TextEditingController _controller = TextEditingController();
  String _latestValue = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleTextChanged)
      ..dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {
      _latestValue = _controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: KeyedSubtree(
          key: AppKeys.screen2Title.key,
          child: const Text('Screen 2'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KeyedSubtree(
              key: AppKeys.screen2Greeting.key,
              child: const Text(
                'Hello Wold 2',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              key: AppKeys.screen2InputField.key,
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter text',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _latestValue.isEmpty
                  ? 'Nothing typed yet'
                  : 'You typed: $_latestValue',
              key: AppKeys.screen2InputPreview.key,
            ),
          ],
        ),
      ),
    );
  }
}
