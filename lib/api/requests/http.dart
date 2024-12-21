import 'dart:io';
import 'dart:convert';

class CustomResponse {
  final int statusCode;
  final String body;

  CustomResponse(this.statusCode, this.body);
}


Future<CustomResponse> httpRequest(
    String method,
    Uri uri, {
      Map<String, String>? headers,
      String? body,
    }) async {
  final client = HttpClient();
  HttpClientRequest request = await client.openUrl(method, uri);
  request.followRedirects = true;       // Разрешить переход по 3xx
  request.maxRedirects = 50;

  // Устанавливаем заголовки
  if (headers != null) {
    headers.forEach(request.headers.set);
  }

  // Пишем тело, если оно есть
  if (body != null) {
    request.write(body);
  }

  HttpClientResponse response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  return CustomResponse(response.statusCode, responseBody);
}
