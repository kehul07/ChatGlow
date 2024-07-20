
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_grow/api/apis.dart';
import 'package:chat_grow/helper/my_date_util.dart';
import 'package:chat_grow/models/chat_user.dart';
import 'package:chat_grow/models/message.dart';
import 'package:chat_grow/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ChatUserCardItem extends StatefulWidget {
  final ChatUser user;
  const ChatUserCardItem({super.key, required this.user});

  @override
  State<ChatUserCardItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatUserCardItem> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,MaterialPageRoute(builder: (_) => ChatScreen(user:widget.user))),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context,snapshot){
            final data = snapshot.data?.docs;
            final list = data?.map((e)=>Message.fromJson(e.data())).toList() ?? [];
            if(list.isNotEmpty){
              _message = list[0];
            }
            return ListTile(
              // leading: CircleAvatar(child: Icon(CupertinoIcons.person),),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.3),
                child: CachedNetworkImage(
                  height: mq.height * 0.055,
                  width: mq.height * 0.055,
                  imageUrl: widget.user.image,
                  errorWidget: (context,url,error) =>  CircleAvatar(child: Icon(CupertinoIcons.person),),
                ),
              ),
              title: Text(widget.user.name),
              subtitle: Text(_message!=null ? _message!.msg : widget.user.about,maxLines: 1,),
              trailing: _message==null ? null: _message!.read.isEmpty && _message!.fromId!=APIs.user.uid ? Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: Colors.greenAccent.shade700,
                    borderRadius: BorderRadius.circular(10)
                ),
              ) : Text(MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),style: TextStyle(color: Colors.black54),),
              // trailing: Text("12:00 PM",style: TextStyle(color: Colors.black54),),
            );
        },)
      ),
    );
  }
}
