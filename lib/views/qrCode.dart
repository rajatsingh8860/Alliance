import 'package:alliance/views/NoDataFoundWidget.dart';
import 'package:alliance/views/group_detail.dart';
import 'package:alliance/views/qr_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Code extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CodeState();
  }
}

class CodeState extends State<Code> {
  String documentId;
  var exists = true;
  var uploading = false;

  checkIfCollectionExists() async {
    setState(() {
      uploading = true;
    });
    await Firestore.instance
        .collection("Qr Code")
        .document(documentId)
        .collection('Registered')
        .snapshots()
        .listen((event) {
      if (event.documents.length == 0) {
        setState(() {
          exists = false;
        });
      }
    });
    setState(() {
      uploading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserId();
    
  }

  getUserId() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      documentId = user.uid;
    });
    checkIfCollectionExists();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Qr Code",
          style: TextStyle(
              //  fontWeight: FontWeight.bold,
              fontSize: 25,
              fontFamily: 'Oswald',
              color: Colors.black),
        ),
      ),
      body: (uploading)
          ? Center(child: CircularProgressIndicator())
          : !exists
              ? NoDataFoundWidget("No data found")
              : StreamBuilder(
                  stream: Firestore.instance
                      .collection("Qr Code")
                      .document(documentId)
                      .collection('Registered')
                      .snapshots(),
                  builder: (BuildContext context, snapshot) {
                    if (!snapshot.hasData)
                      return Container(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator());
                    return Container(
                      height: height,
                      child: Container(
                        padding: EdgeInsets.only(top: 20),
                        child: new ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, i) {
                            String groupName =
                                snapshot.data.documents[i].data['group_Name'];
                            String imageUrl =
                                snapshot.data.documents[i].data['imageUrl'];
                            String date =
                                snapshot.data.documents[i].data['date'];
                            return Padding(
                              padding: EdgeInsets.all(10),
                              child: GestureDetector(
                                onTap: () async {
                                  FirebaseUser user =
                                      await FirebaseAuth.instance.currentUser();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              QRcode(user.email, group_name)));
                                },
                                child: ListTile(
                                  dense: true,
                                  leading: Image.network(
                                    imageUrl,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(
                                    "Attached Qr Code for event organised by $groupName on $date",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
    );
  }
}
