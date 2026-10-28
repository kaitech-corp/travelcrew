import 'package:travel_crew/utils/travel_time.dart';
import 'trip_model.dart';

class LodgingModel {
  final Map<String, String> timeOffsets;
  const LodgingModel({
    this.timeOffsets = const {},
    required this.id,
    required this.createdBy,
    this.lodgingType = '',
    this.hotelName = '',
    this.hotelAddress = '',
    this.checkInDate,
    this.checkOutDate,
    this.expensePerNight,
    this.currencyCode,
    this.revision = 0,
    this.isDeleted = false,
  });

  factory LodgingModel.fromMap(String id, Map<String, dynamic> data) =>
      LodgingModel(
        timeOffsets: TravelTime.offsets(data, ['checkInDate', 'checkOutDate']),
        id: id,
        createdBy: data['createdBy'] as String? ?? '',
        lodgingType: data['lodgingType'] as String? ?? '',
        hotelName: data['hotelName'] as String? ?? '',
        hotelAddress: data['hotelAddress'] as String? ?? '',
        checkInDate: TravelTime.tryParse(data['checkInDate'] as String?),
        checkOutDate: TravelTime.tryParse(data['checkOutDate'] as String?),
        expensePerNight: (data['expensePerNight'] as num?)?.toDouble(),
        currencyCode: data['currencyCode'] as String?,
        revision: data['revision'] as int? ?? 0,
        isDeleted: data['isDeleted'] as bool? ?? false,
      );

  factory LodgingModel.fromTrip(TripModel trip) => LodgingModel(
    id: 'legacy',
    timeOffsets: trip.timeOffsets,
    createdBy: trip.createdBy,
    lodgingType: trip.lodgingType ?? '',
    hotelName: trip.hotelName ?? '',
    hotelAddress: trip.hotelAddress ?? '',
    checkInDate: trip.checkInDate,
    checkOutDate: trip.checkOutDate,
    expensePerNight: trip.expensePerNight,
    currencyCode: trip.lodgingCurrencyCode,
  );

  final String id;
  final String createdBy;
  final String lodgingType;
  final String hotelName;
  final String hotelAddress;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final double? expensePerNight;
  final String? currencyCode;
  final int revision;
  final bool isDeleted;

  bool get hasDetails =>
      [lodgingType, hotelName, hotelAddress].any((s) => s.trim().isNotEmpty) ||
      checkInDate != null ||
      checkOutDate != null ||
      (expensePerNight ?? 0) > 0;

  Map<String, dynamic> toMap() => {
    'createdBy': createdBy,
    'lodgingType': lodgingType.trim(),
    'hotelName': hotelName.trim(),
    'hotelAddress': hotelAddress.trim(),
    'checkInDate': TravelTime.serialize(
      checkInDate,
      timeOffsets['checkInDate'],
    ),
    'checkOutDate': TravelTime.serialize(
      checkOutDate,
      timeOffsets['checkOutDate'],
    ),
    'expensePerNight': expensePerNight,
    'currencyCode': currencyCode,
    'revision': revision,
    'isDeleted': isDeleted,
  };
}
