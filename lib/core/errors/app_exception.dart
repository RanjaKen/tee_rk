/// Base failure surfaced to the UI.
///
/// Providers convert these into `AsyncValue.error`, and screens read
/// [message] instead of showing a raw stack trace.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The catalog could not be read or parsed.
class DataLoadException extends AppException {
  const DataLoadException([
    super.message = 'Unable to load the catalog. Please try again.',
  ]);
}

/// A specific item does not exist.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'This product is no longer available.']);
}
