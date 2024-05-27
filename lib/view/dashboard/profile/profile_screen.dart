import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

import '../../../ViewModel/profile/profile_controller.dart';
import '../../../res/color.dart';
import '../../../widgets/RoundButton.dart';
import '../../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  bool _isLoading = false; // Add this boolean flag

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: ChangeNotifierProvider(
          create: (_) => ProfileController(),
          child: Consumer<ProfileController>(
            builder: (context, provider, child) {
              return SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: StreamBuilder(
                      stream:_firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 140, vertical: 300),
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasData) {
                          final Map<String, dynamic> map =
                          snapshot.data!.data() as Map<String, dynamic>;
                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        provider.pickImage(context);
                                      },
                                      child: Container(
                                        height: 130,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                          border: Border.all(
                                            color: AppColors.grayColor,
                                            width: 5,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: provider.image == null
                                              ? (map['image'] ?? '').toString().isEmpty
                                              ? const Icon(
                                            Icons.person,
                                            color: Colors.grey,
                                            size: 60,
                                          )
                                              : Image.network(
                                            map['image'],
                                            height: 130,
                                            width: 130,
                                            fit: BoxFit.fill,
                                          )
                                              : Stack(
                                            children: [
                                              Image.file(
                                                fit: BoxFit.fill,
                                                height: 130,
                                                width: 130,
                                                File(provider.image!.path),
                                              ),
                                              // Use the boolean flag to control the loading indicator
                                              if (_isLoading)
                                                const Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 112,
                                    child: GestureDetector(
                                      onTap: () {
                                        provider.pickImage(context);
                                      },
                                      child: const CircleAvatar(
                                        radius: 14,
                                        child: Icon(Icons.add),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 100,
                                child: RoundButton(
                                  btntxt: 'Edit Info',
                                  ontap: () {
                                    provider.showDialogEditProfile(
                                      context,
                                      map['name'] ?? '',
                                      map['number'] ?? '',
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 2),
                              ReuseRow(
                                title: 'User Name :',
                                value: map['name'] ?? '',
                                iconData: Icons.person_outline,
                              ),
                              const SizedBox(height: 10),
                              ReuseRow(
                                title: 'User Email :',
                                value: map['email'] ?? '',
                                iconData: Icons.email_outlined,
                              ),
                              const SizedBox(height: 10),
                              ReuseRow(
                                title: 'Phone :',
                                value: map['number']?.toString() ?? 'xxx-xxx-xxx',
                                iconData: Icons.person_outline,
                              ),
                              const SizedBox(height: 20),
                              RoundButton(
                                btntxt: 'Logout',
                                ontap: () {
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: const LoginScreen(),
                                    withNavBar: false,
                                  );
                                },
                              ),
                            ],
                          );
                        } else {
                          return const Center(
                            child: Text('Something went wrong!'),
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ));
  }
}

class ReuseRow extends StatelessWidget {
  const ReuseRow({
    Key? key,
    required this.value,
    required this.iconData,
    required this.title,
  }) : super(key: key);

  final IconData iconData;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
      child: ListTile(
        leading: Icon(iconData,color: Colors.white70),
        title: Text(title,style: const TextStyle(color: Colors.white70)),
        trailing: Text(value,style: const TextStyle(color: Colors.white38)),
      ),
    );
  }
}
