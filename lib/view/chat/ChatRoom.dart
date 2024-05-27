import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import '../../res/color.dart';
import '../../utils/utils.dart';
import '../dashboard/massage/massage2.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatRoom({required this.chatRoomId, required this.userMap});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  var messageController = TextEditingController();
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? imageFile;

  ///for audio
  final voiceRecordingsBox = Hive.box('voiceRecordingsBox');
  late Record audioRecord;
  late audioplayers.AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = "";
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = audioplayers.AudioPlayer();
    audioRecord = Record();
    // fetch_auth.currentUser!.uid();
    // print('......uuuuuuuuu${_auth.currentUser!.uid.toString()}');
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

  // String? _auth.currentUser!.uid;  // Store the user's name
  //
  // Future<void> fetch_auth.currentUser!.uid() async {
  //   firestore.DocumentSnapshot userSnapshot =
  //   await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
  //   _auth.currentUser!.uid = userSnapshot['name'];
  // }


  ///For image
  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }
  ///for upload audio
  Future uploadAudio() async {
    String fileName = const Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendByUser": _auth.currentUser!.uid,
      "message": "",
      "type": "audio",
      "time": firestore.FieldValue.serverTimestamp(),
    });

    var ref = FirebaseStorage.instance.ref().child('audio').child("$fileName.mp3");

    var uploadTask = await ref.putFile(File(audioPath)).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String audioUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": audioUrl});

      print(audioUrl);
    }
  }



  /// like this for audio to upload audio path to firestorm ,the audio path is above
  Future uploadImage() async {
    String fileName = const Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendByUser": _auth.currentUser!.uid,
      "message": "",
      "type": "img",
      "time": firestore.FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  void onSendMessage() async {
    if (messageController.text.isNotEmpty) {
      // firestore.DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
      // String _auth.currentUser!.uid = userSnapshot['name'];
      Map<String, dynamic> messages = {
        "sendByUser": _auth.currentUser!.uid,
        "message": messageController.text,
        "type": "text",
        "time": firestore.FieldValue.serverTimestamp(),
      };

      messageController.clear();
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      Utils().toastMassage('Enter some text', false);
      print("Enter Some Text");
    }
  }

  final ScrollController _scrollController = ScrollController();

  bool scrollbool = false;

  double itemHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/peakpx.jpg'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          backgroundColor: AppColors.dividedColor,
          title: StreamBuilder<firestore.DocumentSnapshot>(
            stream:
                _firestore.collection("users").doc(widget.userMap['uid']).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return Container(
                  child: Row(
                    children: [
                      ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        borderRadius: BorderRadius.circular(100),
                        child: CircleAvatar(
                          child: (widget.userMap['image'] == null || widget.userMap['image'] == '')
                              ? const FaIcon(FontAwesomeIcons.person)
                              : Image.network(widget.userMap['image'], fit: BoxFit.fill),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.userMap['name'],
                              style: const TextStyle(color: Colors.white)),
                          Text(
                            snapshot.data!['status'],
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white38),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: size.height / 1.28,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: StreamBuilder<firestore.QuerySnapshot>(
                  stream: _firestore
                      .collection('chatroom')
                      .doc(widget.chatRoomId)
                      .collection('chats')
                      .orderBy("time", descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<firestore.QuerySnapshot> snapshot) {
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
                        // controller: _scrollController,
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          return messages(size, map, context);
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
                            controller: messageController,
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
                      messageController.text.length == 0
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

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDeleteMessageDialog(context, _firestore
            .collection('chatroom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc(map['id']));
      },
          child: map['type'] == "text"
              ? Container(
            width: size.width,
            alignment: map['sendByUser'] == _auth.currentUser!.uid
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                  left: map['sendByUser'] == _auth.currentUser!.uid
                      ? 100
                      : 8.0,
                  right: map['sendByUser'] == _auth.currentUser!.uid
                      ? 8
                      : 100,
                  top: 10,
                  bottom: 10),
              child: CustomPaint(
                // size: const Size.fromWidth(50),
                painter: MessageBubble(
                    color: map['sendByUser'] == _auth.currentUser!.uid
                        ? const Color(0xffDAF0F3)
                        : const Color(0xffC795B2),
                    alignment: map['sendByUser'] == _auth.currentUser!.uid
                        ? Alignment.topRight
                        : Alignment.topLeft,
                    tail: true),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: map['sendByUser'] == _auth.currentUser!.uid
                          ? 15
                          : 20,
                      right: map['sendByUser'] == _auth.currentUser!.uid
                          ? 20:15,
                      top: 10,
                      bottom: 10),
                  child: Text(
                    map['message'].toString(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 15,
                        color: map['sendByUser'] != _auth.currentUser!.uid
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
            ),
          )
              : map['type'] == "img"
              ? Container(
            width: size.width,
            alignment: map['sendByUser'] == _auth.currentUser!.uid
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              height: size.height / 2.5,
              width: size.width,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              alignment: map['sendByUser'] == _auth.currentUser!.uid
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: InkWell(
                onTap: () => Get.to(
                  ShowImage(
                    imageUrl: map['message'],
                  ),
                ),
                child: Container(
                  height: size.height / 2.5,
                  width: size.width / 2,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45),
                      borderRadius: BorderRadius.circular(15)),
                  alignment: map['message'] != "" ? null : Alignment.center,
                  child: map['message'] != ""
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      map['message'],
                      fit: BoxFit.cover,
                    ),
                  )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
          )
              : Padding(
            padding: EdgeInsets.only(
                left: map['sendByUser'] == _auth.currentUser!.uid
                    ? 150
                    : 8.0,
                right: map['sendByUser'] == _auth.currentUser!.uid
                    ? 8
                    : 150,
                top: 10,
                bottom: 10),
                child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
                height: 60,
                width: 160,
                alignment: map['sendByUser'] == _auth.currentUser!.uid
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
                    IconButton(
                      icon: const Icon(
                        Icons.play_circle,
                        color: Colors.white70,
                      ),
                      onPressed: () async {
                        try {
                          audioplayers.Source urlSource = audioplayers.UrlSource(map['message']);
                          await audioPlayer.play(urlSource);
                        } catch (e) {
                          print('Error Playing Recording $e');
                        }
                      },
                    ),
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
                      },
                    ),
                  ],
                ),
            ),
          ),
              ),
        );

  }

  // Function to show the delete message dialog.
  Future<void> showDeleteMessageDialog(BuildContext context, firestore.DocumentReference messageRef) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Message"),
            content: const Text("Are you sure you want to delete this message?"),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Delete"),
                onPressed: () async {
                  _firestore
                      .collection('chatroom')
                      .doc(widget.chatRoomId)
                      .collection('chats').doc('id').delete();
                  // Use the provided messageRef to delete the document
                  await messageRef.delete().then((value) => Navigator.of(context).pop());
                },
              ),
            ],
          );
        }
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl, fit: BoxFit.fill),
      ),
    );
  }
}

//
