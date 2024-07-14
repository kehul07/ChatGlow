
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_grow/models/chat_user.dart';
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
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      child: InkWell(
        child: ListTile(
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
          subtitle: Text(widget.user.about,maxLines: 1,),
          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.greenAccent.shade700,
              borderRadius: BorderRadius.circular(10)
            ),
          ),
          // trailing: Text("12:00 PM",style: TextStyle(color: Colors.black54),),
        ),
        
      ),
    );
  }
}
