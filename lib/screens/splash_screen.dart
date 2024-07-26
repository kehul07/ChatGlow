import 'package:chat_grow/auth/login_screen.dart';
import 'package:chat_grow/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/apis.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 2),(){
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle( const SystemUiOverlayStyle( systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));

      if(APIs.auth.currentUser!=null){
        print("\nUser : ${APIs.auth.currentUser}");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomeScreen()));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LooginScreen()));
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .15,
              width: mq.width * .5,
              right: mq.width * .25,
              child: Image.asset(
                "images/icon.png",
              )),
          Positioned(
              width: mq.width,
              bottom: mq.height * .15,
              child:const Center(
                child: Text(
                  "MADE IN INDIA WITH ❤️",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    letterSpacing: .5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ))
        ],
      ),
    );
  }
}
