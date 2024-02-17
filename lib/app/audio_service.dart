import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService extends ChangeNotifier {
  final recorder = FlutterSoundRecorder();
  final player = FlutterSoundPlayer();

  File? file;

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

  void startPlay() {
    if (file == null) {
      return;
    }
    player.startPlayer(fromDataBuffer: file!.readAsBytesSync());
  }

  void stopPlay() {
    player.stopPlayer();
    notifyListeners();
  }

  Future startRecord() async {
    await recorder.startRecorder(toFile: "audio");
    notifyListeners();
  }

  Future stopRecorder() async {
    final filePath = await recorder.stopRecorder();
    final fileAudio = File(filePath!);
    file = fileAudio;
    log('Recorded file path: $filePath');
    notifyListeners();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    player.closePlayer();
    super.dispose();
  }
}
