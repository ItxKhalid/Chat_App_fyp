import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:record/record.dart';
// import 'package:path_provider/path_provider.dart' as path_provider;
// import 'package:http/http.dart' as http;

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final voiceRecordingsBox = Hive.box('voiceRecordingsBox');
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = "";

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioRecord = Record();
  }

  @override
  void dispose() {
    super.dispose();
    audioRecord.dispose();
    audioPlayer.dispose();
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start();
        setState(() {
          isRecording = true;
        });
      }
    } catch (e, stackTrace) {
      print('Error Start Recording::::::: $e');
      print('Stack Trace:::::::>>>>>>> $stackTrace');
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
        // Remove old audio recording if exists
        if (voiceRecordingsBox.isNotEmpty) {
          voiceRecordingsBox.deleteAt(0);
        }
        voiceRecordingsBox.add(audioPath);
      });
    } catch (e) {
      print('Error stop Recording $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceRecordings = voiceRecordingsBox.values.cast<String>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recorder'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 60,
                      width: 160,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.black26)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          isRecording == false
                              ? Image.asset(
                                  'assets/pngwing.com.png',
                                  width: 60,
                                  height: 60,
                                )
                              : Lottie.asset('assets/animation_ln1nhjnp.json',
                                  height: 40, width: 60),
                          IconButton(
                            icon: const Icon(
                              Icons.play_circle,
                              color: Colors.green,
                            ),
                            onPressed: () async {
                              try {
                                Source urlSource = UrlSource(audioPath);
                                await audioPlayer.play(urlSource);
                              } catch (e) {
                                print('Error Playing Recording $e');
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.pause_circle,
                              color: Colors.green,
                            ),
                            onPressed: () async {
                              try {
                                await audioPlayer.stop();
                              } catch (e) {
                                print('Error Playing Recording $e');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: isRecording ? stopRecording : startRecording,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: isRecording ? Colors.transparent : Colors.blue,
                          shape: BoxShape.circle),
                      child: isRecording
                          ? Lottie.asset('assets/animation_ln1mavwu.json',
                              height: 50, width: 50)
                          : const Icon(Icons.mic, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
