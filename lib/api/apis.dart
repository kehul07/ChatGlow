import 'dart:io';

import 'package:chat_grow/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import '../models/message.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User get user => auth.currentUser!;

  static late ChatUser me;

  //check userExist or not
  static Future<bool> userExist() async {
    return (await firestore.collection("users").doc(user!.uid).get()).exists;
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: "Hey, I'm using ChatGlow",
        name: user.displayName.toString(),
        createdAt: time,
        isOnline: false,
        id: user.uid,
        lastActive: time,
        email: user.email.toString(),
        pushToken: '');

    return await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection("users")
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //get self info
  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> updateUserinfo() async {
    await firestore
        .collection("users")
        .doc(user.uid)
        .update({"name": me.name, "about": me.about});
  }

  static Future<void> uploadProfilePicture(File file) async {
    try {
      final ext = file.path.split(".").last;
      final ref = storage.ref().child("profile_pictures/${user.uid}.$ext");

      // Upload the file and wait for completion
      final uploadTask =
          ref.putFile(file, SettableMetadata(contentType: "image/$ext"));
      final snapshot = await uploadTask;

      print("Data transferred: ${snapshot.bytesTransferred / 1000} KB");

      // Get the download URL and update the user's profile image
      me.image = await ref.getDownloadURL();
      await firestore.collection("users").doc(user.uid).update({
        'image': me.image,
      });

      print("Profile picture updated successfully.");
    } catch (e) {
      print("Failed to upload profile picture: $e");
    }
  }

  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : "${id}_${user.uid}";

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
      ChatUser user) {
    return firestore
        .collection("chats/${getConversationId(user.id)}/messages/")
        .orderBy("sent",descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(ChatUser chatUser, String msg , Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        toId: chatUser.id,
        fromId: user.uid,
        msg: msg,
        read: "",
        sent: time,
        type: type);
    final ref = firestore
        .collection("chats/${getConversationId(chatUser.id)}/messages/");
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection("chats/${getConversationId(message.fromId)}/messages/")
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection("chats/${getConversationId(user.id)}/messages/")
        .orderBy("sent",descending: true)
        .limit(1)
        .snapshots();
  }
  static Future<void> sendChatImage(ChatUser chatuser,File file) async{
    try {
      final ext = file.path.split(".").last;
      final ref = storage.ref().child("images/${getConversationId(chatuser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext");

      // Upload the file and wait for completion
      final uploadTask =
      ref.putFile(file, SettableMetadata(contentType: "image/$ext"));
      final snapshot = await uploadTask;

      print("Data transferred: ${snapshot.bytesTransferred / 1000} KB");

      // Get the download URL and update the user's profile image
      final imageUrl = await ref.getDownloadURL();
      await sendMessage(chatuser, imageUrl, Type.image);

    } catch (e) {
      print("Failed to send picture: $e");
    }
  }

  static Future<String> getUserProfileImage() async{
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    return ChatUser.fromJson(userDoc as Map<String, dynamic>).image;
  }

}
