import 'package:chat_grow/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static User get user => auth.currentUser!;

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

    return await firestore.collection("users").doc(user.uid).set(chatUser.toJson());
  }
}
