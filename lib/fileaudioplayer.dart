import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class FileAudioPlayer {
  static const MethodChannel _channel = const MethodChannel('fileaudioplayer');

  FileAudioPlayer();

  Map<String, File> _assetCache = Map<String, File>();

  loadAssets(List<String> fileNames) {
    fileNames.forEach((element) async {
      File f = await _fetchToMemory(element);
      _assetCache[element] = f;
    });
  }

  cleanUp() {
    _assetCache.keys.forEach((element) async {
      _assetCache[element]!.delete();
    });
    _assetCache.clear();
  }

  Future<File> _fetchToMemory(String fileName) async {
    final file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.create(recursive: true);
    return await file
        .writeAsBytes((await _fetchAsset(fileName)).buffer.asUint8List());
  }

  Future<ByteData> _fetchAsset(String fileName) async {
    return await rootBundle.load(fileName);
  }

  Future<void> playAsset(String asset) async {
    try {
      await start(_assetCache[asset]!.path);
    } on PlatformException catch (e) {
      print("Stream start error : $e");
    }
  }

  Future<void> start(String path) async {
    try {
      await _channel.invokeMethod("start", path);
    } on PlatformException catch (e) {
      print("Stream start error : $e");
    }
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod("stop");
    } on PlatformException catch (e) {
      print("Stream stop error : $e");
    }
  }

  Future<void> pause() async {
    try {
      await _channel.invokeMethod("pause");
    } on PlatformException catch (e) {
      print("Stream pause error : $e");
    }
  }

  Future<void> resume() async {
    try {
      await _channel.invokeMethod("resume");
    } on PlatformException catch (e) {
      print("Stream resume error : $e");
    }
  }
}
