import 'package:alliance/views/group_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';

class Recomended extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return RecomendedState();
  }
}

class RecomendedState extends State<Recomended>{

  List<dynamic> interest_data = List();
  var distance_in_km;
  var currentLatitude,currentLongitude;
  List<String> recomendedUser = List();
   List<dynamic> filtered_user = List();
   List<String> suggestions = List();


  @override
  void initState() {
    super.initState();
    getArrayElements();
    getArrayElements();
    getFilteredUserList();
    getCurrentLocation();
    getGroupWithinRange();
    getSuggestions();
  }

  getSuggestions(){
    Firestore.instance.collection("Alliance").snapshots().listen((event) {
       event.documents.forEach((element) async {
         setState(() {
           suggestions.add(element["groupName"]);
         });
       });
   });
  }

   getCurrentLocation() async {
      final position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
      });
   }

   getFilteredUserList() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
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
   //  Fluttertoast.showToast(msg: filtered_user.toString());
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


getGroupWithinRange() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String documentId = user.uid;
    Firestore.instance.collection("Alliance").snapshots().listen((event) {
       event.documents.forEach((element) async {
        double distance = await Geolocator().distanceBetween(currentLatitude, currentLongitude, element["latitude"], element["longitude"]);
        distance_in_km = (distance~/1000).toInt();
        var set1=Set.from(element["interest"]);
        var set2=Set.from(interest_data);
        if(distance_in_km <= 20 && set1.intersection(set2).isNotEmpty){
         setState(() {
           recomendedUser.add(element["groupName"]);
         });
           final filtered_snapshot =
            await Firestore.instance
        .collection('Recomended')
        .document(documentId)
        .get();
      if(filtered_snapshot == null || !filtered_snapshot.exists){
          Firestore.instance.collection("Recomended").document(documentId).setData({'recomended_data': recomendedUser});
            }
            else{
              Firestore.instance.collection("Recomended").document(documentId).updateData({'recomended_data': recomendedUser});
            }
        }
       });
   });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Recomended Event",
          style: TextStyle(
              //  fontWeight: FontWeight.bold,
              fontSize: 25,
              fontFamily: 'Oswald',
              color: Colors.black),
        ),
        actions:<Widget>[
         IconButton(icon: Icon(Icons.search), onPressed: (){
           showSearch(context: context, delegate: DataSearch(filtered_user));
         })
       ]
      ),
      body:StreamBuilder(
                  stream: Firestore.instance
                      .collection('Alliance')
                      .where("groupName", whereIn: filtered_user)
                      .snapshots(),
                  builder: (BuildContext context, snapshot) {
                    if (!snapshot.hasData)
                      return Container(
                          alignment: Alignment.center, child: CircularProgressIndicator());
                    return Container(
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: new GridView.count(
                          crossAxisCount: 2,
                          scrollDirection: Axis.vertical,
                          physics: BouncingScrollPhysics(),
                        //  itemCount: snapshot.data.documents.length,
                          children: List.generate(snapshot.data.documents.length, (i) {
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
                                child: Hero(
                                  tag: image_url,
                                  child: GestureDetector(
                                    onTap: () async {
                                      FirebaseUser user = await FirebaseAuth
                                          .instance
                                          .currentUser();
                                      String userId = user.uid;
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return GroupDetail(
                                            snapshot
                                                .data.documents[i].documentID,
                                            userId,
                                            count,
                                            query,
                                            email_id,
                                            group_name,
                                            location,
                                            description,
                                            image_url,
                                            date,
                                            time);
                                      }));
                                    },
                                    child: Column(
                                        children: [
                                          Container(
                                            height: height / 6,
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
                                                        begin:
                                                            Alignment.topRight,
                                                        end: Alignment
                                                            .bottomLeft),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                //  child:Stack(
                                                //  children: [
                                                //    Positioned(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: Image.network(
                                                      image_url,
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
                                           Row(children: [
                                             Padding(
                                               padding:EdgeInsets.only(left: width/6),
                                              
                                             ),
                                             Text(
                                             date.toString().substring(0,10),
                                            style: TextStyle(
                                                //  fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                fontFamily: 'Oswald',
                                                color: Colors.black),
                                          ),
                                           ],)
                                          //   ),
                                        ],
                                      )
                                  ),
                                ));
                          },
                        ),
                      ),
                      )
                    );
                  }
                  ),   );
  }

}

