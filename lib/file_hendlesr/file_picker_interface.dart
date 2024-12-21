// file_picker_interface.dart
import 'dart:typed_data';

abstract class FilePicker {
  /// Возвращает выбранное изображение в виде байтов (Uint8List).
  Future<Uint8List?> pickImage();
}