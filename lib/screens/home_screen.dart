import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_grow/api/apis.dart';
import 'package:chat_grow/screens/profile_screen.dart';
import 'package:chat_grow/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/chat_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(CupertinoIcons.home),
        title: Text("ChatGlow"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          InkWell(
            onTap: () => Navigator.push(context,MaterialPageRoute(builder: (_)=>ProfileScreen(user: list[0]))),
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.05),
                child: CachedNetworkImage(
                  height: mq.height * 0.03,
                  width: mq.height * 0.03,
                  fit: BoxFit.fill,
                  imageUrl: APIs.user.photoURL.toString(),
                  errorWidget: (context, url, error) => CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(
            Icons.add_comment_rounded,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue,
          shape: CircleBorder(),
        ),
      ),
      body: StreamBuilder(
        stream: APIs.firestore.collection("users").snapshots(),
        builder: (context,snapshot){

          switch (snapshot.connectionState) {
            //if data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());

            //if some or all data is loaded then show it
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              
              list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              if(list.isNotEmpty){
                return ListView.builder(
                    itemCount: list.length,
                    padding: EdgeInsets.only(top: 5),
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ChatUserCardItem(user: list[index],);
                    });
              }else{
                return Center(
                  child: Text("No Connections Found!!",style: TextStyle(fontSize: 20),),
                );
              }
          }


        },
      )
    );
  }
}
