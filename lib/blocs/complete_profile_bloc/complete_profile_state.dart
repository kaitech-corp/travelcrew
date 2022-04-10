class CompleteProfileState {

  final bool? isSubmitting;
  final bool? isSuccess;
  final bool? isFailure;


  CompleteProfileState(
      {
        this.isSubmitting,
        this.isSuccess,
        this.isFailure});

  factory CompleteProfileState.initial() {
    return CompleteProfileState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory CompleteProfileState.loading() {
    return CompleteProfileState(
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory CompleteProfileState.failure() {
    return CompleteProfileState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory CompleteProfileState.success() {
    return CompleteProfileState(
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  CompleteProfileState update({
    bool? imageAdded,
    bool? isDisplayNameValid,
    bool? isFirstNameValid,
    bool? isLastNameValid,
  }) {
    return copyWith(
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  CompleteProfileState copyWith({
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
  }) {
    return CompleteProfileState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }
}