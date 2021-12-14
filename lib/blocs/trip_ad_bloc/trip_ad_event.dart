import 'package:equatable/equatable.dart';
import '../../../models/custom_objects.dart';

abstract class TripAdEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingTripAdData extends TripAdEvent {
  @override
  List<Object> get props => [];
}
class HasDataEvent extends TripAdEvent {
  final List<TripAds> data;

  HasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
