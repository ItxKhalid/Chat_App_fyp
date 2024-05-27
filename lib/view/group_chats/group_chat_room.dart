import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import '../../res/color.dart';
import '../../utils/app_constants.dart';
import '../chat/ChatRoom.dart';
import '../dashboard/massage/massage2.dart';
import 'group_info.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupChatId, groupName;

  GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
      : super(key: key);

  @override
  State<GroupChatRoom> createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController _message = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///for audio
  ///for audio
  final voiceRecordingsBox = Hive.box('voiceRecordingsBox');

  late Record audioRecord;

  late audioplayers.AudioPlayer audioPlayer;

  bool isRecording = false;

  String audioPath = "";

  bool isPlaying = false;
  bool isPlaying2 = false;

  @override
  void dispose() {
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

  Future<void> stopRecordingAndSend() async {
    try {
      String? path = await audioRecord.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
      });
      uploadAudio();
    } catch (e) {
      print('Error stop Recording $e');
    }
  }
  ///for upload audio
  Future uploadAudio() async {
    String fileName = const Uuid().v1();
    int status = 1;

    await _firestore
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendBy": AppConstant.currentUserName, // Use the retrieved user name
      "message": "",
      "type": "audio",
      "time": FieldValue.serverTimestamp(),
    });

    var ref = FirebaseStorage.instance.ref().child('audio').child("$fileName.mp3");

    var uploadTask = await ref.putFile(File(audioPath)).catchError((error) async {
      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String audioUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({"message": audioUrl});

      print(audioUrl);
    }
  }

  @override
  void initState() {
    fetchUserName();
    audioPlayer = audioplayers.AudioPlayer();
    audioRecord = Record();
  }

  Future<void> fetchUserName() async {
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    AppConstant.currentUserName = userSnapshot['name']; // Update AppConstant
    print('userName');
  }

  void onSendMessage() async {
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
     AppConstant.currentUserName = userSnapshot['name'];
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": AppConstant.currentUserName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };
      print('uuuuuuuuuuuu${AppConstant.currentUserName}');
      _message.clear();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = const Uuid().v1();
    int status = 1;
    /// Retrieve the user's name from Firestore
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
     AppConstant.currentUserName = userSnapshot['name'];

    await _firestore
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendBy": AppConstant.currentUserName, // Use the retrieved user name
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });
    print('uuuuuuuuuuuu${AppConstant.currentUserName}');
    var ref =
    FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  final ScrollController _scrollController = ScrollController();

  bool scrollbool = false;

  double itemHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/peakpx.jpg'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.groupName, style: const TextStyle(color: Colors.white38)),
          actions: [
            IconButton(
                onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GroupInfo(
                          groupName: widget.groupName,
                          groupId: widget.groupChatId,
                        ),
                      ),
                    ),
                icon: const Icon(Icons.more_vert)),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: size.height / 1.27,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('groups')
                      .doc(widget.groupChatId)
                      .collection('chats')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      if (_scrollController.hasClients) {
                        double maxScrollExtent =
                            _scrollController.position.maxScrollExtent;
                        double offset = _scrollController.offset;
                        double reversedOffset = maxScrollExtent - offset;
                        int bottomItemIndex =
                            (reversedOffset / itemHeight).ceil();

                        // print("----------------------current index          ${bottomItemIndex}--------------------------");
                        if (bottomItemIndex > 2) {
                          scrollbool = false;
                        } else {
                          scrollbool = true;
                        }
                      }
                      if (snapshot.data!.docs.length > 3 &&
                          scrollbool == true) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent);
                          }
                        });
                        scrollbool = false;
                      }
                      return ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> chatMap =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;

                          return messageTile(size, chatMap);
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Container(
                height: size.height / 10,
                width: size.width,
                alignment: Alignment.center,
                child: Container(
                  height: size.height / 12,
                  width: size.width / 1.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.dividedColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: TextFormField(
                            controller: _message,
                            maxLines: 3,
                            onChanged: (value) {
                              setState(() {});
                            },
                            style: const TextStyle(
                                color: AppColors.lightGrayColor),
                            decoration: InputDecoration(
                                fillColor: AppColors.dividedColor,
                                suffixIcon: IconButton(
                                  onPressed: () => getImage(),
                                  icon: const Icon(Icons.photo,
                                      color: AppColors.lightGrayColor),
                                ),
                                hintText: "Send Message",
                                hintStyle: const TextStyle(
                                    color: AppColors.lightGrayColor),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        style: BorderStyle.solid,
                                        color: AppColors.iconBackgroundColor)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        style: BorderStyle.solid,
                                        color: AppColors.lightGrayColor)),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                )),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _message.text.length == 0
                          ? GestureDetector(
                        onTap: isRecording ? stopRecordingAndSend : startRecording,
                        child: Container(
                          height: 63,
                          width: 60,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white38),
                              color: isRecording ? Colors.transparent : AppColors.dividedColor,
                              shape: BoxShape.circle),
                          child: isRecording
                              ? Lottie.asset('assets/animation_ln1mavwu.json',
                              height: 50, width: 50)
                              : const Icon(Icons.mic, color: Colors.white),
                        ),
                      )
                          : Container(
                        height: 63,
                        width: 60,
                        decoration: BoxDecoration(
                            color: AppColors.dividedColor,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.white70)),
                        child: IconButton(
                            icon: const Icon(Icons.send,
                                color: AppColors.lightGrayColor),
                            onPressed: onSendMessage),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == AppConstant.currentUserName
              ? Alignment.topRight
              : Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(
                left: chatMap['sendBy'] == AppConstant.currentUserName
                    ? 100
                    : 8.0,
                right: chatMap['sendBy'] == AppConstant.currentUserName
                    ? 8
                    : 100,
                top: 10,
                bottom: 10),
            child: CustomPaint(
              // size: const Size.fromWidth(50),
              painter: MessageBubble(
                  color: chatMap['sendBy'] == AppConstant.currentUserName
                      ? const Color(0xffDAF0F3)
                      : const Color(0xffC795B2),
                  alignment: chatMap['sendBy'] != AppConstant.currentUserName
                      ? Alignment.topLeft
                      : Alignment.topRight,
                  tail: true),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding:  EdgeInsets.only(left: chatMap['sendBy'] != AppConstant.currentUserName ? 15 :6, right: 20),
                      child: Text(
                        chatMap['sendBy'].toString(),
                        style: TextStyle(
                            fontSize: 11,
                            color: chatMap['sendBy'] !=
                                AppConstant.currentUserName
                                ? Colors.white70
                                : Colors.teal),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 25,
                      ),
                      child: Text(
                        chatMap['message'].toString(),
                        style: TextStyle(
                            fontSize: 15,
                            color: chatMap['sendBy'] !=
                                AppConstant.currentUserName
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else if (chatMap['type'] == "img") {
        return Column(
          crossAxisAlignment: chatMap['sendBy'] == AppConstant.currentUserName ? CrossAxisAlignment.end :CrossAxisAlignment.start,
          children: [
            Padding(
              padding:  EdgeInsets.only(top: 10,left: chatMap['sendBy'] != AppConstant.currentUserName ? 15 :6, right: 20),
              child: Text(
                '${chatMap['sendBy'].toString()}',
                style: TextStyle(
                    fontSize: 16,
                    color: chatMap['sendBy'] !=
                        AppConstant.currentUserName
                        ? Colors.white70
                        : Colors.teal),
              ),
            ),
            Container(
              height: size.height / 2.5,
              width: size.width,
              padding: EdgeInsets.only(
                top: 5,
                bottom: 5,
                left:
                    chatMap['sendBy'] == AppConstant.currentUserName ? 150 : 10,
                right:
                    chatMap['sendBy'] == AppConstant.currentUserName ? 10 : 150,
              ),
              child: InkWell(
                onTap: () => Get.to(
                  ShowImage(
                    imageUrl: chatMap['message'],
                  ),
                ),
                child: Container(
                  height: size.height / 2.5,
                  width: size.width / 2,
                  decoration: BoxDecoration(
                    color: Colors.white38,
                      border: Border.all(color: Colors.black45),
                      borderRadius: BorderRadius.circular(15)),
                  // alignment: chatMap['message'] != "" ? null : Alignment.center,
                  child: chatMap['message'] != ""
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          chatMap['message'],
                          fit: BoxFit.cover,
                        ),
                      )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ],
        );
      }
      else if(chatMap['type'] == "audio"){
        return Padding(
          padding: EdgeInsets.only(
              left: chatMap['sendBy'] == AppConstant.currentUserName
                  ? 150
                  : 8.0,
              right: chatMap['sendBy'] == AppConstant.currentUserName
                  ? 8
                  : 150,
              top: 10,
              bottom: 10),
          child: Column(
            crossAxisAlignment: chatMap['sendBy'] == AppConstant.currentUserName ? CrossAxisAlignment.end :CrossAxisAlignment.start,
            children: [
              Padding(
                padding:  EdgeInsets.only(top: 10,left: chatMap['sendBy'] != AppConstant.currentUserName ? 15 :6, right: 20),
                child: Text(
                  '${chatMap['sendBy'].toString()}',
                  style: TextStyle(
                      fontSize: 16,
                      color: chatMap['sendBy'] !=
                          AppConstant.currentUserName
                          ? Colors.white70
                          : Colors.teal),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  height: 60,
                  width: 160,
                  alignment: chatMap['sendBy'] == AppConstant.currentUserName
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: AppColors.dividedColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white38)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 10,),
                      Image.asset(
                        'assets/pngwing.com.png',
                        color: Colors.white70,
                        width: 60,
                        height: 60,
                      )
                      ,
                      Spacer(),
                      isPlaying2 ? IconButton(
                        icon: const Icon(
                          Icons.play_circle,
                          color: Colors.white70,
                        ),
                        onPressed: () async {
                          try {
                            audioplayers.Source urlSource = audioplayers.UrlSource(chatMap['message']);
                            await audioPlayer.play(urlSource);
                          } catch (e) {
                            print('Error Playing Recording $e');
                          }
                          setState(() {
                            isPlaying2 = !isPlaying2;
                          });
                        },
                      ):
                      IconButton(
                        icon: const Icon(
                          Icons.pause_circle,
                          color: Colors.white70,
                        ),
                        onPressed: () async {
                          try {
                            await audioPlayer.stop();
                          } catch (e) {
                            print('Error Playing Recording $e');
                          }
                          setState(() {
                            isPlaying2 = !isPlaying2;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
      else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          color: Colors.black26,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }
}
