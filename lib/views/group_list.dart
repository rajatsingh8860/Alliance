import 'package:alliance/views/Recomended.dart';
import 'package:alliance/views/about.dart';
import 'package:alliance/views/loginpage.dart';
import 'package:alliance/views/new_intro.dart';
import 'package:alliance/views/profile.dart';
import 'package:flutter/services.dart';
import 'package:android_intent/android_intent.dart';
import 'package:alliance/views/auth.dart';
import 'package:alliance/views/crud.dart';
import 'package:alliance/views/group_detail.dart';
import 'package:alliance/views/notification.dart';
import 'package:alliance/views/page.dart';
import 'package:alliance/views/upcomingList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';

class GroupList extends StatefulWidget {
  int flag;
  String userId;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GroupListState();
  }
}

class GroupListState extends State<GroupList> {
  GroupListState();
  String userId, recomended_data;

  int flag;
  int id;
  var distance_in_km;
  List<String> address = List();
  double maxDistance;
//  String new_flag="";
  String new_icon;
  AuthService authService = AuthService();
  CrudeMethod crudeMethod = CrudeMethod();

  String interestCount = '0';
  var setUserDocument;
  List<String> recomendedUser = List();
  Map<String, dynamic> userSpecificMap;
  // final new_color= Hexcolor('#E6FBFF');
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final new_color = Colors.white;
  List<String> reportList = [
    "Music",
    "Dance",
    "Coding",
    "Drama",
  ];
  List<dynamic> interest_data = List();
  List<dynamic> filtered_user = List();
  // var interest_data;
  @override
  void initState() {
    super.initState();
   // requestLocationPermission();
  //  _gpsService();
    createInterestModel();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkToShowDialog();
    });
    getUserDocumentId();
    getArrayElements();
    //  getFilteredUserList();
    //   getGroupWithinRange();
  }





/*Show dialog if GPS not enabled and open settings location*/
  Future _checkGps() async {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Can't get Current location"),
                content:
                    const Text('Please make sure you enable GPS and try again'),
                actions: <Widget>[
                  FlatButton(
                      child: Text('Ok'),
                      onPressed: () {
                        final AndroidIntent intent = AndroidIntent(
                            action:
                                'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                      })
                ],
              );
            });
      }
  }

