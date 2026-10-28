import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/services/image_upload_policy.dart';

void main() {
  test('uploads are owner scoped, unique, and cannot escape the folder', () {
    final paths = List.generate(
      20,
      (_) => ImageUploadPolicy.objectPath(
        uid: 'owner',
        folder: 'trip_images',
        name: '../../a photo.jpg',
      ),
    );
    expect(paths.toSet(), hasLength(20));
    for (final path in paths) {
      expect(path.split('/'), hasLength(4));
      expect(path, startsWith('uploads/owner/trip_images/'));
      expect(path, endsWith('.._.._a_photo.jpg'));
    }
    expect(
      ImageUploadPolicy.objectPath(
        uid: 'owner',
        folder: 'users_profile',
        name: '',
      ),
      startsWith('uploads/owner/users_profile/'),
    );
  });

  test(
    'missing identity, path injection and unknown destinations are rejected',
    () {
      for (final uid in ['', '.', '..', 'someone/else', r'someone\else']) {
        expect(
          () => ImageUploadPolicy.objectPath(
            uid: uid,
            folder: 'trip_images',
            name: 'x',
          ),
          throwsFormatException,
        );
      }
      expect(
        () => ImageUploadPolicy.objectPath(
          uid: 'owner',
          folder: '../trip_images',
          name: 'x',
        ),
        throwsFormatException,
      );
    },
  );

  test('private uploads bind trip covers to a trip and profiles to an owner', () {
    final tripPath = ImageUploadPolicy.privateObjectPath(
      uid: 'owner',
      folder: 'trip_images',
      tripId: 'trip-1',
      name: '../cover photo.jpg',
    );
    expect(tripPath, startsWith('private_uploads/owner/trip_images/trip-1/'));
    expect(tripPath, endsWith('.._cover_photo.jpg'));
    expect(
      ImageUploadPolicy.privateObjectPath(
        uid: 'owner',
        folder: 'users_profile',
        name: 'avatar.jpg',
      ),
      startsWith('private_uploads/owner/users_profile/'),
    );
    for (final id in ['', '../trip', 'trip/other']) {
      expect(
        () => ImageUploadPolicy.privateObjectPath(
          uid: 'owner',
          folder: 'trip_images',
          tripId: id,
          name: 'cover.jpg',
        ),
        throwsFormatException,
      );
    }
    expect(
      () => ImageUploadPolicy.privateObjectPath(
        uid: 'other/owner',
        folder: 'users_profile',
        name: 'avatar.jpg',
      ),
      throwsFormatException,
    );
  });

  test(
    'content is identified from headers and obeys the exact size boundary',
    () {
      const jpeg = [0xff, 0xd8, 0xff];
      const png = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
      expect(ImageUploadPolicy.contentType(128, jpeg), 'image/jpeg');
      expect(
        ImageUploadPolicy.contentType(ImageUploadPolicy.maxBytes, png),
        'image/png',
      );
      for (final size in [-1, 0, ImageUploadPolicy.maxBytes + 1]) {
        expect(
          () => ImageUploadPolicy.contentType(size, jpeg),
          throwsFormatException,
        );
      }
      for (final header in [
        <int>[],
        '<html>not a photo</html>'.codeUnits,
        '<svg/>'.codeUnits,
      ]) {
        expect(
          () => ImageUploadPolicy.contentType(128, header),
          throwsFormatException,
        );
      }
    },
  );
}
