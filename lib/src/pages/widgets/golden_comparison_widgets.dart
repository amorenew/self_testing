import 'dart:async';

import 'package:flutter/material.dart';
import 'package:self_testing/src/testing_report_models.dart';

import 'screenshot_widgets.dart';

class GoldenComparisonSection extends StatelessWidget {
  const GoldenComparisonSection({super.key, required this.comparisons});

  final List<GoldenComparison> comparisons;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        border: Border.all(color: Colors.purple.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.compare, color: Colors.purple, size: 16),
              SizedBox(width: 6),
              Text(
                'Golden Comparisons',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...comparisons
              .map((comparison) => GoldenComparisonRow(comparison: comparison)),
        ],
      ),
    );
  }
}

class GoldenComparisonRow extends StatelessWidget {
  const GoldenComparisonRow({super.key, required this.comparison});

  final GoldenComparison comparison;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GoldenStatusBadge(status: comparison.status),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comparison.id,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ),
              if (comparison.diffPercentage != null)
                Text(
                  '${comparison.diffPercentage!.toStringAsFixed(2)}% diff',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
            ],
          ),
          if (comparison.errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              comparison.errorMessage!,
              style: const TextStyle(fontSize: 11, color: Colors.red),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (comparison.actual != null)
                Expanded(
                  child: GoldenImage(
                    file: comparison.actual!,
                    label: 'Actual',
                  ),
                ),
              if (comparison.actual != null && comparison.baseline != null)
                const SizedBox(width: 8),
              if (comparison.baseline != null)
                Expanded(
                  child: GoldenImage(
                    file: comparison.baseline!,
                    label: 'Baseline',
                  ),
                ),
              if (comparison.baseline != null && comparison.diff != null)
                const SizedBox(width: 8),
              if (comparison.diff != null)
                Expanded(
                  child: GoldenImage(
                    file: comparison.diff!,
                    label: 'Diff',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class GoldenStatusBadge extends StatelessWidget {
  const GoldenStatusBadge({super.key, required this.status});

  final GoldenStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case GoldenStatus.match:
        color = Colors.green;
        label = 'MATCH';
      case GoldenStatus.mismatch:
        color = Colors.red;
        label = 'MISMATCH';
      case GoldenStatus.baselineCreated:
        color = Colors.blue;
        label = 'CREATED';
      case GoldenStatus.baselineUpdated:
        color = Colors.orange;
        label = 'UPDATED';
      case GoldenStatus.error:
        color = Colors.red;
        label = 'ERROR';
      case GoldenStatus.unknown:
        color = Colors.grey;
        label = 'UNKNOWN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }
}

class GoldenImage extends StatelessWidget {
  const GoldenImage({super.key, required this.file, required this.label});

  final ReportScreenshot file;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: file.exists
          ? () {
              unawaited(
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FullScreenImage(
                      file: file.file,
                      title: label,
                    ),
                  ),
                ),
              );
            }
          : null,
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            clipBehavior: Clip.antiAlias,
            child: file.exists
                ? Image.file(
                    file.file,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  )
                : const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
