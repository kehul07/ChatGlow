import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_grow/api/apis.dart';
import 'package:chat_grow/helper/dialogs.dart';
import 'package:chat_grow/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/login_screen.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title:const Text("Profile"),
        ),
        floatingActionButton: Padding(
          padding:const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton(
            onPressed: () async {
              Dialogs.showProgressBar(context);
              APIs.updateOnlineStatus(false);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  APIs.auth = FirebaseAuth.instance;
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) =>const LooginScreen()));
                });
              });
            },
            backgroundColor: Colors.red,
            shape:const CircleBorder(),
            child:const Icon(
              Icons.login_outlined,
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.1),
                              child: Image.file(
                                File(_image!),
                                height: mq.height * 0.2,
                                width: mq.height * 0.2,
                                fit: BoxFit.cover,
                              ),
                            )
                          :  ClipRRect(
                        borderRadius:
                        BorderRadius.circular(mq.height * .1),
                        child: CachedNetworkImage(
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image,
                          errorWidget: (context, url, error) =>
                          const CircleAvatar(
                              child: Icon(CupertinoIcons.person)),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: MaterialButton(
                          elevation: 1,
                          color: Colors.white,
                          shape:const CircleBorder(),
                          onPressed: () {
                            _showBottomSheet();
                          },
                          child:const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mq.height * 0.05,
                  ),
                  Text(
                    widget.user.email,
                    style:const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? "",
                    validator: (val) =>
                        val != null && val.isEmpty ? "Required field" : null,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.purple.shade900,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:const BorderSide(color: Colors.blue)),
                        hintText: "eg.Happy Singh",
                        label:const Text("Name")),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.02,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? "",
                    validator: (val) =>
                        val != null && val.isEmpty ? "Required field" : null,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.info_outline,
                          color: Colors.purple.shade900,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:const BorderSide(
                              color: Colors.blue,
                            )),
                        hintText: "eg.Feeling Happy",
                        label:const Text("About")),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.05,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        APIs.updateUserinfo().then((value) {
                          Dialogs.showSnackbar(
                              context, "Profile Updated Successfully!");
                        });
                      }
                    },
                    label:const Text(
                      "Update",
                      style: TextStyle(fontSize: 16),
                    ),
                    icon:const Icon(
                      Icons.edit,
                      size: 25,
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade900,
                        foregroundColor: Colors.white,
                        shape:const StadiumBorder(),
                        minimumSize: Size(mq.width * .4, mq.height * 0.06)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.05),
            shrinkWrap: true,
            children: [
              const Text(
                "Pic Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: mq.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery,imageQuality: 80);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        APIs.uploadProfilePicture(File(_image!));
                        Navigator.pop(context);
                      }

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape:const CircleBorder(),
                      fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                    ),
                    child: Image.asset("images/add_image.png"),
                  ),
                  ElevatedButton(
                    onPressed: () async{
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera,imageQuality: 80);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        APIs.uploadProfilePicture(File(_image!));
                        Navigator.pop(context);
                      }

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape:const CircleBorder(),
                      fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                    ),
                    child: Image.asset("images/camera.png"),
                  )
                ],
              )
            ],
          );
        });
  }
}
