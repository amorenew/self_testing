import 'package:flutter/material.dart';

/// Lightweight wrapper that provides a lazily-initialised [GlobalKey] with an
/// optional debug label. Robots and widgets can share the same key instance
/// without worrying about accidental regeneration.
class GlobalAppKey<T extends State<StatefulWidget>> {
  GlobalAppKey({this.debugLabel});

  final String? debugLabel;

  GlobalKey<T>? _cachedKey;

  /// Returns the shared [GlobalKey] instance, creating it on first access.
  GlobalKey<T> get key => _cachedKey ??= GlobalKey<T>(debugLabel: debugLabel);

  /// Returns the current key without creating a new one if it was never
  /// requested. Useful when consumers expect the key to have already been
  /// attached to a widget.
  GlobalKey<T>? get maybeCurrentKey => _cachedKey;

  /// Returns the current key, creating it when necessary so callers can rely
  /// on a non-null value.
  GlobalKey<T> get currentKey => key;

  /// Creates a fresh [GlobalKey] instance. Call this only when the previous key
  /// is no longer mounted in the widget tree.
  void regenerate() {
    _cachedKey = GlobalKey<T>(debugLabel: debugLabel);
  }
}
