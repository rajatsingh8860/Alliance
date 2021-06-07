import 'package:alliance/views/NoDataFoundWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationOfGroups extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotificationState();
  }
}

class NotificationState extends State<NotificationOfGroups> {
  String documentId;
  var uploading = false;
  var exists = true;

  checkIfCollectionExists() async {
    setState(() {
      uploading = true;
    });
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      documentId = user.uid;
    });
    await Firestore.instance
        .collection("Notification_data_$documentId")
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
    changeIconCount();
    checkIfCollectionExists();
  }

  changeIconCount() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    Firestore.instance
        .collection('Notification_Icon')
        .document(documentId)
        .updateData({'icon_count': '00'});
  }

  getUserId() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      documentId = user.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Notifications",
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
                      .collection("Notification_data_$documentId")
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
                                snapshot.data.documents[i].data['groupName'];
                            String imageUrl =
                                snapshot.data.documents[i].data['imgUrl'];
                            DateTime date = snapshot
                                .data.documents[i].data['date']
                                .toDate();
                            return Padding(
                              padding: EdgeInsets.all(10),
                              child: ListTile(
                                dense: true,
                                leading: Image.network(
                                  imageUrl,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                  "$groupName just announced a new event for ${date.toString().substring(0, 10)}.",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
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
