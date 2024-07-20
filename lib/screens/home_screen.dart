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
  //for storing all users
  List<ChatUser> list = [];

  //search users
  final List<ChatUser> searchUsers= [];
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
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
            leading: Icon(CupertinoIcons.home),
            title: _isSearching ? TextFormField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Name,Email...",
              ),style: TextStyle(fontSize: 17,letterSpacing: 0.5),
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
            ) :Text("ChatGlow"),
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
            stream: APIs.getAllUsers(),
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
}
