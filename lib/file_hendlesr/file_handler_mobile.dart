// file_picker_mobile.dart
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'file_picker_interface.dart';

class FilePickerMobile implements FilePicker {
  @override
  Future<Uint8List?> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return await pickedFile.readAsBytes();
    }
    return null;
  }
}
