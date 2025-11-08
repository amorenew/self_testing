import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:self_testing/src/testing_report_models.dart';

class ScreenshotsSection extends StatelessWidget {
  const ScreenshotsSection({super.key, required this.screenshots});

  final List<ReportScreenshot> screenshots;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.photo_library, color: Colors.grey, size: 16),
              SizedBox(width: 6),
              Text(
                'Screenshots',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: screenshots
                .map(
                    (screenshot) => ScreenshotThumbnail(screenshot: screenshot))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class ScreenshotThumbnail extends StatelessWidget {
  const ScreenshotThumbnail({super.key, required this.screenshot});

  final ReportScreenshot screenshot;

  @override
  Widget build(BuildContext context) {
    if (!screenshot.exists) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.grey),
            SizedBox(height: 4),
            Text('Missing', style: TextStyle(fontSize: 10)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        unawaited(
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => FullScreenImage(
                file: screenshot.file,
                title: screenshot.name,
              ),
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade400),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.file(
          screenshot.file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  const FullScreenImage({super.key, required this.file, required this.title});

  final File file;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.file(file),
        ),
      ),
    );
  }
}
