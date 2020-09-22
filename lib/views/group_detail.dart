import 'package:alliance/views/auth.dart';
import 'package:alliance/views/crud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alliance/views/qr_code.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

enum WidgetMaker { Add, Another, Delete, Update }

enum ButtonMaker { Follow, UnFollow }

WidgetMaker selectedWidget = WidgetMaker.Another;
CrudeMethod crudeMethod = CrudeMethod();
String group_name, description, location, userId;
DateTime date;
bool isLoading;

class GroupDetail extends StatefulWidget {
  int count, flag;
  var current_flag;
  String peerId, follow_prefs;
  String query, email_id, email, image_url;
  String group_name, description, location, time, userId;
  DateTime date;
  GroupDetail(
      this.peerId,
      this.userId,
      this.count,
      this.query,
      this.email_id,
      this.group_name,
      this.location,
      this.description,
      this.image_url,
      this.date,
      this.time);
  //Group(this.email);
  @override
  State<StatefulWidget> createState() {
    return GroupDetailState(
        this.peerId,
        this.userId,
        this.count,
        this.query,
        this.email_id,
        this.group_name,
        this.location,
        this.description,
        this.image_url,
        this.date,
        this.time);
  }
}

class GroupDetailState extends State<GroupDetail> {
  SharedPreferences prefs;
  String groupChatId;
  var current_flag;
  String joinedGroupName;
  List<String> x = List();
  @override
  void initState() {
    super.initState();
    getData();
    checkFollowButton();
    createFollowModel();
    // changeButton();
    // Fluttertoast.showToast(msg: current_flag.toString());
  }

  changeButton() async {
    //String getCurrentFlag = await getData();
    // Fluttertoast.showToast(msg: current_flag);
    if (current_flag != null) {
      if (current_flag == "1") {
        setState(() {
          selectedWidget = WidgetMaker.Another;
        });
        setState(() {
          isLoading = false;
        });
      }
      if (current_flag == "2") {
        setState(() {
          selectedWidget = WidgetMaker.Delete;
        });
        setState(() {
          isLoading = false;
        });
      } else if (current_flag == "3") {
        setState(() {
          selectedWidget = WidgetMaker.Add;
        });
        setState(() {
          isLoading = false;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  updateUserGroup() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    QuerySnapshot snapshot = await Firestore.instance
        .collection("User_Group")
        .document(documentId)
        .collection("My Groups")
        .where('joinedGroupName', isEqualTo: group_name)
        .reference()
        .getDocuments();
    String reference = snapshot.documents[0].documentID;
    Firestore.instance
        .collection("User_Group")
        .document(documentId)
        .collection("My Groups")
        .document(reference)
        .delete();
  }

  checkFollowButton() async {
    prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('id') ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }
    Firestore.instance
        .collection('Follow Count')
        .document(groupChatId)
        .snapshots()
        .listen((event) {
      event.data.values.forEach((element) {
        setState(() {
          follow_flag = element;
        });
        changeButtonAfterCheck();
      });
    });
  }

  changeButtonAfterCheck() {
    if (follow_flag == 1) {
      setState(() {
        followWidget = ButtonMaker.UnFollow;
      });
    } else {
      setState(() {
        followWidget = ButtonMaker.Follow;
      });
    }
  }

  createFollowModel() async {
    prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('id') ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }
    Map<String, dynamic> followMap = {
      "follow_count": 0,
    };
    final snapshot = await Firestore.instance
        .collection('Follow Count')
        .document(groupChatId)
        .get();
    if (snapshot == null || !snapshot.exists) {
      Firestore.instance
          .collection('Follow Count')
          .document(groupChatId)
          .setData(followMap);
    }
  }

  changeFollowButton() {
    if (follow_flag == 0) {
      setState(() {
        followWidget = ButtonMaker.Follow;
      });
    } else {
      followWidget = ButtonMaker.UnFollow;
    }
  }

  getData() async {
    isLoading = true;
    groupChatId = await readLocal();
    Firestore.instance
        .collection('createFlag')
        .document(groupChatId)
        .snapshots()
        .listen((event) {
      event.data.values.forEach((element) {
        setState(() {
          current_flag = element;
        });
        changeButton();
      });
    });
    // Fluttertoast.showToast(msg: current_flag);
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('id') ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }
    final snapshot = await Firestore.instance
        .collection('createFlag')
        .document(groupChatId)
        .get();
    if (snapshot == null || !snapshot.exists) {
      Firestore.instance
          .collection('createFlag')
          .document(groupChatId)
          .setData({'flag': '0'});
    }
    // setState(() {});
    return groupChatId;
  }

  updateflagdata(data) async {
    String my_id = await readLocal();
    Firestore.instance
        .collection('createFlag')
        .document(my_id)
        .updateData({'flag': data});
  }

  //This method is used to send email

  email(email_id) async {
    String username = 'rajatkumar.singh8860@gmail.com';
    String password = 'NituSingh';

    //this creates your smtp server for sending email
    final smtpServer = gmail(username, password);

    //Email message

    final message = Message()
      ..from = Address(username)
      ..recipients.add(email_id)
      ..ccRecipients
          .addAll(['rajatsingh9212@gmail.com', 'rajatkumar.singh@acem.edu.in'])
      ..bccRecipients.add(Address('rajatkumar.singh@acem.edu.in'))
      ..subject = 'Auto generated email'
      ..text = 'this is plain text';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not send' + e.toString());
    }
  }

