import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfileState();
  }
}

class ProfileState extends State<Profile> {
  String userProfilePicture;
  String userName;
  String email;
  String address;
  List<String> x = List();

  @override
  void initState() {
    super.initState();
    getProfilePicture();
    getGroupFollowedByUser();
  }

  getProfilePicture() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String photoUrl = user.photoUrl;
    String name = user.displayName;
    String userEmail = user.email;
    setState(() {
      userProfilePicture = photoUrl;
      userName = name;
      email = userEmail;
    });
  }

  getGroupFollowedByUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    Firestore.instance
        .collection("User_Group")
              .document(documentId)
              .collection("My Groups")
        .snapshots()
        .listen((event) {
      event.documents.forEach((element) {
        setState(() {
          x.add(element["joinedGroupName"]);
        });
      });
    });
  }

  

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        /*   bottomSheet: Container(
          child: Center(child: Text("Log out",style: TextStyle(color:Colors.black,fontSize:25,),)),
            color: Colors.redAccent,
            height: height / 15,
            width: width,
        ),*/
        //  ],
        //  ),
        //),
        body: Column(
      children: [
        Stack(
            overflow: Overflow.visible,
            alignment: Alignment.center,
            children: [
              //Padding(
              //padding:EdgeInsets.only(top:20),
               //),
               Container(
                 height:height/3.5
               ),
              Positioned(
                  bottom: -50.0,
                  child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(userProfilePicture))),
            ]
            ),
        SizedBox(
          height: height / 30,
        ),
        Container(
          padding: EdgeInsets.only(top: 50),
          child: Text(
            userName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        SizedBox(
          height: height / 30,
        ),
        ListTile(
          leading: Icon(Icons.email, color: Colors.red),
          title: Text(email),
        ),
        ListTile(
          leading: Icon(Icons.my_location, color: Colors.red),
          title: Text(address),
        ),
        ListTile(
          leading: Icon(Icons.group, color: Colors.red),
          title: Text("Group Followed"),
        ),
        Container(
          width: width / 1.7,
          padding: EdgeInsets.only(left: width / 12),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        x.length.toString(),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      )))
            ],
          ),
          //  padding: EdgeInsets.all(20),
          color: Hexcolor("#d8d8d8"),
        ),
        SizedBox(height:height/15),
        

        
        GestureDetector(
          onTap: (){
            try {
                return FirebaseAuth.instance.signOut().whenComplete(() => Navigator.pop(context));
              } catch (e) {
                Fluttertoast.showToast(msg: e);
              }
          },
                  child: Container(
            width:width/1.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.black),
              color: Colors.redAccent,
            ),
            child: Row(
              children: [
                SizedBox(width: width / 15),
                Container(
                  height: 40,
                  child: Icon(Icons.input,color: Colors.white,)
                ),
                new SizedBox(
                  width: width/5,
                ),
                Text(
                  "Log out",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Oswald',
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        )
      ],
    ));
  }
}
