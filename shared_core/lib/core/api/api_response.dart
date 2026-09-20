/// Generic API response envelope.
///
/// Most REST APIs wrap their payload in a common structure:
/// ```json
/// {
///   "success": true,
///   "message": "Operation successful",
///   "data": { … }
/// }
/// ```
/// This class models that envelope and makes deserialization consistent.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  final bool success;
  final String message;
  final T? data;
  final Map<String, List<String>>? errors;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      errors: (json['errors'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(
          k,
          (v as List<dynamic>).map((e) => e.toString()).toList(),
        ),
      ),
    );
  }

  /// Returns `true` when the response has data.
  bool get hasData => data != null;

  @override
  String toString() => 'ApiResponse(success: $success, message: $message, data: $data)';
}

/// Lightweight result type that wraps either [data] or an [error] message.
///
/// Prefer `Either<Failure, T>` from `dartz` in domain/presentation layers.
/// This is useful for simpler internal utility methods.
sealed class Result<T> {
  const Result();
}

final class ResultSuccess<T> extends Result<T> {
  const ResultSuccess(this.data);
  final T data;
}

final class ResultError<T> extends Result<T> {
  const ResultError(this.message, {this.exception});
  final String message;
  final Exception? exception;
}

extension ResultX<T> on Result<T> {
  bool get isSuccess => this is ResultSuccess<T>;
  bool get isError => this is ResultError<T>;

  T? get dataOrNull => isSuccess ? (this as ResultSuccess<T>).data : null;

  String? get errorOrNull => isError ? (this as ResultError<T>).message : null;

  /// Transforms [ResultSuccess] data; passes [ResultError] through unchanged.
  Result<R> map<R>(R Function(T) transform) => switch (this) {
    ResultSuccess(:final data) => ResultSuccess(transform(data)),
    ResultError(:final message, :final exception) => ResultError(
      message,
      exception: exception,
    ),
  };

  /// Calls [onSuccess] or [onError] depending on the result.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message) onError,
  }) => switch (this) {
    ResultSuccess(:final data) => onSuccess(data),
    ResultError(:final message) => onError(message),
  };
}
