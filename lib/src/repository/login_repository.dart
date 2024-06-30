import 'dart:convert';
import 'dart:io';

import '../models/user_model.dart';
import '../utils/exception.dart';

class LoginRepository {
  Future<User> authUser(Map<String, dynamic> reqData) async {
    final httpClient = HttpClient();
    var request =
        await httpClient.postUrl(Uri.parse('https://dummyjson.com/auth/login'));
    httpClient.close();
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.add(utf8.encode(jsonEncode(reqData)));
    var response = await request.close();

    Map<String, dynamic> jsonResponse =
        jsonDecode(await response.transform(utf8.decoder).join());
    if (response.statusCode == 200) {
      return User.fromJson(jsonResponse);
    } else {
      throw ServiceException(
          jsonResponse['message'] ?? 'Request failed', response.statusCode);
    }
  }
}