/*Check if gps service is enabled or not*/
  
  getUserDocumentId() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    setState(() {
      setUserDocument = documentId;
    });
  }

  //Used to create interestmodel to store interest flag
  createInterestModel() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    final snapshot = await Firestore.instance
        .collection('InterestModel')
        .document(documentId)
        .get();
    if (snapshot == null || !snapshot.exists) {
      Firestore.instance
          .collection('InterestModel')
          .document(documentId)
          .setData({'interest_count': '0'});
    }
  }

  /*createGroup() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String photoUrl = user.photoUrl;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => addGroup()));
  }*/

  updateInterestModel() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    Firestore.instance
        .collection('InterestModel')
        .document(documentId)
        .updateData({'interest_count': '00'});
  }

  getArrayElements() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    Firestore.instance
        .collection('List_of_interests')
        .document(documentId)
        .snapshots()
        .listen((event) {
      event.data.values.forEach((element) {
        for (int i = 0; i <= event.data.length; i++) {
          setState(() {
            interest_data.add(event['data'][i]);
          });
        }
      });
    });
  }

  getFilteredUserList() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    /* Firestore.instance
        .collection('Recomended')
        .document(documentId)
        .snapshots()
        .listen((event) {
      event.data.values.forEach((element) {
        for (int i = 0; i <= event.data.length; i++) {
          setState(() {
            filtered_user.add(event['recomended_data'][i]);
          });
        }
      });
                Fluttertoast.showToast(msg: filtered_user.toString());

    });*/
    //  Fluttertoast.showToast(msg: filtered_user.toString());

    Firestore.instance
        .collection('Recomended')
        .document(documentId)
        .snapshots()
        .listen((event) {
      event.data.values.forEach((element) {
        for (int i = 0; i <= 100; i++) {
          setState(() {
            filtered_user.add(event['recomended_data'][i]);
          });
        }
      });
    });
  }

  addEntryToAllianceModel() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;

    Firestore.instance.collection('Alliance').snapshots().listen((event) {
      event.documents.forEach((element) async {
        //   setState(() {
        var list = element.data;
        list.addAll({"Rajat": "Singh"});
        setState(() {
          userSpecificMap = list;
        });
        // });
        final model_snapshot =
            await Firestore.instance.collection(documentId).getDocuments();
        if (model_snapshot == null) {
          Firestore.instance
              .collection("${documentId}")
              .add(userSpecificMap)
              .catchError((e) {
            print(e);
          });
        } else {
          Firestore.instance
              .collection('${documentId}')
              .getDocuments()
              .then((snapshot) {
            for (DocumentSnapshot ds in snapshot.documents) {
              ds.reference.updateData(userSpecificMap);
            }
          });
          //       Firestore.instance
          //         .collection("${documentId}")
          //       .add(userSpecificMap)
          //     .catchError((e) {
          //        print(e);
          //    });
        }
      });
    });
    /* final position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator().placemarkFromAddress(address[0]);
    double distance = await Geolocator().distanceBetween(position.latitude, position.longitude, placemark.first.position.latitude, placemark.first.position.longitude);
    distance_in_km = (distance~/1000).toInt();
    Fluttertoast.showToast(msg: distance_in_km.toString());
    Map<String, dynamic> blogMap = {
      "${documentId}_distance": distance_in_km ,
    };
    Fluttertoast.showToast(msg: Firestore.instance.collection('Alliance').document().toString());*/
    //  Firestore.instance.collection('Alliance').document();
  }

  getGroupWithinRange() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    Firestore.instance.collection("Alliance").snapshots().listen((event) {
      event.documents.forEach((element) async {
       
      
       
               var set1 = Set.from(element["interest"]);
        var set2 = Set.from(interest_data);
        if (set1.intersection(set2).isNotEmpty) {
          setState(() {
            recomendedUser.add(element["groupName"]);
          });
          final filtered_snapshot = await Firestore.instance
              .collection('Recomended')
              .document(documentId)
              .get();
          if (filtered_snapshot == null || !filtered_snapshot.exists) {
            Firestore.instance
                .collection("Recomended")
                .document(documentId)
                .setData({'recomended_data': recomendedUser});
          } else {
            Firestore.instance
                .collection("Recomended")
                .document(documentId)
                .updateData({'recomended_data': recomendedUser});
          }
        }
      });
    });
  }

  //Dialog for choosing interest

  showInterestDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Choose Interest"),
            content: MultiSelectChip(reportList),
            actions: [
              FlatButton(
                child: Text("Done"),
                onPressed: () {
                  updateInterestModel();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  checkToShowDialog() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    var new_flag;
    Firestore.instance
        .collection('InterestModel')
        .document(documentId)
        .snapshots()
        .listen((event) {
      event.data.values.forEach((element) {
        setState(() {
          new_flag = element;
        });
      });
      if (new_flag != '00') {
        showInterestDialog(context);
      }
    });
  }

  goToNotificationPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => NotificationOfGroups()));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        title: Text(
          "ALLIANCE",
          style: TextStyle(
              //  fontWeight: FontWeight.bold,
              fontSize: 25,
              fontFamily: 'Oswald',
              color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.black,
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return Intro();
                  }));
                });
              }),
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.developer_mode,
                color: Colors.black,
              ),
            ),
            onPressed: () async {
              /*try {
                return FirebaseAuth.instance.signOut();
              } catch (e) {
                Fluttertoast.showToast(msg: e);
              }*/
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return About();
              }));
            },
          ),
          /* IconButton(
            icon: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.account_circle, color: Colors.black)),
            onPressed: () {
              //createGroup();
              // NotificationOfGroups();
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Profile()));
            },
          ),*/
        ],
      ),
      body: Container(
          height: height,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: width / 22),
                      child: Text("Upcoming Event",
                          style: TextStyle(fontSize: 20, fontFamily: 'Oswald')),
                    ),
                    SizedBox(width: width / 2.8),
                    SizedBox(width: width / 20),
                    IconButton(
                        icon: Icon(Icons.arrow_forward, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Upcoming()));
                        })
                  ],
                ),
              ),
              StreamBuilder(
                  stream: Firestore.instance
                      .collection("Alliance")
                      .orderBy('date')
                      .snapshots(),
                  builder: (BuildContext context, snapshot) {
                    if (!snapshot.hasData)
                      return Container(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator());
                    return Container(
                      height: height / 3.5,
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: new ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, i) {
                            String image_url =
                                snapshot.data.documents[i].data['imgUrl'];
                            int count = snapshot.data.documents[i].data['seat'];
                            int flag = snapshot.data.documents[i].data['flag'];
                            String email_id =
                                snapshot.data.documents[i].data['email'];
                            String group_name =
                                snapshot.data.documents[i].data['groupName'];
                            String location =
                                snapshot.data.documents[i].data['location'];
                            String description =
                                snapshot.data.documents[i].data['description'];
                            DateTime date = snapshot
                                .data.documents[i].data['date']
                                .toDate();
                            String time =
                                snapshot.data.documents[i].data['time'];
                            String query =
                                snapshot.data.documents[i].documentID;

                            return new Container(
                                width: width / 1.4,
                                //  child: Hero(
                                //  tag: image_url,
                                child: GestureDetector(
                                  onTap: () async {
                                    FirebaseUser user = await FirebaseAuth
                                        .instance
                                        .currentUser();
                                    String userId = user.uid;
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return GroupDetail(
                                          snapshot.data.documents[i].documentID,
                                          userId,
                                          count,
                                          query,
                                          email_id,
                                          group_name,
                                          location,
                                          description,
                                          image_url,
                                          date,
                                          time,
                                          snapshot.data.documents[i].data['fees']
                                          );
                                    }));
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        height: height / 4.6,
                                        width: width,
                                        padding: EdgeInsets.all(10),
                                        // child: Container(
                                        child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                gradient: LinearGradient(
                                                    colors: [
                                                      Colors.red,
                                                      Colors.blue
                                                    ],
                                                    begin: Alignment.topRight,
                                                    end: Alignment.bottomLeft),
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            //  child:Stack(
                                            //  children: [
                                            //    Positioned(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Image.network(image_url,
                                                  fit: BoxFit.cover),
                                            )
                                            //  )
                                            // ],
                                            //)
                                            ),
                                      ),
                                      Text(
                                        group_name,
                                        style: TextStyle(
                                            //  fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: 'Oswald',
                                            color: Colors.black),
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: width / 4),
                                            child: Text(
                                              "Date : ",
                                              style: TextStyle(
                                                  //  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  fontFamily: 'Oswald',
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Text(
                                            date.toString().substring(0, 10),
                                            style: TextStyle(
                                                //  fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                fontFamily: 'Oswald',
                                                color: Colors.black),
                                          ),
                                        ],
                                      )
                                      //   ),
                                    ],
                                    // )
                                  ),
                                ));
                          },
                        ),
                      ),
                    );
                  }),

              Container(
                margin: EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: width / 22),
                      child: Text("Recomended Event",
                          style: TextStyle(fontSize: 20, fontFamily: 'Oswald')),
                    ),
                    SizedBox(width: width / 2.8),
                    IconButton(
                        icon: Icon(Icons.arrow_forward, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Recomended()));
                        })
                  ],
                ),
              ),

              //Fetch nearby events
              StreamBuilder(
                  stream: Firestore.instance
                      .collection("Alliance")
                      .where("interest", arrayContainsAny: interest_data)
                      .orderBy('date')
                      .snapshots(),
                  builder: (BuildContext context, snapshot) {
                    if (!snapshot.hasData)
                      return Container(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator());
                    return Container(
                      height: height / 3.5,
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: new ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, i) {
                            String image_url =
                                snapshot.data.documents[i].data['imgUrl'];
                            int count = snapshot.data.documents[i].data['seat'];
                            int flag = snapshot.data.documents[i].data['flag'];
                            String email_id =
                                snapshot.data.documents[i].data['email'];
                            String group_name =
                                snapshot.data.documents[i].data['groupName'];
                            String location =
                                snapshot.data.documents[i].data['location'];
                            String description =
                                snapshot.data.documents[i].data['description'];
                            DateTime date = snapshot
                                .data.documents[i].data['date']
                                .toDate();
                            String time =
                                snapshot.data.documents[i].data['time'];
                            String query =
                                snapshot.data.documents[i].documentID;

                            return new Container(
                                width: width / 1.4,
                                //  child: Hero(
                                //  tag: image_url,
                                child: GestureDetector(
                                  onTap: () async {
                                    FirebaseUser user = await FirebaseAuth
                                        .instance
                                        .currentUser();
                                    String userId = user.uid;
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return GroupDetail(
                                          snapshot.data.documents[i].documentID,
                                          userId,
                                          count,
                                          query,
                                          email_id,
                                          group_name,
                                          location,
                                          description,
                                          image_url,
                                          date,
                                          time,snapshot.data.documents[i].data['fees']);
                                    }));
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        height: height / 4.6,
                                        width: width,
                                        padding: EdgeInsets.all(10),
                                        // child: Container(
                                        child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                gradient: LinearGradient(
                                                    colors: [
                                                      Colors.red,
                                                      Colors.blue
                                                    ],
                                                    begin: Alignment.topRight,
                                                    end: Alignment.bottomLeft),
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            //  child:Stack(
                                            //  children: [
                                            //    Positioned(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Image.network(image_url,
                                                  fit: BoxFit.cover),
                                            )
                                            //  )
                                            // ],
                                            //)
                                            ),
                                      ),
                                      Text(
                                        group_name,
                                        style: TextStyle(
                                            //  fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: 'Oswald',
                                            color: Colors.black),
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: width / 4),
                                            child: Text(
                                              "Date : ",
                                              style: TextStyle(
                                                  //  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  fontFamily: 'Oswald',
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Text(
                                            date.toString().substring(0, 10),
                                            style: TextStyle(
                                                //  fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                fontFamily: 'Oswald',
                                                color: Colors.black),
                                          ),
                                        ],
                                      )
                                      //   ),
                                    ],
                                    // )
                                  ),
                                ));
                          },
                        ),
                      ),
                    );
                  }),
            ],
          )),
    );
  }
}

