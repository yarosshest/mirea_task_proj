import 'dart:convert';
import 'dart:io';

String host = "78.136.223.100:60106";

Future<HttpClientResponse> registerUser(String username, String password) async {
  final uri = Uri.http(host, "auth/register");

  // Создаем экземпляр HttpClient
  final httpClient = HttpClient();
  final request = await httpClient.postUrl(uri);

  // Устанавливаем заголовки
  request.headers.set(HttpHeaders.acceptHeader, 'application/json');
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');

  // Устанавливаем тело запроса
  final requestBody = 'login=$username&password=$password';
  request.write(requestBody);

  // Отправляем запрос
  final response = await request.close();

  return response;
}

Future<HttpClientResponse> loginUser(String username, String password) async {
  final uri = Uri.http(host, "auth/login");

  // Создаем экземпляр HttpClient
  final httpClient = HttpClient();
  final request = await httpClient.postUrl(uri);

  // Устанавливаем заголовки
  request.headers.set(HttpHeaders.acceptHeader, 'application/json');
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');

  // Устанавливаем тело запроса
  final requestBody = 'login=$username&password=$password';
  request.write(requestBody);

  // Отправляем запрос
  final response = await request.close();

  return response;
}
