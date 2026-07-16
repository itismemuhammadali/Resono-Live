class ServerException implements Exception {
  final String message;

  ServerException(this.message);

  @override
  String toString() {
    return message;
  }
}

class NoDataException implements Exception {
  final String message;

  NoDataException([this.message = 'No data found.']);

  @override
  String toString() {
    return message;
  }
}

class ConflictException implements Exception {
  final String message;

  ConflictException([this.message = 'conflict found.']);

  @override
  String toString() {
    return message;
  }
}

class InvalidRequestException implements Exception {
  final String message;

  InvalidRequestException([this.message = 'Invalid Request']);

  @override
  String toString() {
    return message;
  }
}

class UnAuthException implements Exception {
  final String message;

  UnAuthException([this.message = 'Unauthenticated']);

  @override
  String toString() {
    return message;
  }
}

class ForbiddenException implements Exception {
  final String message;

  ForbiddenException([this.message = 'ForbiddenException']);

  @override
  String toString() {
    return message;
  }
}

class BadRequestException implements Exception {
  final String message;

  BadRequestException([this.message = 'BadRequestException']);

  @override
  String toString() {
    return message;
  }
}

class UnknownException implements Exception {
  final String message;

  UnknownException([this.message = 'UnknownException']);

  @override
  String toString() {
    return message;
  }
}

class NoInternetException implements Exception {
  @override
  String toString() {
    return 'No Internet Access';
  }
}

class SilentException implements Exception {
  final String message;

  SilentException([this.message = 'SilentException']);

  @override
  String toString() {
    return message;
  }
}
