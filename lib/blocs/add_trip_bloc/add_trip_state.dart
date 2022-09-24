class AddTripState {
  AddTripState(
      {required this.isTripNameValid,
      required this.isTripTypeValid,
      required this.isSubmitting,
      required this.isSuccess,
      required this.isFailure});

  factory AddTripState.initial() {
    return AddTripState(
      isTripNameValid: true,
      isTripTypeValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory AddTripState.loading() {
    return AddTripState(
      isTripNameValid: true,
      isTripTypeValid: true,
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory AddTripState.failure() {
    return AddTripState(
      isTripNameValid: true,
      isTripTypeValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory AddTripState.success() {
    return AddTripState(
      isTripNameValid: true,
      isTripTypeValid: true,
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }
  final bool isTripNameValid;
  final bool isTripTypeValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;

  bool get isFormValid => isTripNameValid && isTripTypeValid;

  AddTripState update({
    bool? isTripNameValid,
    bool? isTripTypeValid,
    bool? isTripLocationAdded,
    bool? isTripImageAdded,
    bool? isTripCommentAdded,
  }) {
    return copyWith(
      isTripNameValid: isTripNameValid,
      isTripTypeValid: isTripTypeValid,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  AddTripState copyWith({
    bool? isTripNameValid,
    bool? isTripTypeValid,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
  }) {
    return AddTripState(
      isTripNameValid: isTripNameValid ?? this.isTripNameValid,
      isTripTypeValid: isTripTypeValid ?? this.isTripTypeValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }
}
