import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart'; // add at top

extension LangDir on AppLang {
  TextDirection get dir => this == AppLang.ar ? TextDirection.rtl : TextDirection.ltr;
}

enum AppLang { en, ar }

class AppSettings {
  static const _kKey = 'hf_key';
  static const _kModel = 'hf_model';
  static const _kLang = 'lang';
  static const _kDailyDate = 'daily_date';
  static const _kDailyQs = 'daily_qs';

  static Future<void> setKeyModel(String key, String model) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kKey, key.trim());
    await p.setString(_kModel, model.trim());
  }
  static Future<(String,String)> getKeyModel() async {
    final p = await SharedPreferences.getInstance();
    return (p.getString(_kKey) ?? '', p.getString(_kModel) ?? 'google/flan-t5-large');
  }

  static Future<void> setLang(AppLang lang) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLang, lang.name);
  }
  static Future<AppLang> getLang() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_kLang) ?? 'en';
    return s == 'ar' ? AppLang.ar : AppLang.en;
  }

  static Future<void> saveDaily(String date, int count) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kDailyDate, date);
    await p.setInt(_kDailyQs, count);
  }
  static Future<(String,int)> getDaily() async {
    final p = await SharedPreferences.getInstance();
    return (p.getString(_kDailyDate) ?? '', p.getInt(_kDailyQs) ?? 0);
  }
}
