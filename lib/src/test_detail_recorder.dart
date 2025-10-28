class TestDetailRecorder {
  TestDetailRecorder._();

  static List<String>? _buffer;

  static void start() {
    _buffer = <String>[];
  }

  static void add(String detail) {
    final buffer = _buffer;
    if (buffer != null) {
      buffer.add(detail);
    }
  }

  static List<String> finish() {
    final result = _buffer;
    _buffer = null;
    return result == null ? const [] : List<String>.from(result);
  }

  static bool get isRecording => _buffer != null;
}
