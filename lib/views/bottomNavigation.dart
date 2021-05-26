import 'package:alliance/views/home.dart';
import 'package:alliance/views/page.dart';
import 'package:alliance/views/group_list.dart';
import 'package:alliance/views/notification.dart';
import 'package:alliance/views/qrCode.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:random_string/random_string.dart';

class navigation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return navigationState();
  }
}

class navigationState extends State<navigation> {
  int currentIndex = 0;
  String photoUrl;
  String new_flag;
  var distance_in_km;
  List<dynamic> interest_data = List();
  var currentLatitude, currentLongitude;
  List<String> recomendedUser = List();
  bool isLoading;
  List<String> alreadyExistingUser = List();
  final List<Widget> _children = [
    GroupList(),
    Code(),
    NotificationOfGroups(),
    HomePage()
  ];

  @override
  void initState() {
    super.initState();
    getArrayElements();
    changeWidget();
    getCurrentLocation();
   // getListOfAlreadyRegisteredUser();
    makeDummyDocument();
    getGroupWithinRange();
  }

  getCurrentLocation() async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    setState(() {
      currentLatitude = position.latitude;
      currentLongitude = position.longitude;
    });
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

  getListOfAlreadyRegisteredUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    final filtered_snapshot = await Firestore.instance
        .collection('Recomended')
        .document(documentId)
        .get();
    if (filtered_snapshot == null || !filtered_snapshot.exists) {
      print('j');
    } else {
      //Fluttertoast.showToast(msg: modelSnapshot.toString());
      Firestore.instance
          .collection('Recomended')
          .document(documentId)
          .snapshots()
          .listen((event) {
        event.data.values.forEach((element) {
          for (int i = 0; i <= 50; i++) {
            setState(() {
              alreadyExistingUser.add(event['recomended_data'][i]);
            });
            //      Fluttertoast.showToast(msg: alreadyExistingUser.toString());
          }
        });
      });
    }
  }

  makeDummyDocument() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    Map<String, dynamic> blogMapdummy = {
      'id': randomAlphaNumeric(9),
    };
    final snapshot =
        await Firestore.instance.collection('Dummy').document(documentId).get();
    if (snapshot == null || !snapshot.exists) {
      Firestore.instance
          .collection('Dummy')
          .document(documentId)
          .setData(blogMapdummy);
    }
  }

  getGroupWithinRange() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    Firestore.instance.collection("Alliance").snapshots().listen((event) {
      event.documents.forEach((element) async {
        //   List<Placemark> placemark = await Geolocator().placemarkFromAddress(element["location"]);
        double distance = await Geolocator().distanceBetween(currentLatitude,
            currentLongitude, element["latitude"], element["longitude"]);
        distance_in_km = (distance ~/ 1000).toInt();
        var set1 = Set.from(element["interest"]);
        var set2 = Set.from(interest_data);
        if (distance_in_km <= 20 &&
            set1.intersection(set2).isNotEmpty &&
            alreadyExistingUser.contains(element["groupName"]) != true) {
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

  changeWidget() async {
    isLoading = true;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    Firestore.instance
        .collection('Notification_Icon')
        .document(documentId)
        .snapshots()
        .listen((event) {
      event.data.values.forEach((element) {
        setState(() {
          new_flag = element;
        });
      });
    });
    isLoading = false;
  }

  

  //This executes on tap on bottom navigation bar button
  void onTappedBar(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Widget change_icon() {
    if (new_flag == '00') {
      return new Positioned(right: 0, child: Container());
    } else {
      return new Positioned(
        right: 0,
        child: Container(
          padding: EdgeInsets.all(1),
          decoration: new BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(6)),
          constraints: BoxConstraints(minHeight: 12, minWidth: 12),
          child: Text(
            '',
            style: TextStyle(color: Colors.white, fontSize: 8),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[currentIndex],
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.red,
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => addGroup()));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BubbleBottomBar(
        fabLocation: BubbleBottomBarFabLocation.end,
        opacity: 0.2,
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        currentIndex: currentIndex,
        hasInk: true,
        inkColor: Colors.black12,
        hasNotch: true,
        onTap: onTappedBar,
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(
              backgroundColor: Colors.red,
              icon: Icon(Icons.home, size: 30, color: Colors.black),
              activeIcon: Icon(Icons.home, size: 30, color: Colors.red),
              title: Text('Home')),
          BubbleBottomBarItem(
              backgroundColor: Colors.red,
              activeIcon: Icon(Icons.code, size: 30, color: Colors.red),
              icon: Icon(Icons.code, size: 30, color: Colors.black),
              title: Text('QR')),
          BubbleBottomBarItem(
              backgroundColor: Colors.red,
              activeIcon:
                  Icon(Icons.notifications, size: 30, color: Colors.red),
              icon: Stack(
                children: <Widget>[
                  Icon(Icons.notifications, size: 30, color: Colors.black),
                  isLoading ? Text('') : change_icon()
                ],
              ),
              title: Text('Notify')),
          BubbleBottomBarItem(
              backgroundColor: Colors.red,
              icon: Icon(Icons.message, size: 30, color: Colors.black),
              activeIcon: Icon(Icons.message, size: 30, color: Colors.red),
              title: Text('Chat')),
        ],
      ),
    );
  }
}