class MultiSelectChip extends StatefulWidget {
  MultiSelectChip(this.reportList);
  List<String> reportList;
  @override
  State<StatefulWidget> createState() {
    return MultiSelectChipState(this.reportList);
  }
}

class MultiSelectChipState extends State<MultiSelectChip> {
  MultiSelectChipState(this.reportList);
  List<String> reportList;
  bool isSelected = false;
  List<String> selectedChoice = List();
  List<Widget> choices = List();

  saveInterests(List<String> selectedChoice) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    //final snapshot = await Firestore.instance.collection('List_of_interests').document(documentId).get();
    // if(snapshot == null || !snapshot.exists){
    Firestore.instance
        .collection('List_of_interests')
        .document(documentId)
        .setData({'data': selectedChoice});
    // }
  }

  buildChoiceList() {
    List<Widget> choices = List();
    reportList.forEach((element) {
      choices.add(
        Container(
            padding: EdgeInsets.all(8.0),
            child: ChoiceChip(
              backgroundColor: Colors.red,
              label: Text(element,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Oswald',
                  )),
              selected: selectedChoice.contains(element),
              onSelected: (selected) async {
                setState(() {
                  selectedChoice.contains(element)
                      ? selectedChoice.remove(element)
                      : selectedChoice.add(element);
                });
                saveInterests(selectedChoice);
              },
            )),
      );
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: buildChoiceList(),
    );
  }
}
