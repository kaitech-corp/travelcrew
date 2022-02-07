import 'package:equatable/equatable.dart';

import '../../../models/lodging_model.dart';

abstract class LodgingState extends Equatable{
  LodgingState();

  @override
  List<Object> get props => [];
}
class LodgingLoadingState extends LodgingState {}
class LodgingHasDataState extends LodgingState {
  final List<LodgingData> data;
  LodgingHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
