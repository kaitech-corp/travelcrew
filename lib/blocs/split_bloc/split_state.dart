import 'package:equatable/equatable.dart';

import '../../../models/split_model.dart';


abstract class SplitState extends Equatable{
  SplitState();

  @override
  List<Object> get props => [];
}
class SplitLoadingState extends SplitState {}
class SplitHasDataState extends SplitState {
  final List<SplitObject> data;
  SplitHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
