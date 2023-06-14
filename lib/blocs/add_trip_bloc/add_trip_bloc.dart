import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/validators.dart';
import '../../features/Trip_Management/logic/logic.dart';
import '../../models/trip_model/trip_model.dart';
import '../../services/database.dart';
import 'add_trip_event.dart';
import 'add_trip_state.dart';

class AddTripBloc extends Bloc<AddTripEvent, AddTripState> {
  AddTripBloc() : super(AddTripState.initial()) {
    on<AddTripNameChange>((AddTripNameChange event,
            Emitter<AddTripState> emit) async =>
        emit(state.update(isTripNameValid: isTripNameValid(event.tripName))));
    on<AddTripTypeChanged>(
        (AddTripTypeChanged event, Emitter<AddTripState> emit) async => emit(
            state.update(isTripTypeValid: isTripTypeValid(event.travelType))));
    on<AddTripImageAdded>(
        (AddTripImageAdded event, Emitter<AddTripState> emit) async => emit(
            state.update(
                isTripImageAdded: isTripImageValid(event.urlToImage))));
    on<AddTripButtonPressed>(
        (AddTripButtonPressed event, Emitter<AddTripState> emit) async {
            emit(AddTripState.loading());
            try {
              addNewTripData(
                Trip(
                  accessUsers: <String>[userService.currentUserID],
                  comment: event.comment,
                  endDateTimeStamp: event.endDateTimestamp,
                  startDateTimeStamp: event.startDateTimestamp,
                  ispublic: event.ispublic,
                  location: event.location,
                  travelType: event.travelType,
                  tripGeoPoint: event.tripGeoPoint ?? const GeoPoint(0, 0),
                  tripName: event.tripName,
                  ownerID: userService.currentUserID,
                  displayName: '',
                  dateCreatedTimeStamp: DateTime.now(),
                  urlToImage: '',
                  documentId: '',
                  favorite: <String>[],
                ),
                event.urlToImage,
              );
              emit(AddTripState.success());
            } catch (_) {
              emit(AddTripState.failure());
            }
    });
  }
}
