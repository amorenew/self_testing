import 'package:flutter/material.dart';
import 'package:self_testing/src/testing_report_models.dart';

/// Header with run timestamps and metrics badges
class ReportHeader extends StatelessWidget {
  const ReportHeader({super.key, required this.data});

  final TestingReportData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17.6), // 1.1rem
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 50,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header top - Title and timestamps
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button with gradient
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.green.shade900, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: Colors.white,
                  iconSize: 35,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 4), // Small gap
              // Title with emoji
              const Text(
                '🧪',
                style: TextStyle(fontSize: 24), // 1.5rem
              ),
              const SizedBox(width: 9.6), // 0.6rem
              const Text(
                'Flutter Self Testing Report',
                style: TextStyle(
                  fontSize: 19.2, // 1.2rem
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2d3748),
                ),
              ),
              const Spacer(),
              // Timestamps
              Row(
                children: [
                  if (data.runStart != null) ...[
                    TimestampChip(
                      label: 'RUN START',
                      value: _formatTime(data.runStart!),
                    ),
                    const SizedBox(width: 6.4), // 0.4rem
                  ],
                  if (data.runEnd != null)
                    TimestampChip(
                      label: 'RUN END',
                      value: _formatTime(data.runEnd!),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12), // 0.75rem
          // Stats section
          Wrap(
            spacing: 7.2, // 0.45rem
            runSpacing: 7.2,
            children: [
              MetricBadge(
                value: '${data.scenarios.length}',
                label: 'TOTAL SCENARIOS',
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              MetricBadge(
                value: '${data.totalSteps}',
                label: 'TOTAL STEPS',
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              MetricBadge(
                value: '${data.passedSteps}',
                label: 'STEPS PASSED',
                gradient: const LinearGradient(
                  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                ),
              ),
              MetricBadge(
                value: '${data.failedSteps}',
                label: 'STEPS FAILED',
                gradient: const LinearGradient(
                  colors: [Color(0xFFee0979), Color(0xFFff6a00)],
                ),
              ),
              MetricBadge(
                value: '${data.successRate.toStringAsFixed(1)}%',
                label: 'SUCCESS RATE',
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              if (data.totalDuration != null)
                MetricBadge(
                  value: _formatDuration(data.totalDuration!),
                  label: 'TOTAL DURATION',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
              if (data.averageGoldenDiff != null)
                MetricBadge(
                  value: '${data.averageGoldenDiff!.toStringAsFixed(2)}%',
                  label: 'AVG GOLDEN DIFF',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFf6d365), Color(0xFFfda085)],
                  ),
                  textColor: const Color(0xFF553c02),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Timestamp chip for header
class TimestampChip extends StatelessWidget {
  const TimestampChip({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9.6, // 0.6rem
        vertical: 4.8, // 0.3rem
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFecf1f8).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4c51bf).withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8.3, // 0.52rem
              fontWeight: FontWeight.bold,
              color: Color(0xFF5a6b82),
              letterSpacing: 0.55,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11.2, // 0.7rem
              color: Color(0xFF1a202c),
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}

/// Metric badge with gradient background
class MetricBadge extends StatelessWidget {
  const MetricBadge({
    super.key,
    required this.value,
    required this.label,
    required this.gradient,
    this.textColor = Colors.white,
  });

  final String value;
  final String label;
  final LinearGradient gradient;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 33.6), // 2.1rem
      padding: const EdgeInsets.symmetric(
        horizontal: 12, // 0.75rem
        vertical: 6.4, // 0.4rem
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(999), // Pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 15.2, // 0.95rem
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(width: 7.2), // 0.45rem gap
          Text(
            label,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.9),
              fontSize: 9.3, // 0.58rem
              fontWeight: FontWeight.w400,
              letterSpacing: 0.85,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  if (duration.inSeconds < 1) {
    return '${duration.inMilliseconds}ms';
  }
  if (duration.inSeconds < 60) {
    return '${duration.inSeconds}.${(duration.inMilliseconds % 1000 ~/ 100)}s';
  }
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '${minutes}m ${seconds}s';
}

String _formatTime(DateTime? dateTime) {
  if (dateTime == null) return '--';
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
}
