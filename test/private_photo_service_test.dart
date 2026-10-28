import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/services/private_photo_service.dart';

void main() {
  test('private photo endpoint carries the storage reference without a token', () {
    const reference =
        'gs://app.appspot.com/private_uploads/owner/trip_images/trip-1/cover.jpg';
    expect(PrivatePhotoService.isPrivateReference(reference), isTrue);
    final endpoint = PrivatePhotoService.endpoint(
      reference,
      projectId: 'travelcrew-test',
    );
    expect(endpoint.scheme, 'https');
    expect(endpoint.host, 'us-central1-travelcrew-test.cloudfunctions.net');
    expect(endpoint.path, '/privatePhotoV3');
    expect(endpoint.queryParameters['ref'], reference);
    expect(endpoint.queryParameters.containsKey('token'), isFalse);
    expect(
      () => PrivatePhotoService.endpoint(
        'https://example.com/photo.jpg',
        projectId: 'travelcrew-test',
      ),
      throwsFormatException,
    );
  });
}
