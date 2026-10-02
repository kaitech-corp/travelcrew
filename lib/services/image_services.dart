// import 'dart:io';

import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;

class ImageServices {
  Future<String> getImageGallery() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return image.path.toString();
    } else {
      return '';
    }
  }

  Future<String> getImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      return image.path.toString();
    } else {
      return '';
    }
  }

  //   Future<File?> createFileFromImageUrl(String imageUrl) async {
  //   // Get the directory to save the file
  //   final directory = await getApplicationDocumentsDirectory();
  //   final filePath = '${directory.path}/downloaded_image.jpg';

  //   // Download the image
  //   final response = await http.get(Uri.parse(imageUrl));

  //   // Check if the request was successful
  //   if (response.statusCode == 200) {
  //     // Create the file and write the image bytes to it
  //     final file = File(filePath);
  //     await file.writeAsBytes(response.bodyBytes);
  //     return file;
  //   } else {
  //     return null;
  //   }
  // }
}
