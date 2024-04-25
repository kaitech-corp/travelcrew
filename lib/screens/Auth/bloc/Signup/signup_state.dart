class SignupState {

  SignupState(
      {required this.isEmailValid,
        required this.isPasswordValid,
        required this.isSubmitting,
        required this.isSuccess,
        required this.isFailure});

  factory SignupState.initial() {
    return SignupState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory SignupState.loading() {
    return SignupState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory SignupState.failure() {
    return SignupState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory SignupState.success() {
    return SignupState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;

  bool? get isFormValid => isEmailValid&& isPasswordValid;

  SignupState update({
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? imageAdded,
    bool? isDisplayNameValid,
  }) {
    return copyWith(
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  SignupState copyWith({
    bool?isEmailValid,
    bool?isPasswordValid,
    bool?isSubmitting,
    bool?isSuccess,
    bool?isFailure,
  }) {
    return SignupState(
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }
}
