import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_grow/models/chat_user.dart';
import 'package:chat_grow/screens/profile_screen.dart';
import 'package:chat_grow/widgets/message_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/message.dart';


class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
   List<Message> _list = [];

   final _textController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: _appBar(),
      ),
      backgroundColor: const Color.fromARGB(255,234,248,255),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: APIs.getAllMessage(widget.user),
              builder: (context,snapshot){

                switch (snapshot.connectionState) {
                //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                       return const SizedBox();

                //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                     final data = snapshot.data?.docs;

                    _list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                    // _list.add(Message(toId: "xyz", fromId: APIs.user.uid, msg: "Hii", read: "", sent: "12:05 PM", type: Type.text));
                    // _list.add(Message(toId: APIs.user.uid , fromId: "xyz", msg: "Hello", read: "", sent: "12:05 PM", type: Type.text));

                     if(_list.isNotEmpty){
                      return ListView.builder(
                          itemCount: _list.length,
                          padding: EdgeInsets.only(top: 5),
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return MessageCard(message: _list[index],);
                          });
                    }else{
                      return Center(
                        child: Text("Say Hii!👋",style: TextStyle(fontSize: 20),),
                      );
                    }
                }


              },
            ),
          ),
            _chatInput()
        ],
      ),
    );
  }

  Widget _appBar() {
    return SafeArea(
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ProfileScreen(user: widget.user))),
        child: Row(
          children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                )),
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * 0.3),
              child: CachedNetworkImage(
                height: mq.height * 0.05,
                width: mq.height * 0.05,
                imageUrl: widget.user.image,
                errorWidget: (context, url, error) => CircleAvatar(
                  child: Icon(CupertinoIcons.person),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  "Last seen not availbale",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * 0.025, vertical: mq.height * 0.01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                      )),
                  Expanded(
                      child: TextField(
                        controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type Something...",
                        helperStyle: TextStyle(color: Colors.blueAccent)),
                  )),
                  IconButton(
                      onPressed: () {},
                      icon:const Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon:const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueAccent,
                      )),
                  SizedBox(
                    width: mq.width * 0.02,
                  )
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if(_textController.text.isNotEmpty){
                APIs.sendMessage(widget.user, _textController.text);
                _textController.text = "";
              }
            },
            minWidth: 0,
            shape: CircleBorder(),
            padding: EdgeInsets.only(top: 10, right: 5, bottom: 10, left: 10),
            color: Colors.green,
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
