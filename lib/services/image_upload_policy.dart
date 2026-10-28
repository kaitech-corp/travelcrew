import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

/// Shared client policy; Storage rules independently enforce path ownership,
/// content-type and size. Header detection is not server-side content scanning.
class ImageUploadPolicy {
  static const maxBytes = 20 * 1024 * 1024;
  static const folders = {'trip_images', 'users_profile'};
  static const contentTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
    'image/heic',
    'image/heif',
  };

  static String objectPath({
    required String uid,
    required String folder,
    required String name,
  }) {
    if (uid.isEmpty ||
        uid.contains('/') ||
        uid.contains('\\') ||
        uid == '.' ||
        uid == '..') {
      throw const FormatException('Sign in before uploading an image.');
    }
    if (!folders.contains(folder)) {
      throw const FormatException('Unsupported image destination.');
    }
    final safeName = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final suffix =
        safeName.length > 120 ? safeName.substring(0, 120) : safeName;
    return 'uploads/$uid/$folder/${const Uuid().v4()}_$suffix';
  }

  static String privateObjectPath({
    required String uid,
    required String folder,
    required String name,
    String? tripId,
  }) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(uid) ||
        !folders.contains(folder)) {
      throw const FormatException('Unsupported image destination.');
    }
    if (folder == 'trip_images' &&
        (tripId == null ||
            !RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(tripId))) {
      throw const FormatException('Select a trip before uploading its image.');
    }
    if (folder == 'users_profile' && tripId != null) {
      throw const FormatException(
        'A profile image cannot be attached to a trip.',
      );
    }
    final safeName = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final suffix =
        safeName.length > 120 ? safeName.substring(0, 120) : safeName;
    final parent =
        folder == 'trip_images'
            ? 'private_uploads/$uid/trip_images/$tripId'
            : 'private_uploads/$uid/users_profile';
    return '$parent/${const Uuid().v4()}_$suffix';
  }

  static String contentType(int size, List<int> header) {
    if (size <= 0) throw const FormatException('This image file is empty.');
    if (size > maxBytes) {
      throw const FormatException('Choose an image no larger than 20 MB.');
    }
    final type = lookupMimeType('', headerBytes: header);
    if (!contentTypes.contains(type)) {
      throw const FormatException(
        'Choose a JPEG, PNG, WebP, GIF, HEIC or HEIF image.',
      );
    }
    return type!;
  }
}
