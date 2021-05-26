import 'package:alliance/views/group_detail.dart';
import 'package:alliance/views/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:alliance/views/chat.dart';

class HomePage extends StatefulWidget {
  //String userId;
  HomePage();
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  HomePageState();
  String userId, photoUrl;
  GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
  }

  getCurrentUserId() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    String id = currentUser.uid;
    String url = currentUser.photoUrl;
    setState(() {
      userId = id;
      if (url != null) {
        photoUrl = url;
      } else {
        photoUrl = "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fphotos%2Fone-person&psig=AOvVaw0xphJEp-I1hhtp5VAOsOaT&ust=1622110033168000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCPing_eM5_ACFQAAAAAdAAAAABAD";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
         
          title: Text("Chat",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25)),
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: Container(
                  child: Image(
                    fit: BoxFit.cover,
                    image: NetworkImage(photoUrl),
                  ),
                ),
              ),
            ),
            Container(width: 20)

            //    )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Container(
                child: StreamBuilder(
              stream: Firestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(context, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                  );
                }
              },
            )),
          ],
        ));
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == userId) {
      return Container();
    } else {
      return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orangeAccent, Colors.pinkAccent],
            ),
            borderRadius: BorderRadius.circular(20.0)),
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document['photoUrl'] != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(),
                            width: 50.0,
                            height: 50.0,
                            padding: EdgeInsets.all(15.0)),
                        imageUrl: document['photoUrl'],
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.account_circle,
                        size: 50.0, color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                  child: Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                              child: Text('NickName: ${document['nickname']}',
                                  style: TextStyle(color: Colors.black)),
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0)),
                        ],
                      ),
                      margin: EdgeInsets.only(left: 20.0)))
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (cntext) => Chat(
                        document['photoUrl'],
                        document['nickname'],
                        document.documentID,
                        document['photoUrl'])));
          },
          //  color: Colors.orange,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }
}
