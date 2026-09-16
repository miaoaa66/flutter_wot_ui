import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'wot_upload.dart';

/// 基于 `dart:io` 的 multipart/form-data 上传实现（仅 native 平台：Android/iOS/桌面）。
///
/// 由 `wot_upload.dart` 通过条件导入选择；web 平台走 `wot_upload_unsupported.dart`。
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
  final client = HttpClient();
  try {
    final req = await client.postUrl(uri);
    header?.forEach((k, v) => req.headers.set(k, v));

    final boundary = 'wotBoundary${DateTime.now().microsecondsSinceEpoch}';
    req.headers.set(
      HttpHeaders.contentTypeHeader,
      'multipart/form-data; boundary=$boundary',
    );

    // 手工拼装 multipart 报文体，便于统计真实发送字节数。
    final body = <int>[];
    void write(String s) => body.addAll(utf8.encode(s));

    formData?.forEach((k, v) {
      write('--$boundary\r\n');
      write('Content-Disposition: form-data; name="$k"\r\n\r\n');
      write('$v\r\n');
    });

    write('--$boundary\r\n');
    write(
        'Content-Disposition: form-data; name="$fieldName"; filename="$fileName"\r\n');
    if (contentType != null && contentType.isNotEmpty) {
      write('Content-Type: $contentType\r\n');
    }
    write('\r\n');
    body.addAll(bytes);
    write('\r\n--$boundary--\r\n');

    req.contentLength = body.length;

    // 分块写入并 flush：既让出事件循环让进度可观测，也能真实反映已发送字节。
    const int chunkSize = 64 * 1024;
    var sent = 0;
    while (sent < body.length) {
      final end =
          (sent + chunkSize) > body.length ? body.length : sent + chunkSize;
      req.add(body.sublist(sent, end));
      sent = end;
      onProgress(sent * 100.0 / body.length);
      await req.flush();
    }

    final resp = await req.close();
    final text = await resp.transform(utf8.decoder).join();
    return WotUploadResponse(statusCode: resp.statusCode, body: text);
  } on SocketException catch (e) {
    return WotUploadResponse(statusCode: 0, error: '网络错误：${e.message}');
  } catch (e) {
    return WotUploadResponse(statusCode: 0, error: '$e');
  } finally {
    client.close(force: true);
  }
}
