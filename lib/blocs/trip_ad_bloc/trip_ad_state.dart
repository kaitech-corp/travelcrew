import 'package:equatable/equatable.dart';

import '../../../models/custom_objects.dart';


abstract class TripAdState extends Equatable{
  TripAdState();

  @override
  List<Object> get props => [];
}
class TripAdLoadingState extends TripAdState {}
class TripAdHasDataState extends TripAdState {
  final List<TripAds> data;
  TripAdHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
