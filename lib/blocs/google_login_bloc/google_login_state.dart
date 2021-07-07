class GoogleLoginState {
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;


  GoogleLoginState(
      {
        this.isSubmitting,
        this.isSuccess,
        this.isFailure});

  factory GoogleLoginState.initial() {
    return GoogleLoginState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory GoogleLoginState.loading() {
    return GoogleLoginState(
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory GoogleLoginState.failure() {
    return GoogleLoginState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory GoogleLoginState.success() {
    return GoogleLoginState(
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  GoogleLoginState update() {
    return copyWith(
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  GoogleLoginState copyWith({
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
  }) {
    return GoogleLoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }
}