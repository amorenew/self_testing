DateTime? findBoundaryTimestamp(
  List<Map<String, dynamic>> scenarios,
  String field, {
  required bool findEarliest,
}) {
  DateTime? boundary;
  for (final scenario in scenarios) {
    final rawValue = scenario[field];
    if (rawValue == null) continue;
    final parsed = DateTime.tryParse(rawValue.toString());
    if (parsed == null) continue;
    if (boundary == null) {
      boundary = parsed;
      continue;
    }
    final shouldReplace =
        findEarliest ? parsed.isBefore(boundary) : parsed.isAfter(boundary);
    if (shouldReplace) boundary = parsed;
  }
  return boundary;
}

String formatDateTime(String? value) {
  if (value == null || value.isEmpty) return 'N/A';
  try {
    final parsed = DateTime.parse(value).toLocal();
    return parsed.toString().split('.').first;
  } catch (_) {
    return value;
  }
}

String formatDuration(int? durationMs) {
  if (durationMs == null) return 'N/A';
  if (durationMs < 1000) return '${durationMs}ms';
  final totalSeconds = durationMs / 1000;
  if (totalSeconds < 60) return '${totalSeconds.toStringAsFixed(2)}s';
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  final secondsLabel =
      seconds >= 1 ? '${seconds.toStringAsFixed(seconds >= 10 ? 0 : 1)}s' : '';
  final minutesLabel = '${minutes}m';
  return secondsLabel.isEmpty ? minutesLabel : '$minutesLabel $secondsLabel';
}

String formatPercent(num? value) {
  if (value == null) return 'N/A';
  return '${value.toDouble().toStringAsFixed(2)}%';
}

String escapeHtml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

String escapeAttribute(String value) {
  return escapeHtml(value).replaceAll('\n', '&#10;');
}

List<Map<String, dynamic>> normalizeGoldenEntries(dynamic raw) {
  if (raw is Map) {
    return [Map<String, dynamic>.from(raw.cast<String, dynamic>())];
  }
  if (raw is Iterable) {
    return raw
        .whereType<Map>()
        .map(
            (value) => Map<String, dynamic>.from(value.cast<String, dynamic>()))
        .toList();
  }
  return const [];
}

List<Map<String, dynamic>> extractSteps(Map<String, dynamic> scenario) {
  final steps = scenario['steps'];
  if (steps is List) {
    return steps
        .map<Map<String, dynamic>>((step) {
          if (step is Map<String, dynamic>) {
            return Map<String, dynamic>.from(step);
          }
          if (step is Map) {
            return Map<String, dynamic>.from(step.cast<String, dynamic>());
          }
          return <String, dynamic>{};
        })
        .where((step) => step.isNotEmpty)
        .toList();
  }
  return const [];
}

String statusToSlug(String status) {
  final cleaned = status.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  return cleaned.toLowerCase();
}

String badgeClassForStatus(String statusSlug) {
  switch (statusSlug) {
    case 'match':
      return 'golden-match';
    case 'mismatch':
      return 'golden-mismatch';
    case 'baselinecreated':
    case 'baselineupdated':
      return 'golden-baselinecreated';
    case 'error':
      return 'golden-error-badge';
    default:
      return 'golden-baselinecreated';
  }
}

String formatGoldenStatus(String status) {
  switch (status) {
    case 'match':
      return 'Match';
    case 'mismatch':
      return 'Mismatch';
    case 'baselineCreated':
      return 'Baseline Created';
    case 'baselineUpdated':
      return 'Baseline Updated';
    case 'error':
      return 'Error';
    default:
      if (status.isEmpty) return 'Unknown';
      final spaced = status
          .replaceAll('_', ' ')
          .replaceAllMapped(
            RegExp(r'([a-z])([A-Z])'),
            (match) => '${match.group(1)} ${match.group(2)}',
          )
          .toLowerCase();
      return spaced[0].toUpperCase() + spaced.substring(1);
  }
}
