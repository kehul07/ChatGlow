
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_grow/helper/my_date_util.dart';
import 'package:chat_grow/models/chat_user.dart';
import 'package:chat_grow/screens/view_profile.dart';
import 'package:chat_grow/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  bool _showEmoji = false;
  bool _isUploading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: _appBar(),
          ),
          backgroundColor: const Color.fromARGB(255, 234, 248, 255),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessage(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      //if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();

                      //if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;

                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];
                        // _list.add(Message(toId: "xyz", fromId: APIs.user.uid, msg: "Hii", read: "", sent: "12:05 PM", type: Type.text));
                        // _list.add(Message(toId: APIs.user.uid , fromId: "xyz", msg: "Hello", read: "", sent: "12:05 PM", type: Type.text));

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding:const EdgeInsets.only(top: 5),
                              physics:const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: _list[index],
                                );
                              });
                        } else {
                          return const Center(
                            child: Text(
                              "Say Hii!👋",
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
              if (_isUploading)
                const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:  EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )),
              _chatInput(),
              if (_showEmoji)
                SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      emojiViewConfig: EmojiViewConfig(
                        backgroundColor:
                            const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return SafeArea(
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfileScreen(user: widget.user))),
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:const Icon(
                      Icons.arrow_back,
                      color: Colors.black54,
                    )),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.3),
                  child: CachedNetworkImage(
                    height: mq.height * 0.05,
                    width: mq.height * 0.05,
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                    errorWidget: (context, url, error) =>const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style:const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? "Online"
                              : MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                          : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                      style:const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _chatInput() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: mq.width * 0.025, vertical: mq.height * 0.01),
        child: Row(
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _showEmoji = !_showEmoji;
                          });
                        },
                        icon: const Icon(
                          Icons.emoji_emotions,
                          color: Colors.blueAccent,
                        )),
                    Expanded(
                        child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () => setState(() {
                        _showEmoji = false;
                      }),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type Something...",
                          helperStyle: TextStyle(color: Colors.blueAccent)),
                    )),
                    IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final List<XFile> images =
                              await picker.pickMultiImage(imageQuality: 70);
      
                          for (var i in images) {
                            setState(() {
                              _isUploading = true;
                            });
                            await APIs.sendChatImage(widget.user, File(i.path));
                            setState(() {
                              _isUploading = false;
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.image,
                          color: Colors.blueAccent,
                        )),
                    IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 70);
                          if (image != null) {
                            setState(() {
                              _isUploading = true;
                            });
                            await APIs.sendChatImage(
                                widget.user, File(image.path));
                            setState(() {
                              _isUploading = false;
                            });
                          }
                        },
                        icon: const Icon(
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
                if (_textController.text.isNotEmpty) {

                  if(_list.isEmpty){
                    APIs.sendFirstMessage(widget.user, _textController.text, Type.text);
                  }
                  else {
                    APIs.sendMessage(
                        widget.user, _textController.text, Type.text);
                  }
                  _textController.text = "";
                }
              },
              minWidth: 0,
              shape:const CircleBorder(),
              padding: const EdgeInsets.only(top: 10, right: 5, bottom: 10, left: 10),
              color: Colors.green,
              child:const Icon(
                Icons.send,
                color: Colors.white,
                size: 28,
              ),
            )
          ],
        ),
      ),
    );
  }
}
