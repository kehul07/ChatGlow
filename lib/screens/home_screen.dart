import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_grow/api/apis.dart';
import 'package:chat_grow/screens/profile_screen.dart';
import 'package:chat_grow/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../main.dart';
import '../models/chat_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //for storing all users
  List<ChatUser> list = [];

  //search users
  final List<ChatUser> searchUsers= [];
  bool _isSearching = false;
  // late ChatUser i;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
     // i = APIs.me;

    SystemChannels.lifecycle.setMessageHandler((message){

      if(APIs.auth.currentUser!=null){
        if(message.toString().contains("pause")){
          APIs.updateOnlineStatus(false);
        }

        if(message.toString().contains("resume")){
          APIs.updateOnlineStatus(true);
        }
      }



        return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }

        },
        child: Scaffold(
          appBar: AppBar(
            leading:const Icon(CupertinoIcons.home),
            title: _isSearching ? TextFormField(
              decoration:const InputDecoration(
                border: InputBorder.none,
                hintText: "Name,Email...",
              ),style:const TextStyle(fontSize: 17,letterSpacing: 0.5),
              onChanged: (value){
                searchUsers.clear();
                for(var i in list){
                  if(i.name.toLowerCase().contains(value.toLowerCase()) || i.email.toLowerCase().contains(value.toLowerCase())){
                    searchUsers.add(i);
                  }
                  setState(() {
                    searchUsers;
                  });
                }
              },
              autofocus: true,
            ) :const Text("ChatGlow"),
            actions: [
              IconButton(onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              }, icon: Icon(_isSearching? CupertinoIcons.clear_circled_solid : Icons.search)),
              InkWell(
                onTap: () => Navigator.push(context,MaterialPageRoute(builder: (_)=>ProfileScreen(user: APIs.me))),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FutureBuilder(
                    future: APIs.getSelfProfileImage(),
                    builder: (context,snapshot){
                      var data = snapshot.data!.data();
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * 0.05),
                          child: CachedNetworkImage(
                            height: mq.height * 0.035,
                            width: mq.height * 0.035,
                            fit: BoxFit.fill,
                            // APIs.user.photoURL.toString()
                            imageUrl: APIs.user.photoURL.toString(),
                            errorWidget: (context, url, error) =>
                                CircleAvatar(
                                  child: const Icon(CupertinoIcons.person),
                                ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * 0.05),
                          child: CachedNetworkImage(
                            height: mq.height * 0.035,
                            width: mq.height * 0.035,
                            fit: BoxFit.fill,
                            // APIs.user.photoURL.toString()
                            imageUrl: data?["image"],
                            errorWidget: (context, url, error) =>
                                CircleAvatar(
                                  child: const Icon(CupertinoIcons.person),
                                ),
                          ),
                        );
                      }
                    },
                  )
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
            stream: APIs.getAllUsers(),
            builder: (context,snapshot){

              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  // return const Center(child: CircularProgressIndicator());
                  return SkeletonLoader();

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;

                  list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

                  if(list.isNotEmpty){
                    return ListView.builder(
                        itemCount:_isSearching ? searchUsers.length :list.length,
                        padding: EdgeInsets.only(top: 5),
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ChatUserCardItem(user:_isSearching? searchUsers[index] :list[index],);
                        });
                  }else{
                    return Center(
                      child: Text("No Connections Found!!",style: TextStyle(fontSize: 20),),
                    );
                  }
              }


            },
          )
        ),
      ),
    );
  }

  Widget SkeletonLoader(){
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48.0,
                  height: 48.0,
                  color: Colors.white,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 8.0,
                        color: Colors.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Container(
                        width: double.infinity,
                        height: 8.0,
                        color: Colors.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Container(
                        width: 40.0,
                        height: 8.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
