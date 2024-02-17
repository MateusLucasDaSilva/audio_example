import 'package:audio_example/app/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    listenService();
    service.init();
  }

  @override
  void dispose() {
    service.removeListener(listen);
    service.dispose();

    super.dispose();
  }

  final service = AudioService();

  void listenService() {
    service.addListener(listen);
  }

  void listen() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal.shade700,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(service.file?.path ?? ""),
              StreamBuilder<RecordingDisposition>(
                builder: (context, snapshot) {
                  final duration = snapshot.hasData
                      ? snapshot.data!.duration
                      : Duration.zero;

                  String twoDigits(int n) => n.toString().padLeft(2, '0');

                  final twoDigitMinutes =
                      twoDigits(duration.inMinutes.remainder(60));
                  final twoDigitSeconds =
                      twoDigits(duration.inSeconds.remainder(60));

                  return Text(
                    '$twoDigitMinutes:$twoDigitSeconds',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                stream: service.recorder.onProgress,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (service.recorder.isRecording) {
                    await service.stopRecorder();
                  } else {
                    await service.startRecord();
                  }
                },
                child: Icon(
                  service.recorder.isRecording ? Icons.stop : Icons.mic,
                  size: 100,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (service.player.isPlaying) {
                    service.stopPlay();
                  } else {
                    service.startPlay();
                  }
                },
                child: Icon(
                  service.player.isPlaying ? Icons.stop : Icons.play_arrow,
                  size: 100,
                ),
              ),
            ],
          ),
        ));
  }
}
