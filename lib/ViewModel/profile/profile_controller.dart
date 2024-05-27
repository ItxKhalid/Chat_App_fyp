import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../res/color.dart';
import '../../utils/utils.dart';
import '../../widgets/TextFormFeild.dart';

class ProfileController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final nameFocus = FocusNode();
  final phoneFocus = FocusNode();

  final picker = ImagePicker();
  XFile? _image;

  XFile? get image => _image;

  bool _loading = false;

  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future pickGalleryImage(BuildContext context) async {
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (pickedImage != null) {
      _image = XFile(pickedImage.path);
      notifyListeners();
      // await uploadImage(context);
    }
  }

  Future pickCameraImage(BuildContext context) async {
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (pickedImage != null) {
      _image = XFile(pickedImage.path);
      notifyListeners();
      // await uploadImage(context);
    }
  }

  void pickImage(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 120,
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    pickCameraImage(context);
                    Navigator.pop(context);
                  },
                  leading: Icon(Icons.camera),
                  title: Text('Camera'),
                ),
                ListTile(
                  onTap: () {
                    pickGalleryImage(context);
                    Navigator.pop(context);
                  },
                  leading: Icon(Icons.image),
                  title: Text('Gallery'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> uploadImage(BuildContext context) async {
    setLoading(true);
    final refStorage = firebase_storage.FirebaseStorage.instance
        .ref('/profileImage/${FirebaseAuth.instance.currentUser!.uid}');
    final uploadTask =
    refStorage.putFile(File(image!.path).absolute);

    try {
      await Future.value(uploadTask);
      final newUrl = await refStorage.getDownloadURL();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'User is not logged in.';
      }

      await _firestore.collection('users').doc(user.uid).update({
        'image': newUrl.toString(),
      });

      Utils().toastMassage('Profile Updated', false);
      setLoading(false);
    } catch (error) {
      Utils().toastMassage(error.toString(), true);
      setLoading(false);
    }
  }

  Future<void> showDialogEditProfile(BuildContext context, String name, String phone) {
    nameController.text = name;
    phoneController.text = phone;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Your Info'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormFieldWidget(
                  myController: nameController,
                  myFocusNode: nameFocus,
                  onFieldSubmitted: (newValue) {},
                  formFieldValidator: (value) {},
                  keyboardType: TextInputType.text,
                  hint: 'User Name',
                  obscureText: false,
                ),
                SizedBox(height: 10),
                TextFormFieldWidget(
                  myController: phoneController,
                  myFocusNode: phoneFocus,
                  onFieldSubmitted: (newValue) {},
                  formFieldValidator: (value) {},
                  keyboardType: TextInputType.number,
                  hint: 'Phone Number',
                  obscureText: false,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: AppColors.alertColor)),
            ),
            TextButton(
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  _firestore.collection('users').doc(user.uid).update({
                    'name': nameController.text,
                    'number': phoneController.text,
                  }).then((value) {
                    nameController.clear();
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Update', style: TextStyle(color: AppColors.primaryTextTextColor)),
            ),
          ],
        );
      },
    );
  }
}
