class AppleLoginState {
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;


  AppleLoginState(
      {
        this.isSubmitting,
        this.isSuccess,
        this.isFailure});

  factory AppleLoginState.initial() {
    return AppleLoginState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory AppleLoginState.loading() {
    return AppleLoginState(
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory AppleLoginState.failure() {
    return AppleLoginState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory AppleLoginState.success() {
    return AppleLoginState(
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  AppleLoginState update() {
    return copyWith(
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  AppleLoginState copyWith({
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
  }) {
    return AppleLoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }
}