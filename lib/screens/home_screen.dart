import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_grow/api/apis.dart';
import 'package:chat_grow/helper/dialogs.dart';
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
  List<ChatUser> _list = [];

  //search users
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  // late ChatUser i;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
    // i = APIs.me;

    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains("pause")) {
          APIs.updateOnlineStatus(false);
        }
        if (message.toString().contains("resume")) {
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
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        // canPop: !_isSearching,
        // onPopInvoked: (_) async {
        //   if (_isSearching) {
        //     setState(() => _isSearching = !_isSearching);
        //   } else {
        //     Navigator.of(context).pop();
        //   }
        // },

        child: Scaffold(
            appBar: AppBar(
              leading: const Icon(CupertinoIcons.home),
              title: _isSearching
                  ? Expanded(
                    child: TextFormField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Name,Email...",
                        ),
                        style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                        onChanged: (value) {
                          _searchList.clear();
                          for (var i in _list) {
                            if (i.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()) ||
                                i.email
                                    .toLowerCase()
                                    .contains(value.toLowerCase())) {
                              _searchList.add(i);
                            }
                            setState(() {
                              _searchList;
                            });
                          }
                        },
                        autofocus: true,
                      ),
                  )
                  : const Text("ChatGlow"),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search)),
                InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: APIs.me))),
                  child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FutureBuilder(
                        future: APIs.getSelfProfileImage(),
                        builder: (context, snapshot) {
                          var data = snapshot.data?.data();
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.05),
                              child: CachedNetworkImage(
                                height: 30,
                                width: 30,
                                fit: BoxFit.fill,
                                // APIs.user.photoURL.toString()
                                imageUrl: APIs.user.photoURL.toString(),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            return ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.05),
                              child: CachedNetworkImage(
                                height: 30,
                                width: 30,
                                fit: BoxFit.fill,
                                // APIs.user.photoURL.toString()
                                imageUrl: data?["image"],
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            );
                          }
                        },
                      )),
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                onPressed: () {
                  _addChatUserDialog();
                },
                backgroundColor: Colors.blue,
                shape:const CircleBorder(),
                child: const Icon(
                  Icons.add_comment_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          body: StreamBuilder(
            stream: APIs.getMyUsers(),

            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
              //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return _skeletonLoader();

              //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                      //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());
                        // return _skeletonLoader();

                      //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCardItem(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('No Connections Found!',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
        ),
      );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackbar(
                                context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }

  Widget _skeletonLoader() {
    return ListView.builder(
      itemCount: _list.length,
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
