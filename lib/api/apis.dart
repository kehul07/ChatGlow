import 'dart:convert';
import 'dart:io';

import 'package:chat_grow/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import '../models/message.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User get user => auth.currentUser!;

  static late ChatUser me;

  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await messaging.requestPermission();
    await messaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        print("Push Token : ${t}");
      } else {
        print("Error on getting token ");
      }
    });
    // for handling foreground messages
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    return firestore
        .collection("users")
        .where('id',
        whereIn: userIds.isEmpty
            ? ['']
            : userIds)
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection("users")
        .doc(chatUser.id)
        .collection("my_users")
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsers() {
    return firestore
        .collection("users")
        .doc(user.uid)
        .collection("my_users")
        .snapshots();
  }

  //get self info
  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        APIs.updateOnlineStatus(true);
        print("User Data : ${user.data()}");
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
        .orderBy("sent", descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
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
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushedNotification(chatUser, type == Type.text ? msg : "image"));
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
        .orderBy("sent", descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatuser, File file) async {
    try {
      final ext = file.path.split(".").last;
      final ref = storage.ref().child(
          "images/${getConversationId(chatuser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext");

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

  static Future<String> getUserProfileImage() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    return ChatUser.fromJson(userDoc as Map<String, dynamic>).image;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection("users")
        .where("id", isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateOnlineStatus(bool isOnline) async {
    firestore.collection("users").doc(user.uid).update({
      "is_online": isOnline,
      "last_active": DateTime.now().millisecondsSinceEpoch.toString(),
      "push_token": me.pushToken,
    });
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>>
      getSelfProfileImage() async {
    return await firestore.collection("users").doc(user.uid).get();
  }

  static Future<void> sendPushedNotification(
      ChatUser chatUser, String msg) async {
    try {
      final accessToken = await getAccessToken();
      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {
            "title": me.name,
            "body": msg,
            // "android_channel_id": "chats",
          },
          "android": {
            "notification": {
              "channel_id": "chats",
            }
          }
        }
      };

      var res = await http.post(
          Uri.parse(
              "https://fcm.googleapis.com/v1/projects/chatglow-2cbf0/messages:send"),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer $accessToken"
          },
          body: jsonEncode(body));
      print("Response status : ${res.statusCode}");
      print("Response body : ${res.body}");
    } catch (e) {
      print("Error : $e");
    }
  }

  static String firebaseMessagingScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  static Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "chatglow-2cbf0",
          "private_key_id": "a6ad12fb7b0179b2cc5242fc133401c16036474c",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCt4ppNDUhZy6Qi\ntvC4pfUgVHDDdk11rAo4NLR/F4uEqHNFjOqRxHKPjD21E79pe9s0H0qvmZpOjP+c\n+wjV3i28cizYjhwb8ff6cy4dXhTrukuPxs4Kp+jbDLt7r+Y5CJyopOBjlWPFe46y\n/e0WgeEu0vPm9bZdEPkCowlVGhWerp7e3rWgtU44t8EH1L+El4hyE19nluOn5tGh\n1u+h5zEvBm5+qqEDEP2meFmgroaSMolBAuhtHavXL4XlFMoMfj27w47BrN/FvqBu\nJ4bMQDkvZ45A6uIjC1gOKSv6JPjExg2TO2w/l0wDiEHYSiAbOrvGdNOnloVVH+0e\nqxeu+NQ9AgMBAAECggEAKTySBy/dNp5aoHjuAXwp867SxyfpGrzf95BYNcOprJ4e\nKCJRBpyl5nEFuUmjnSpoQ6YgGiC9PV+mxt2prL5x7jzNcdXRyLbLbjOefgxvva+C\nd+hXuKM1T61nUN/YIzJtpHjlVfh5nr28i6o4bZwDgQ06Fk2zH8MEqqFrdykmc2jl\n4yoKiiClxdQlcseIxJsKLRbh51p3Z2rncuZcvpAtwibMrXv12Y5GRukTs2SJwd9F\nN9fpfyjVNyklUgnUCvwGfAmjhNCoIXTiKasLQY63JkXQkw3+O36buBPXS24MQpvo\nCZpGiC5tc3qUqAdIFPxTol/SAN+dj6JFIrh00mFWAQKBgQDWNVluSDUrnEPJScQ5\nI3BT2oJ9lABnD6TRaUFNue0feor/FsWr5CeHdBipi/qt+S2oN2LyhSSWw4Gn428X\n7ijRsTmO7sgIYeidTMpLLa+TD1cBbOR8/Q0js7Fu/sDlgWiDYmuho8jTrv8YmQrg\nOavrxpm9RIOS6DpqM6btaDKrwQKBgQDPz06ycMr7uwaClPfsiI5euVkX4dAoS6kI\nQymNZn7j18mxrrYXMRgteNl3znbRFHjzw4lW8ETpMmi2QfdLUq3RG/bAXj1o1NjA\ntUqSag3rY1nu4pwAQKFJB8FPbPTMhhJ8KkA5QbEO2SnrsxNeHkxKVpIczKme/j5p\nb9DyQnS3fQKBgFFbQ9Mh86fTmt9JeBBniFMgy6zcWGbMR0IN4vKdahUpmr8VrBAE\nAItuqatDcfs/h3q7RoZr0SC9snHMbLY/CxvRXtYNlMWyQgH0V2TEPknxao8tB379\nMU9dAUfx09uXEdXMvKpQpYbYkSSLg9jzrntHG78J1ZsnPoB1i7HhgFVBAoGAGMb4\n9SGpshX8krk8TkGB6B1lWAmejg9nWgrX+3oLCxOBguP35g/+d/1+wGAnnoo4Wago\nyerf7IYMIh7/Y0W6X8Jby1fxLnyiU2fKOmbWvggcgvUV8JnEITcBf3zYO0KJFbDb\n83e3qrON4gJ5/rDSG9LynOhyGPjrbBre6OOvkukCgYABOMl/GCmVZFQDZ4q8HJnZ\nwdyO5/Swhes425JUP7R8//AB94HcX+wd1n0fgh+Uy45eDGX/IEjnXQsrCJZth1vY\nwyJE6zuUpyhHfr/s2XsvurJ4IkonZxDLbgZA/X1PeNVHhYJngnzYUhscCq1GA1g6\n1B2VgT+O0uj8sr21mt06mg==\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-ysmpd@chatglow-2cbf0.iam.gserviceaccount.com",
          "client_id": "111368422739951779076",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-ysmpd%40chatglow-2cbf0.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [firebaseMessagingScope]);
    final accessToken = client.credentials.accessToken.data;

    return accessToken;
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection("chats/${getConversationId(message.toId)}/messages/")
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection("chats/${getConversationId(message.toId)}/messages/")
        .doc(message.sent)
        .update({"msg": updatedMsg});
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    print('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      print('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists
      return false;
    }
  }
}

// "dsEuauBxSPmZCJ5nbj5whR:APA91bED9OoYGyGOBQaCxgF_kvY7U6d3BIzKQVNnq1fHhBgkHo962CY9qZ0qYCw863tfr2NHA8t52R5pofRvQUkuZfmctSorAWSlMvnob9d0_rugT1Uw0MdftfN1zaLWGdvP2hqdTaik"

// https://fcm.googleapis.com/v1/projects/projectis/messages:send

// body
// {
//   "message":{
//     "token":"",
//     "notification":{
//         "body" : "",
//         "title" : "",
//     }
//   }
// }
