import 'dart:io';

import 'package:flutter/foundation.dart';

const int maxLines = 500;

void main() {
  debugPrint('🔍 Checking Dart files for 500-line limit...\n');

  final violations = <String, int>{};
  final allFiles = <String, int>{};

  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  for (final file in dartFiles) {
    final lines = file.readAsLinesSync();
    final lineCount = lines.length;
    allFiles[file.path] = lineCount;

    if (lineCount > maxLines) {
      violations[file.path] = lineCount;
    }
  }

  if (violations.isEmpty) {
    debugPrint('✅ All ${allFiles.length} Dart files are under $maxLines lines!');
    debugPrint('\nLargest files:');
    final sorted = allFiles.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (var i = 0; i < 5 && i < sorted.length; i++) {
      final entry = sorted[i];
      debugPrint('   ${entry.value.toString().padLeft(3)} lines - ${entry.key}');
    }
    exit(0);
  }

  debugPrint('❌ Found ${violations.length} file(s) exceeding $maxLines lines:\n');
  final sorted = violations.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (final entry in sorted) {
    final excess = entry.value - maxLines;
    final percentage = ((entry.value / maxLines - 1) * 100).toStringAsFixed(0);
    debugPrint('   ${entry.value} lines (+$excess, +$percentage%) - ${entry.key}');
  }

  debugPrint('\n💡 Refactor these files to stay under $maxLines lines.');
  exit(1);
}
