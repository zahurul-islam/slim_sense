class DataRetrievalException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  DataRetrievalException(this.message, {this.code, this.details});

  @override
  String toString() =>
      'DataRetrievalException: $message${code != null ? ' (code $code)' : ''}';
}

class DataCreationException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  DataCreationException(this.message, {this.code, this.details});

  @override
  String toString() =>
      'DataCreationException: $message${code != null ? ' (code $code)' : ''}';
}

class DataUpdateException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  DataUpdateException(this.message, {this.code, this.details});

  @override
  String toString() =>
      'DataUpdateException: $message${code != null ? ' (code $code)' : ''}';
}

class DataDeletionException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  DataDeletionException(this.message, {this.code, this.details});

  @override
  String toString() =>
      'DataDeletionException: $message${code != null ? ' (code $code)' : ''}';
}

class DataProcessingException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  DataProcessingException(this.message, {this.code, this.details});

  @override
  String toString() =>
      'DataProcessingException: $message${code != null ? ' (code $code)' : ''}';
}

class DataSyncException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  DataSyncException(this.message, {this.code, this.details});

  @override
  String toString() =>
      'DataSyncException: $message${code != null ? ' (code $code)' : ''}';
}

class AuthException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  AuthException(this.message, {this.code, this.details});

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (code $code)' : ''}';
}
