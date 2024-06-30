import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheRepository {
  static SharedPreferences? sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveData(String key, dynamic value) async {
    final String dataStringify = json.encode(value);
    return await sharedPreferences!.setString(key, dataStringify);
  }

  static Future<bool> saveListData(String key, List<String> value) async =>
      await sharedPreferences!.setStringList(key, value);

  static dynamic getData(String key) {
    String? data = sharedPreferences!.getString(key);
    final dynamic decodedData = data != null ? json.decode(data) : null;
    return decodedData;
  }

  static Future<List<String>> getListData(String key) async =>
      sharedPreferences!.getStringList(key) ?? [];

  static Future<bool> clearAllData() async {
    return await sharedPreferences!.clear();
  }
}
