import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_data.dart';
import '../models/regatta_data.dart';

class FileHandler {
  static Future<File> getLocalFile(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$name.json');
  }

  static Future<void> saveData(RegattaData data) async {
    final file = await getLocalFile('regatta_data');
    final jsonString = jsonEncode(data.toJson());
    await file.writeAsString(jsonString);
  }

  static Future<RegattaData> loadData() async {
    final file = await getLocalFile('regatta_data');
    final jsonString = await file.readAsString();
    return RegattaData.fromJson(jsonDecode(jsonString));
  }

  static Future<File> getAppDataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/regatta_data.json');
  }

  static Future<void> saveAppData(AppData data) async {
    final file = await getAppDataFile();
    await file.writeAsString(jsonEncode(data.toJson()));
  }

  static Future<AppData> loadAppData() async {
    final file = await getAppDataFile();
    if (!await file.exists()) return AppData([]);
    return AppData.fromJson(jsonDecode(await file.readAsString()));
  }

  static Future<void> exportJson(String filename, dynamic jsonData) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(jsonEncode(jsonData));
    await Share.shareXFiles([XFile(file.path)], text: 'Exported $filename');
  }

  static Future<List<dynamic>?> importJsonListFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final json = jsonDecode(content);

      if (json is List) return json;
      return null;
    }

    return null;
  }
}

