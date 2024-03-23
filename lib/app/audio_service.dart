import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService extends ChangeNotifier {
  final recorder = FlutterSoundRecorder();
  final player = FlutterSoundPlayer();

  StreamController<String> streamInfo = StreamController(sync: true);

  File? file;

  List<String> paths = [];
  int count = 0;

  void addElement(String path) {
    paths.add(path);
    notifyListeners();
  }

  void init() {
    initPlayer();
    initRecorder();
    notifyListeners();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Permission not granted';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future<void> initPlayer() async {
    await player.openPlayer();
    player.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  void startPlay(File? fileOther) {
    if (file == null) {
      return;
    }
    player.startPlayer(
        fromDataBuffer:
            fileOther?.readAsBytesSync() ?? file!.readAsBytesSync());
  }

  void stopPlay() {
    player.stopPlayer();
    notifyListeners();
  }

  Future startRecord({String? path}) async {
    count++;
    await recorder.startRecorder(toFile: path ?? 'audio$count');
    notifyListeners();
  }

  Future stopRecorder() async {
    final filePath = await recorder.stopRecorder();
    final fileAudio = File(filePath!);
    file = fileAudio;
    streamInfo.add('Audio gravado');
    notifyListeners();
  }

  Future<void> concatenarAudios() async {
    try {
      if (paths.isEmpty || paths.length < 2) {
        streamInfo.add('grave mais audios');
        return;
      }
      const outPATH =
          '/data/user/0/com.example.audio_example/cache/concatenado';
      '/data/user/0/com.example.audio_example/cache/concatenado';

      final String comand =
          "-i ${paths[0]} -i ${paths[1]} -filter_complex 'concat=n=2:v=0:a=1[a]' -map '[a]' -codec:a libmp3lame -qscale:a 2 $outPATH";
      await FFmpegKit.execute(comand);
      File fileConcatenado = File(outPATH);
      startPlay(fileConcatenado);

      streamInfo.add('Audio Concatenado${fileConcatenado.path}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    player.closePlayer();
    streamInfo.close();
    super.dispose();
  }
}
