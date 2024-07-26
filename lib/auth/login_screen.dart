import 'dart:io';

import 'package:chat_grow/api/apis.dart';
import 'package:chat_grow/helper/dialogs.dart';
import 'package:chat_grow/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';

class LooginScreen extends StatefulWidget {
  const LooginScreen({super.key});

  @override
  State<LooginScreen> createState() => _LooginScreenState();
}

class _LooginScreenState extends State<LooginScreen> {
  bool _isanimated = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 500),(){
     setState(() {
       _isanimated=true;
     });
    });
  }

  _handleGoogleClickBtn() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async{
      Navigator.pop(context);
      if(user!=null){
        print("User : ${user.user}");
        print("Additional : ${user.additionalUserInfo}");

        if(await APIs.userExist()){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }else{
          await APIs.createUser().then((value){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          });
        }

      }

    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try{
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    }catch(e){
        print("\n_signInWithGoogle : ${e.toString()}");
        Dialogs.showSnackbar(context, "Something went wrong (Check internet)");
        return null;
    }
  }

  _signOut() async{
     await APIs.auth.signOut();
     await GoogleSignIn().signOut();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:const Text("Welcome to ChatGlow"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration:const Duration(seconds: 1),
              top: mq.height * .15,
              width: mq.width * .5,
              right: _isanimated ? mq.width * .25 : -mq.width*.5,
              child: Image.asset("images/icon.png",)),
          Positioned(
              bottom:  mq.height * .15,
              width: mq.width*.9,
              left: mq.width * .05,
              height: mq.height*.07,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black,width: 1),
                  borderRadius: BorderRadius.circular(30)
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape:const StadiumBorder(),
                    backgroundColor: Colors.blue.shade50
                  ),
                  onPressed: (){
                    _handleGoogleClickBtn();
                  }, label: RichText(
                  text:const TextSpan(
                    style: TextStyle(color: Colors.black,fontSize: 18),
                    children: [
                      TextSpan(text: "Login with"),
                      TextSpan(text: " Google",style: TextStyle(fontWeight: FontWeight.w500))
                    ]
                  ),
                ),icon: Image.asset("images/google.png",height: mq.height*.04),),
              ))
        ],
      ),
    );
  }
}
