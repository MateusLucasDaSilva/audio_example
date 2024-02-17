import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterSoundRecorder recover = FlutterSoundRecorder();

  Future<void> init() async {
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      throw Exception('Permission denied');
    }
    await recover.openRecorder();
    recover.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  void gravar() {
    recover.startRecorder(toFile: 'audio');
  }

  Future<String> stop() async {
    final path = await recover.stopRecorder();
    if (path == null) {
      return '';
    }
    return path;
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void togglerAudio() {
    if (recover.isRecording) {
      stop();
    } else {
      gravar();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Audio Exemplo',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Nao existe Audio!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(),
            IconButton(
              onPressed: togglerAudio,
              icon: Icon(
                size: 100,
                recover.isRecording ? Icons.pause : Icons.mic,
              ),
            ),
            const Divider(),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                size: 100,
                Icons.play_arrow,
              ),
            )
          ],
        ),
      ),
    );
  }
}
