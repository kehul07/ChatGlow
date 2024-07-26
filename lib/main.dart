import 'package:chat_grow/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'firebase_options.dart';
late Size mq;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  var result = await FlutterNotificationChannel().registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');

  print('\nNotification Channel Result: $result');
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
        iconTheme: const IconThemeData(
          color: Colors.black
        ),

        appBarTheme:const AppBarTheme(
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,fontSize: 20,fontWeight: FontWeight.normal
          ),
          backgroundColor: Colors.white
        )
      ),

      home:const SplashScreen() ,
    );
  }
}