class DataSearch extends SearchDelegate<String>{
 DataSearch(this.filtered_user);

 List<dynamic> filtered_user = List();

  @override
  List<Widget> buildActions(BuildContext context) {
      //Actions for app bar
      return[
        IconButton(icon: Icon(Icons.clear),onPressed: (){
          query = "";
        },)
      ];
    }
  
    @override
    Widget buildLeading(BuildContext context) {
     //leading icons on the left of app bar
     return IconButton(icon: AnimatedIcon(
       icon: AnimatedIcons.menu_arrow,
       progress:transitionAnimation,
       ), 
       onPressed:(){
         close(context, null);
       }
       );
    }
  
    @override
    Widget buildResults(BuildContext context) {
      // show some search  result based on selection
      var height= MediaQuery.of(context).size.height;
      var width = MediaQuery.of(context).size.width;
      return StreamBuilder(
                  stream: Firestore.instance
                      .collection('Alliance')
                      .where("groupName", whereIn: filtered_user)
                      .where("groupName",isEqualTo: query)
                      .snapshots(),
                  builder: (BuildContext context, snapshot) {
                    if (!snapshot.hasData)
                      return Container(
                          alignment: Alignment.center, child: CircularProgressIndicator());
                    return Container(
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: new GridView.count(
                          crossAxisCount: 2,
                          scrollDirection: Axis.vertical,
                          physics: BouncingScrollPhysics(),
                        //  itemCount: snapshot.data.documents.length,
                          children: List.generate(snapshot.data.documents.length, (i) {
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
                                child: Hero(
                                  tag: image_url,
                                  child: GestureDetector(
                                    onTap: () async {
                                      FirebaseUser user = await FirebaseAuth
                                          .instance
                                          .currentUser();
                                      String userId = user.uid;
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return GroupDetail(
                                            snapshot
                                                .data.documents[i].documentID,
                                            userId,
                                            count,
                                            query,
                                            email_id,
                                            group_name,
                                            location,
                                            description,
                                            image_url,
                                            date,
                                            time);
                                      }));
                                    },
                                    child: Column(
                                        children: [
                                          Container(
                                            height: height / 6,
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
                                                        begin:
                                                            Alignment.topRight,
                                                        end: Alignment
                                                            .bottomLeft),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                //  child:Stack(
                                                //  children: [
                                                //    Positioned(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: Image.network(
                                                      image_url,
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
                                           Row(children: [
                                             Padding(
                                               padding:EdgeInsets.only(left: width/6),
                                              
                                             ),
                                             Text(
                                             date.toString().substring(0,10),
                                            style: TextStyle(
                                                //  fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                fontFamily: 'Oswald',
                                                color: Colors.black),
                                          ),
                                           ],)
                                          //   ),
                                        ],
                                      )
                                  ),
                                ));
                          },
                        ),
                      ),
                      )
                    );
                  }
                  );
    }
  
    @override
    Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something
    final suggestionList = filtered_user.where((element) => element.startsWith(query)).toList();
    return ListView.builder(
      itemBuilder: (context,index) => ListTile(
        onTap: (){
          query = suggestionList[index];
          showResults(context);
        },
          leading: Icon(Icons.group,color: Hexcolor('#ffcc00'),),
          title: RichText(
            text: TextSpan(
              text: suggestionList[index].substring(0,query.length),
              style: TextStyle(
                color:Colors.black,
                fontWeight:FontWeight.bold
              ),
              children: [
                TextSpan(
                  text: suggestionList[index].substring(query.length),
                  style: TextStyle(
                color:Colors.grey,
              ),
                )
              ]
            ) 
            ),
        ),
      itemCount: suggestionList.length,
      );
  }

}