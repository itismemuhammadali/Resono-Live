
import 'package:vibe_swipe/src/core/services/network_service/entities/file_entity.dart';

import '../../utils/app_exports.dart';

class ApiService with ResponseHandlersMixin implements BaseApiService {
  final _http = locator<Client>();

  @override
  Future requestGET({required ApiRouteEntity apiRoute, Map<String, String>? headers}) async {
    try {
      final route = "${apiRoute.baseUrl ?? ApiRoutes.baseUrl}${apiRoute.endpoint}";
      appLog("→ GET $route");

      final response = await _http.get(Uri.parse(route), headers: headers);
      final result = await filterResponse(response);

      logResponse(method: 'GET', url: route, statusCode: response.statusCode, body: response.body);
      return result;
    } on SocketException {
      throw NoInternetException();
    } on ClientException {
      throw NoInternetException();
    } catch (e) {
      appPrint("ApiClient e: $e");
      rethrow;
    }
  }

  @override
  Future requestPOST({required ApiRouteEntity apiRoute, Object? body, Map<String, String>? headers}) async {
    try {
      final route = "${apiRoute.baseUrl ?? ApiRoutes.baseUrl}${apiRoute.endpoint}";
      appLog("→ POST $route | Payload: $body");

      final response = await _http.post(Uri.parse(route), headers: headers, body: jsonEncode(body));
      final result = await filterResponse(response);

      logResponse(method: 'POST', url: route, statusCode: response.statusCode, body: response.body);
      return result;
    } on SocketException {
      throw NoInternetException();
    } on ClientException {
      throw NoInternetException();
    } catch (e) {
      appPrint("ApiClient e: $e");
      rethrow;
    }
  }

  @override
  Future requestPUT({required ApiRouteEntity apiRoute, Object? body, Map<String, String>? headers}) async {
    try {
      final route = "${apiRoute.baseUrl ?? ApiRoutes.baseUrl}${apiRoute.endpoint}";
      appLog("→ PUT $route | Payload: $body");

      final response = await _http.put(Uri.parse(route), headers: headers, body: jsonEncode(body));
      final result = await filterResponse(response);

      logResponse(method: 'PUT', url: route, statusCode: response.statusCode, body: response.body);
      return result;
    } on SocketException {
      throw NoInternetException();
    } on ClientException {
      throw NoInternetException();
    } catch (e) {
      appPrint("ApiClient e: $e");
      rethrow;
    }
  }

  @override
  Future requestDELETE({required ApiRouteEntity apiRoute, Object? body, Map<String, String>? headers}) async {
    try {
      final route = "${apiRoute.baseUrl ?? ApiRoutes.baseUrl}${apiRoute.endpoint}";
      appLog("→ DELETE $route | Payload: $body");

      final response = await _http.delete(Uri.parse(route), headers: headers, body: body);
      final result = await filterResponse(response);

      logResponse(method: 'DELETE', url: route, statusCode: response.statusCode, body: response.body);
      return result;
    } on SocketException {
      throw NoInternetException();
    } on ClientException {
      throw NoInternetException();
    } catch (e) {
      appPrint("ApiClient e: $e");
      rethrow;
    }
  }

  @override
  Future requestPATCH({required ApiRouteEntity apiRoute, Object? body, Map<String, String>? headers}) async {
    try {
      final route = "${apiRoute.baseUrl ?? ApiRoutes.baseUrl}${apiRoute.endpoint}";
      appLog("→ PATCH $route | Payload: $body");

      final response = await _http.patch(Uri.parse(route), headers: headers, body: jsonEncode(body));
      final result = await filterResponse(response);

      logResponse(method: 'PATCH', url: route, statusCode: response.statusCode, body: response.body);
      return result;
    } on SocketException {
      throw NoInternetException();
    } on ClientException {
      throw NoInternetException();
    } catch (e) {
      appPrint("ApiClient e: $e");
      rethrow;
    }
  }

  @override
  Future requestMultiPartPOST({
    required String filePath,
    required String? fileName,
    required ApiRouteEntity apiRoute,
    Map<String, String>? body,
    required Map<String, String> headers,
  }) async {
    try {
      final route = "${apiRoute.baseUrl}${apiRoute.endpoint}";
      final mimeType = lookupMimeType(filePath);
      final mimeTypeData = mimeType?.split('/');
      var request = MultipartRequest('POST', Uri.parse(route));
      if (body != null) request.fields.addAll(body);
      request.files.add(
        await MultipartFile.fromPath(
          fileName ?? 'file',
          filePath,
          filename: filePath.split('/').last,
          contentType: mimeTypeData != null ? MediaType(mimeTypeData[0], mimeTypeData[1]) : null,
        ),
      );
      request.headers.addAll(headers);
      appLog("→ MULTIPART POST $route | File: ${filePath.split('/').last}");

      final streamedResponse = await request.send();
      final result = await filterResponse(streamedResponse);
      return result;
    } on SocketException {
      throw NoInternetException();
    } catch (e, stackTrace) {
      appPrint('[StackTrace]: $stackTrace');
      rethrow;
    }
  }

  @override
  Future requestMultiPartPOSTMultiple({
    required List<FileEntity> files,
    required ApiRouteEntity apiRoute,
    Map<String, String>? data,
    required Map<String, String> headers,
  }) async {
    try {
      final route = "${apiRoute.baseUrl ?? ApiRoutes.baseUrl}${apiRoute.endpoint}";
      var request = MultipartRequest('POST', Uri.parse(route));
      if (data != null) request.fields.addAll(data);
      for (final file in files) {
        final mimeType = lookupMimeType(file.path);
        final mimeTypeData = mimeType?.split('/');
        request.files.add(
          await MultipartFile.fromPath(
            file.name,
            file.path,
            filename: file.path.split('/').last,
            contentType: mimeTypeData != null ? MediaType(mimeTypeData[0], mimeTypeData[1]) : null,
          ),
        );
      }
      request.headers.addAll(headers);
      appLog("→ MULTIPART POST (multiple) $route | Files: ${files.map((f) => f.name).toList()}");

      final streamedResponse = await request.send();
      final result = await filterResponse(streamedResponse);
      return result;
    } on SocketException {
      throw NoInternetException();
    } catch (e, stackTrace) {
      appPrint('[StackTrace]: $stackTrace');
      rethrow;
    }
  }

  @override
  Future requestMultiPartPUT({
    required List<FileEntity> files,
    required ApiRouteEntity apiRoute,
    Map<String, String>? data,
    required Map<String, String> headers,
  }) async {
    try {
      final route = "${apiRoute.baseUrl}${apiRoute.endpoint}";
      var request = MultipartRequest('PUT', Uri.parse(route));
      if (data != null) request.fields.addAll(data);
      for (final file in files) {
        final mimeType = lookupMimeType(file.path);
        final mimeTypeData = mimeType?.split('/');
        request.files.add(
          await MultipartFile.fromPath(
            file.name,
            file.path,
            filename: file.path.split('/').last,
            contentType: mimeTypeData != null ? MediaType(mimeTypeData[0], mimeTypeData[1]) : null,
          ),
        );
      }
      request.headers.addAll(headers);
      appLog("→ MULTIPART PUT $route | Files: ${files.map((f) => f.name).toList()}");

      final streamedResponse = await request.send();
      final result = await filterResponse(streamedResponse);
      return result;
    } on SocketException {
      throw NoInternetException();
    } catch (e, stackTrace) {
      appPrint('[StackTrace]: $stackTrace');
      rethrow;
    }
  }
}
