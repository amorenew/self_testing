import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_testing/src/testing_report_models.dart';

import 'step_detail_widgets.dart';

/// Scenario card matching HTML report style
class ScenarioCard extends StatefulWidget {
  const ScenarioCard({super.key, required this.scenario});

  final ScenarioReport scenario;

  @override
  State<ScenarioCard> createState() => _ScenarioCardState();
}

class _ScenarioCardState extends State<ScenarioCard> {
  bool _isExpanded = false;
  bool _copied = false;

  Future<void> _copyToClipboard() async {
    // Copy scenario name to clipboard
    await Clipboard.setData(ClipboardData(text: widget.scenario.name));
    if (!mounted) return;
    setState(() => _copied = true);
    // Reset after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scenario = widget.scenario;
    final isPassed = scenario.passed;

    // Border colors
    final borderColor =
        isPassed ? const Color(0xFF38ef7d) : const Color(0xFFff6a00);

    return Container(
      margin: const EdgeInsets.only(bottom: 18.4), // 1.15rem
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 6,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, // 1rem
                vertical: 11.5, // 0.72rem
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPassed
                      ? [
                          const Color(0xFF11998e).withValues(alpha: 0.12),
                          const Color(0xFF38ef7d).withValues(alpha: 0.12),
                        ]
                      : [
                          const Color(0xFFee0979).withValues(alpha: 0.12),
                          const Color(0xFFff6a00).withValues(alpha: 0.12),
                        ],
                ),
                border: const Border(
                  bottom: BorderSide(
                    color: Color(0xFFe2e8f0),
                    width: 2,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  // Toggle icon (chevron down/up)
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: const Color(0xFF4c51bf),
                    size: 20,
                  ),
                  const SizedBox(width: 6.4), // 0.4rem
                  // Title
                  Text(
                    scenario.name,
                    style: const TextStyle(
                      fontSize: 16.8, // 1.05rem
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a202c),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Copy to clipboard button with emoji
                  GestureDetector(
                    onTap: _copyToClipboard,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _copied
                            ? const Color(0xFF38ef7d).withValues(alpha: 0.2)
                            : const Color(0xFFe2e8f0),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          _copied ? '✅' : '📋',
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Metrics chips
                  ScenarioChip(
                    label: 'TOTAL',
                    value: '${scenario.steps.length}',
                    variant: ChipVariant.total,
                  ),
                  const SizedBox(width: 6.4),
                  ScenarioChip(
                    label: 'PASSED',
                    value: '${scenario.passedSteps}',
                    variant: ChipVariant.passed,
                  ),
                  const SizedBox(width: 6.4),
                  ScenarioChip(
                    label: 'FAILED',
                    value: '${scenario.failedSteps}',
                    variant: ChipVariant.failed,
                  ),
                  const SizedBox(width: 6.4),
                  ScenarioChip(
                    label: 'START',
                    value: _formatTime(scenario.startedAt),
                    variant: ChipVariant.subtle,
                  ),
                  const SizedBox(width: 6.4),
                  ScenarioChip(
                    label: 'END',
                    value: _formatTime(scenario.endedAt),
                    variant: ChipVariant.subtle,
                  ),
                  const SizedBox(width: 6.4),
                  ScenarioChip(
                    label: 'DURATION',
                    value: _formatDuration(scenario.duration ?? Duration.zero),
                    variant: ChipVariant.subtle,
                  ),
                  const SizedBox(width: 12.8),
                  // Status badge
                  StatusBadge(passed: isPassed),
                ],
              ),
            ),
          ),
          // Steps (expanded)
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children:
                    scenario.steps.map((step) => StepRow(step: step)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Chip variant for scenario header
enum ChipVariant {
  subtle,
  total,
  passed,
  failed,
}

/// Small chip for scenario header metrics
class ScenarioChip extends StatelessWidget {
  const ScenarioChip({
    super.key,
    required this.label,
    required this.value,
    required this.variant,
  });

  final String label;
  final String value;
  final ChipVariant variant;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color valueColor;

    switch (variant) {
      case ChipVariant.subtle:
        backgroundColor = const Color(0xFFecf1f8).withValues(alpha: 0.8);
        valueColor = const Color(0xFF4a5568);
        break;
      case ChipVariant.total:
        backgroundColor = const Color(0xFF667eea).withValues(alpha: 0.16);
        valueColor = const Color(0xFF3c3fa3);
        break;
      case ChipVariant.passed:
        backgroundColor = const Color(0xFF38ef7d).withValues(alpha: 0.18);
        valueColor = const Color(0xFF067a4d);
        break;
      case ChipVariant.failed:
        backgroundColor = const Color(0xFFff6b6b).withValues(alpha: 0.2);
        valueColor = const Color(0xFFc53030);
        break;
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 67.2), // 4.2rem
      padding: const EdgeInsets.symmetric(
        horizontal: 5.12, // 0.32rem
        vertical: 2.56, // 0.16rem
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4c51bf).withValues(alpha: 0.12),
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
              fontWeight: FontWeight.w600,
              color: Color(0xFF5a6b82),
              letterSpacing: 0.55,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(width: 4), // spacing between label and value
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5, // 0.72rem
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}

/// Status badge with emoji
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.passed});

  final bool passed;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 72), // 4.5rem
      padding: const EdgeInsets.symmetric(
        horizontal: 6.4, // 0.4rem
        vertical: 2.88, // 0.18rem
      ),
      decoration: BoxDecoration(
        color: passed
            ? const Color(0xFF38ef7d).withValues(alpha: 0.24)
            : const Color(0xFFff6b6b).withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            passed ? '✅' : '❌',
            style: const TextStyle(fontSize: 8), // 0.85rem
          ),
          const SizedBox(width: 4),
          Text(
            passed ? 'PASSED' : 'FAILED',
            style: TextStyle(
              fontSize: 9.9, // 0.62rem
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: passed ? const Color(0xFF067a4d) : const Color(0xFFc24024),
            ),
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
