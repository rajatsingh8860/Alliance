import 'package:alliance/views/group_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class Upcoming extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return UpcomingState();
  }
}

class UpcomingState extends State<Upcoming>{
  
List<String> suggestions = List();

   @override
  void initState() {
  super.initState();
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


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Upcoming Event",
          style: TextStyle(
              //  fontWeight: FontWeight.bold,
              fontSize: 25,
              fontFamily: 'Oswald',
              color: Colors.black),
        ),
       actions:<Widget>[
         IconButton(icon: Icon(Icons.search), onPressed: (){
           showSearch(context: context, delegate: DataSearch(suggestions));
         })
       ]
      ),
      body:StreamBuilder(
                  stream: Firestore.instance
                      .collection('Alliance')
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
                                            time,snapshot.data.documents[i].data['fees']);
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
                  ), 
                    );
  }
}

class DataSearch extends SearchDelegate<String>{
 DataSearch(this.suggestions);  
 List<String> suggestions= List();
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
                                            time,snapshot.data.documents[i].data['fees']);
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
    final suggestionList = suggestions.where((element) => element.startsWith(query)).toList();
    return ListView.builder(
      itemBuilder: (context,index) => ListTile(
        onTap: (){
          query = suggestionList[index];
          showResults(context);
        },
          leading: Icon(Icons.group,color: Hexcolor('#ffcc00')),
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