import 'dart:io';

class ReportScreenshot {
  ReportScreenshot({
    required this.name,
    required this.relativePath,
    required this.file,
  });

  final String name;
  final String relativePath;
  final File file;

  bool get exists => file.existsSync();

  static ReportScreenshot? tryParse(
    dynamic raw, {
    required Directory reportDirectory,
  }) {
    if (raw == null) {
      return null;
    }
    if (raw is ReportScreenshot) {
      return raw;
    }
    if (raw is String) {
      final sanitized = _normalizeRelativePath(raw);
      if (sanitized.isEmpty) {
        return null;
      }
      return ReportScreenshot(
        name: _basename(sanitized),
        relativePath: sanitized,
        file: _resolveFile(reportDirectory, sanitized),
      );
    }
    if (raw is Map) {
      final map = raw.cast<dynamic, dynamic>();
      final relative =
          (map['relativePath'] ?? map['path'] ?? map['image'])?.toString();
      if (relative == null || relative.isEmpty) {
        final fallback = map['name']?.toString();
        if (fallback == null || fallback.isEmpty) {
          return null;
        }
        final normalized = _normalizeRelativePath(fallback);
        return ReportScreenshot(
          name: _basename(normalized),
          relativePath: normalized,
          file: _resolveFile(reportDirectory, normalized),
        );
      }
      final normalized = _normalizeRelativePath(relative);
      return ReportScreenshot(
        name: map['name']?.toString() ?? _basename(normalized),
        relativePath: normalized,
        file: _resolveFile(reportDirectory, normalized),
      );
    }
    return null;
  }
}

File _resolveFile(Directory reportDirectory, String relativePath) {
  final sanitized = _normalizeRelativePath(relativePath);
  final joined =
      '${reportDirectory.path}/${sanitized.isEmpty ? 'screenshots' : sanitized}';
  return File(joined);
}

String _normalizeRelativePath(String raw) {
  final sanitized = raw.replaceAll('\\', '/');
  final trimmed =
      sanitized.startsWith('/') ? sanitized.substring(1) : sanitized;
  if (trimmed.startsWith('report/')) {
    return trimmed.substring('report/'.length);
  }
  return trimmed;
}

String _basename(String path) {
  final sanitized = path.replaceAll('\\', '/');
  if (!sanitized.contains('/')) {
    return sanitized.isEmpty ? 'artifact' : sanitized;
  }
  final segments = sanitized.split('/');
  final candidate = segments.isNotEmpty ? segments.last : sanitized;
  return candidate.isEmpty ? 'artifact' : candidate;
}
