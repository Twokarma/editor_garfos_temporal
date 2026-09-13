import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GraphStorageService {
  static const String _prefsKey = "saved_graphs";

  Future<Map<String, dynamic>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _writeAll(Map<String, dynamic> all) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(all));
  }

  Future<List<String>> listNames() async {
    final all = await _readAll();
    final names = all.keys.toList();
    names.sort();
    return names;
  }

  Future<bool> exists(String name) async {
      final all = await _readAll();
      return all.containsKey(name);
  }

  Future<void> save(String name, Map<String, dynamic> jsonGraph) async{
    final all = await _readAll();
    all[name] = jsonGraph;
    _writeAll(all);
  }

  Future<Map<String, dynamic>?> load(String name) async{
    final all = await _readAll();
    final entry = all[name];
    if (entry == null) return null;
    return entry as Map<String, dynamic>;
  }

  Future<void> delete(String name) async{
    final all = await _readAll();
    all.remove(name);
    _writeAll(all);
  }
}