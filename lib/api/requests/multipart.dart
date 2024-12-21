import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mirea_task_proj/api/requests/http.dart';

String _randomBoundary() {
  final rand = Random();
  final codeUnits = List.generate(12, (index) {
    return rand.nextInt(26) + 97; // a-z
  });
  return "----${String.fromCharCodes(codeUnits)}";
}

Future<CustomResponse> multipartRequest(
    String method,
    Uri uri, {
      Map<String, String>? headers,
      required String fieldName,
      required String fileName,
      required List<int> fileBytes,
      String fileType = 'application/octet-stream',
    }) async {
  final client = HttpClient();
  final request = await client.openUrl(method, uri);

  // Устанавливаем заголовки
  final boundary = _randomBoundary();
  request.headers.set(HttpHeaders.contentTypeHeader, 'multipart/form-data; boundary=$boundary');

  if (headers != null) {
    headers.forEach(request.headers.set);
  }

  // Формируем тело multipart
  // Начало part
  request.write('--$boundary\r\n');
  request.write('Content-Disposition: form-data; name="$fieldName"; filename="$fileName"\r\n');
  request.write('Content-Type: $fileType\r\n\r\n');
  request.add(fileBytes);
  request.write('\r\n--$boundary--\r\n');

  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  return CustomResponse(response.statusCode, responseBody);
}
