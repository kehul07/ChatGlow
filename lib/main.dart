import 'package:chat_grow/auth/login_screen.dart';
import 'package:chat_grow/screens/home_screen.dart';
import 'package:chat_grow/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
late Size mq;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]).then((value)async{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
        primarySwatch: Colors.blue,
        useMaterial3: true,
        iconTheme: IconThemeData(
          color: Colors.black
        ),

        appBarTheme: AppBarTheme(
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,fontSize: 20,fontWeight: FontWeight.normal
          ),
          backgroundColor: Colors.white
        )
      ),

      home:SplashScreen() ,
    );
  }
}

