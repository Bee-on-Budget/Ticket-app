import 'dart:io';

import 'package:flutter/foundation.dart';

abstract class AppFile {
  String get name;
  int get size;
}

class WebFile implements AppFile {
  @override
  final String name;
  final Uint8List bytes;
  @override
  final int size;

  WebFile({required this.name, required this.bytes, required this.size});
}

class LocalFile implements AppFile {
  final File file;
  @override
  final String name;
  @override
  final int size;

  LocalFile({required this.file, required this.name, required this.size});
}