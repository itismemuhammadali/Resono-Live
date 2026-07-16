
import 'package:vibe_swipe/src/core/services/network_service/entities/file_entity.dart';

import '../network_service/entities/loader_entity.dart';

abstract class BaseApiService {
  Future requestGET({required ApiRouteEntity apiRoute, required Map<String, String>? headers});

  Future requestPOST({required ApiRouteEntity apiRoute, Object? body, Map<String, String>? headers});

  Future requestPUT({required ApiRouteEntity apiRoute, Object? body, required Map<String, String>? headers});

  Future requestPATCH({required ApiRouteEntity apiRoute, Object? body, required Map<String, String>? headers});

  Future requestDELETE({required ApiRouteEntity apiRoute, Object? body, required Map<String, String>? headers});

  Future requestMultiPartPOST({required String filePath, required String? fileName, required ApiRouteEntity apiRoute, Map<String, String>? body, required Map<String, String> headers});

  Future requestMultiPartPOSTMultiple({required List<FileEntity> files, required ApiRouteEntity apiRoute, Map<String, String>? data, required Map<String, String> headers});

  Future requestMultiPartPUT({required List<FileEntity> files, required ApiRouteEntity apiRoute, Map<String, String>? data, required Map<String, String> headers});
}
