// ignore_for_file: strict_top_level_inference

import '../../utils/app_exports.dart';

mixin ResponseHandlersMixin {
  ///
  /// This is a generic function for handling the API call responses based on status code
  ///
  @protected
  Future<dynamic> filterResponse(dynamic response) async {
    try {
      if (response is StreamedResponse) {
        response = await _convertStreamedResponse(response);
      }
      if (response.statusCode == 200 || response.statusCode < 300) {
        return _onSuccess(response);
      }
      // Handle custom status code 512 (unverified account) as success
      // so the response body can be parsed and handled in the controller
      if (response.statusCode == 512) {
        return _onSuccess(response);
      }
      if (response.statusCode == 400) return _onBadRequest(response);
      if (response.statusCode == 401) return _onUnAuthorized(response);
      if (response.statusCode == 403) return _onForbidden(response);
      if (response.statusCode == 422) return _onInvalidRequest(response);
      if (response.statusCode == 404) return _onNotFound(response);
      if (response.statusCode >= 500) return _onServerError(response);
      appPrint("Unknown Error -> Status: ${response.statusCode}, Body: ${response.body}");
      return _onUnknownError();
    } on SocketException {
      throw NoInternetException();
    } catch (e) {
      rethrow;
    }
  }

  ///
  /// This will handle response on 200  status code
  ///
  dynamic _onSuccess(Response response) {
    return response.body;
  }

  ///
  /// This will handle response on 500 or above status code
  ///
  void _onServerError(Response response) {
    var error = _handleError(response.body);
    throw ServerException(error);
  }

  ///
  /// This will handle response on 401
  ///
  void _onUnAuthorized(Response response) {
    throw UnAuthException(_handleError(response.body));
  }

  ///
  /// This will handle response on 403 status code
  ///
  void _onForbidden(Response response) {
    throw ForbiddenException(_handleError(response.body));
  }

  ///
  /// This will handle response on 400 or above status code
  ///
  void _onBadRequest(Response response) {
    throw BadRequestException(_handleError(response.body));
  }

  ///
  /// This will handle unknown errors or exception
  ///
  void _onUnknownError() {
    throw UnknownException("Something went wrong");
  }

  ///
  /// This will handle response on 404 status code
  ///
  void _onNotFound(Response response) {
    throw NoDataException(_handleError(response.body));
  }

  ///
  /// This will handle response on 422 status code
  ///
  void _onInvalidRequest(Response response) {
    throw InvalidRequestException(_handleError(response.body));
  }

  String _handleError(String response) {
    try {
      final Map<String, dynamic> res = json.decode(response);
      appPrint('Response: $res');
      var error = res['message'];
      appPrint('Error: $error : ${error.runtimeType}');
      if (error is List) {
        return _extractErrors(error);
      }
      return error;
    } on FormatException catch (e) {
      appPrint('Error Parsing JSON: $e');
      throw SilentException(
        'An unexpected error occurred. Please try again later.',
      );
    }
  }

  // String _extractErrors(List errors) {

  //   String errorMsg = '';
  //   for (String error in errors) {
  //     errorMsg += errors.length > 1 ? '\n• $error\n' : '• $error';
  //   }
  //   return errorMsg;

  // }
  String _extractErrors(List errors) {
    Set<String> uniqueErrors = errors
        .map((e) => e.toString())
        .toSet(); // Convert to String explicitly
    return uniqueErrors.map((error) => '• $error').join('\n');
  }

  Future<Response> _convertStreamedResponse(
    StreamedResponse streamedResponse,
  ) async {
    final responseBytes = await streamedResponse.stream.toBytes();
    final responseString = utf8.decode(responseBytes);
    return Response(
      responseString,
      streamedResponse.statusCode,
      headers: streamedResponse.headers,
    );
  }
}
