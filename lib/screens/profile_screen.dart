import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_grow/api/apis.dart';
import 'package:chat_grow/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../auth/login_screen.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () async {
            await APIs.auth.signOut();
            await GoogleSignIn().signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> LooginScreen()));
          },
          child: Icon(
            Icons.login_outlined,
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
          shape: CircleBorder(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: mq.width,
                height: mq.height * 0.03,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.1),
                child: CachedNetworkImage(
                  height: mq.height * 0.2,
                  width: mq.height * 0.2,
                  fit: BoxFit.fill,
                  imageUrl: widget.user.image,
                  errorWidget: (context, url, error) => CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
              SizedBox(
                height: mq.height * 0.05,
              ),
              Text(
                widget.user.email,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              SizedBox(
                width: mq.width,
                height: mq.height * 0.03,
              ),
              TextFormField(
                initialValue: widget.user.name,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.purple.shade900,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.blue
                      )
                    ),
                    hintText: "eg.Happy Singh",
                    label: Text("Name")),
              ),
              SizedBox(
                width: mq.width,
                height: mq.height * 0.02,
              ),
              TextFormField(
                initialValue: widget.user.about,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.info_outline,
                      color: Colors.purple.shade900,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: Colors.blue,
                        )
                    ),
                    hintText: "eg.Feeling Happy",
                    label: Text("About")),
              ),
              SizedBox(
                width: mq.width,
                height: mq.height * 0.05,
              ),
              ElevatedButton.icon(
                onPressed: () {},
                label: Text("Update",style: TextStyle(fontSize: 16),),
                icon: Icon(Icons.edit,size: 25,),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade900,
                  foregroundColor: Colors.white,
                  shape: StadiumBorder(),
                  minimumSize: Size(mq.width*.4, mq.height*0.06)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
