class Result<Success, Failure> {
  Failure? failure;
  Success? success;

  bool get isSuccess => failure == null;

  Result({this.success, this.failure});
}
