import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static const String LANG_CODE = 'Language';
  static Map<String, dynamic> _localizedValues = {};

  static final Map<String, String> _languageToFile = {
    'English': 'english',
    '한국어': 'korean',
  };

  static Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String langCode = prefs.getString(LANG_CODE) ?? 'English';
    await changeLanguage(langCode);
  }

  static Future<void> changeLanguage(String langCode) async {
    String fileName = _languageToFile[langCode] ?? 'english';
    String jsonContent = await rootBundle.loadString('assets/lang/$fileName.json');
    _localizedValues = json.decode(jsonContent);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANG_CODE, langCode);
  }

  static String translate(String key) {
    return _localizedValues[key] ?? key;
  }

  static List<String> get supportedLanguages => _languageToFile.keys.toList();
}