// file_picker_web.dart
import 'dart:typed_data';
import 'package:image_picker_web/image_picker_web.dart';
import 'file_picker_interface.dart';

class FilePickerWeb implements FilePicker {
  @override
  Future<Uint8List?> pickImage() async {
    // Для веба используем image_picker_web:
    return await ImagePickerWeb.getImageAsBytes();
  }
}
