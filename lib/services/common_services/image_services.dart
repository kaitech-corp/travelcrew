import 'package:image_picker/image_picker.dart';

class ImageServices {
  Future<String> getImageGallery() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // final newPath = await _saveImageToDirectory(image.path);
      return image.path;
    } else {
      return '';
    }
  }

  getMultiImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    return images.map((image) => image.path).toList();
  }

  Future<String> getImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // final newPath = await _saveImageToDirectory(image.path);
      return image.path;
    } else {
      return '';
    }
  }

  // Future<String> _saveImageToDirectory(String imagePath) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final fileName = imagePath.split('/').last;
  //   final newPath = '${directory.path}/$fileName';
  //   final File imageFile = File(imagePath);
  //   final File newImageFile = await imageFile.copy(newPath);
  //   return newImageFile.path;
  // }
}
