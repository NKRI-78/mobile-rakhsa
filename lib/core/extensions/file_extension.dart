import 'dart:io';

import 'package:path/path.dart' as p;

extension FileExtension on File {
  String get filename => p.basename(path);

  String get filenameWithoutExtension => p.basenameWithoutExtension(path);

  String get extension => p.extension(path);

  String get dirname => p.dirname(path);
}