  WidgetMaker selectedWidget = WidgetMaker.Add;
  ButtonMaker followWidget = ButtonMaker.Follow;

  CrudeMethod crudeMethod = CrudeMethod();

  GroupDetailState(
      this.peerId,
      this.userId,
      this.count,
      this.query,
      this.email_id,
      this.group_name,
      this.location,
      this.description,
      this.image_url,
      this.date,
      this.time);
  int count;
  //int number=count;
  int flag;
  String peerId;
  String query, image_url, time, userId;
  DateTime date;
  var follow_prefs;
  int follow_flag;
  int id;
  String user_email, group_Name, imageUrl;
  String email_id, user_id;
  String group_name, location, description;
  AuthService auth = AuthService();

  Future<String> currentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  //print("${currentUser()}");

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        bottomSheet: isLoading
            ? Center(child: Loader())
            : Container(
                 decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orangeAccent,
                                    Colors.pinkAccent
                                  ],
                                ),
                              ),
                height: height / 12,
                width: width,
                child: Row(
                  children: [
                    getCustomContainer(query, count, flag, height, width)
                  ],
                ),
              ),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Colors.black),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20), child: getCustomButton())
          ],
        ),
        backgroundColor: Colors.white,
        body: Container(
          child:  ListView(
                  children: [
                    SizedBox(height: height / 20),
                    Container(
                      child: new Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          child: Image(
                            height: height / 6,
                            width: width / 2.8,
                            fit: BoxFit.cover,
                            image: NetworkImage(image_url),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    //   Padding(
                    //   padding: EdgeInsets.only(left: 10.0),
                    Center(
                      child: Text(group_name,
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.w600)),
                    ),
                    // ),
                    SizedBox(height: height / 18),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.access_time, color: Colors.red),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Time",
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 60),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Column(
                            children: [
                              new Text(date.toString().substring(0, 11),
                                  style: TextStyle(
                                      color: Colors.blueGrey, fontSize: 18
                                      //  fontWeight: FontWeight.bold
                                      )),
                              new Text(
                                  time.substring(
                                    9,
                                  ),
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    //  fontWeight: FontWeight.bold
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.location_on, color: Colors.red),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Location",
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 60),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(location,
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 17,
                                // fontWeight: FontWeight.w300
                                //  fontWeight: FontWeight.bold
                              )),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.email, color: Colors.red),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Email",
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 60),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(email_id,
                              style:
                                  TextStyle(color: Colors.blueGrey, fontSize: 18
                                      //  fontWeight: FontWeight.bold
                                      )),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.announcement, color: Colors.red),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Description",
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 60),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(description,
                              style:
                                  TextStyle(color: Colors.blueGrey, fontSize: 18
                                      //  fontWeight: FontWeight.bold
                                      )),
                        ],
                      ),
                    ),
                  ],
                ),
        ));
  }

  Widget getCustomContainer(query, count, flag, height, width) {
    switch (selectedWidget) {
      case WidgetMaker.Add:
        return getAddButton(query, count, flag, height, width);
      case WidgetMaker.Another:
        return getAnotherWidget(query, count, flag, height);
      case WidgetMaker.Delete:
        return getDeleteButton(query, count, flag, height);
      case WidgetMaker.Update:
        return addingAlertDialog(context);
    }
    return getAnotherWidget(query, count, flag, height);
  }

  Widget getAddButton(query, count, flag, height, width) {
    return Container(
      // height: height / 8,
      //  color: Colors.white,
      child: Row(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: width / 15),
          child: Text(
            "${count.toString()} spots left",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(left: width / 2 - 80),
            // child: ClipRRect(
            //    borderRadius: BorderRadius.circular(40.0),
            child: new RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              color: Colors.white,
              child: Text("Attend", style: TextStyle(color: Colors.black)),
              onPressed: () async {
                FirebaseUser user = await FirebaseAuth.instance.currentUser();
                var documentId = user.uid;

                Map<String, dynamic> blogMap = {
                  "user_email": user.email,
                  "group_Name": group_name,
                  "date": date.toString().substring(0, 11),
                  "imageUrl": image_url
                };
                Firestore.instance
                    .collection("Qr Code")
                    .document(documentId)
                    .collection('Registered')
                    .add(blogMap)
                    .catchError((e) {
                  print(e);
                });

                readLocal();
                if (20 - count > 1) {
                  email(email_id);
                }
                if (count > 0) {
                  count = count - 1;
                }
                // setState(() {
                flag = 1;
                // });
                flag = 1;
                crudeMethod.updateData(query, {'seat': count});
                updateflagdata('1');
                if (flag == 1) {
                  setState(() {
                    selectedWidget = WidgetMaker.Another;
                  });
                }
              },
            )),

        //  )
      ]),
    );
  }

  Widget getAnotherWidget(query, count, flag, height) {
    return Container(
        //   height: height / 8,
        
        child: new Row(children: <Widget>[
          SizedBox(width: 20),
          Text("You're going",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          SizedBox(width: 20),
          new RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            color: Colors.white,
            onPressed: () async {
              FirebaseUser user = await FirebaseAuth.instance.currentUser();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QRcode(user.email, group_name)));
            },
            child: Text("QR code", style: TextStyle(color: Colors.black)),
          ),
          SizedBox(width: 10),
          new RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              color: Colors.white,
              onPressed: () {
                //setState(() {
                flag = 2;
                //  });
                updateflagdata('2');
                if (flag == 2) {
                  setState(() {
                    selectedWidget = WidgetMaker.Delete;
                  });
                }
              },
              child: Text(
                "Edit",
                style: TextStyle(color: Colors.black),
              )),

          //  )
        ]));
  }

  Widget getDeleteButton(query, count, flag, height) {
    return Container(
      //   height: height / 8,
       decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orangeAccent,
                                    Colors.pinkAccent
                                  ],
                                ),
                              ),
      child: Padding(
        padding: EdgeInsets.only(left: 20.0),
        child: Row(children: <Widget>[
          Text("You're going",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          SizedBox(width: 90),
          ClipOval(
              child: Material(
                  color: Colors.white,
                  child: InkWell(
                    //  splashColor: Colors.red,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(Icons.done),
                    ),
                    onTap: () {
                      // setState(() {
                      // setState(() {
                      flag = 1;
                      // });
                      crudeMethod.updateData(query, {
                        'seat': count,
                      });
                      if (flag == 1) {
                        setState(() {
                          selectedWidget = WidgetMaker.Another;
                        });
                      }
                      // });
                    },
                  ))),
          SizedBox(width: 20.0),
          ClipOval(
              child: Material(
                  color: Colors.white,
                  child: InkWell(
                    //  splashColor: Colors.white,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(Icons.highlight_off, color: Colors.black),
                    ),
                    onTap: () {
                      count = count + 1;
                      //   setState(() {
                      flag = 3;
                      //   });
                      crudeMethod.updateData(query, {
                        'seat': count,
                      });
                      updateflagdata('3');
                      if (flag == 3) {
                        setState(() {
                          selectedWidget = WidgetMaker.Add;
                        });
                      }
                    },
                  )))
        ]),
      ),
    );
  }

  Widget addingAlertDialog(context) {
    String email;
    int id;

    uploadData() async {
      Map<String, dynamic> blogMap = {"email": email, "id": id};
      crudeMethod.addemail(blogMap).then((value) {
        Navigator.pop(context);
      });
    }
  }

  Widget getCustomButton() {
    switch (followWidget) {
      case ButtonMaker.Follow:
        return getFollowButton();
      case ButtonMaker.UnFollow:
        return getUnfollowWidget();
    }
    //  return getFollowButton();
  }

  Widget getFollowButton() {
    return IconButton(
        icon: Icon(Icons.star_border),
        onPressed: () async {
          FirebaseUser user = await FirebaseAuth.instance.currentUser();
          String documentId = user.uid;
          var followFlagCount;
          Map<String, dynamic> blogMap = {
            "joinedGroupName": group_name,
          };
          Firestore.instance
              .collection("User_Group")
              .document(documentId)
              .collection("My Groups")
              .add(blogMap)
              .catchError((e) {
            print(e);
          });
          follow_prefs = await SharedPreferences.getInstance();
          String id = prefs.getString('id') ?? '';
          if (id.hashCode <= peerId.hashCode) {
            groupChatId = '$id-$peerId';
          } else {
            groupChatId = '$peerId-$id';
          }

          followFlagCount = 1;

          if (followFlagCount == 1) {
            setState(() {
              followWidget = ButtonMaker.UnFollow;
            });
          }

          Firestore.instance
              .collection('Follow Count')
              .document(groupChatId)
              .updateData({"follow_count": followFlagCount});
        });
  }

  getUnfollowWidget() {
    return IconButton(
        icon: Icon(Icons.star),
        onPressed: () async {
          var followFlagCount;
          follow_prefs = await SharedPreferences.getInstance();
          String id = prefs.getString('id') ?? '';
          if (id.hashCode <= peerId.hashCode) {
            groupChatId = '$id-$peerId';
          } else {
            groupChatId = '$peerId-$id';
          }

          followFlagCount = 0;

          if (followFlagCount == 1) {
            setState(() {
              followWidget = ButtonMaker.Follow;
            });
          }

          Firestore.instance
              .collection('Follow Count')
              .document(groupChatId)
              .updateData({"follow_count": followFlagCount});

          updateUserGroup();
        });
  }
}
