import 'dart:typed_data';

import 'wot_upload.dart';

/// web 平台（无 `dart:io`）的占位实现。
///
/// web 上无法使用 `dart:io` 发起 multipart 请求，因此内置上传不可用。
/// 请通过 [WotUpload.uploadMethod] 自行实现上传（例如用 `package:http` 的
/// `BrowserClient`，或 `dart:html` 的 `HttpRequest`）。
Future<WotUploadResponse> wotUploadViaHttp({
  required Uri uri,
  required Map<String, String>? header,
  required Map<String, String>? formData,
  required String fieldName,
  required String fileName,
  required Uint8List bytes,
  required String? contentType,
  required void Function(double percent) onProgress,
}) async {
  return const WotUploadResponse(
    statusCode: 0,
    error: '当前平台不支持内置上传，请提供 WotUpload.uploadMethod 自行实现。',
  );
}
