import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/services/trip_link_service.dart';
import 'package:travel_crew/models/trip_model.dart';

void main() {
  const id = '09e04f90-1acd-4f38-828f-32a359cc25e1';
  test('trip links accept only a single UUID on the registered app route', () {
    expect(tripIdFromLink(Uri.parse('travelcrew://trips/$id')), id);
    for (final input in [
      'https://evil.example/trips/$id',
      'travelcrew://users/$id',
      'travelcrew://trips/$id/extra',
      'travelcrew://trips/$id?uid=other',
      'travelcrew://trips/%2Fusers%2Fother',
      'travelcrew://trips/not-a-trip',
      'travelcrew://user@trips/$id',
      'travelcrew://trips:80/$id',
    ]) {
      expect(tripIdFromLink(Uri.parse(input)), isNull, reason: input);
    }
  });
  test(
    'server itinerary dates and empty image list deserialize in the app',
    () {
      final trip = TripModel.fromMap({
        'id': id,
        'createdBy': 'owner',
        'destination': 'Tokyo',
        'country': 'Japan',
        'tripStartDate': '2027-04-10T00:00:00.000',
        'tripEndDate': '2027-04-12T00:00:00.000',
        'startDate': '2027-04-10T00:00:00.000',
        'endDate': '2027-04-12',
        'isPrivate': true,
        'isShared': false,
        'joinedUsers': <String>[],
        'images': <String>[],
        'tripStatus': 'upcoming',
      });
      expect(trip.tripStartDate, DateTime(2027, 4, 10));
      expect(trip.isPrivate, isTrue);
      expect(trip.images, isEmpty);
    },
  );
}
