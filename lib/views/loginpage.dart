import 'package:alliance/views/group_list.dart';
import 'package:flutter/material.dart';
import 'package:alliance/views/const.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<Login> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;
  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  Future<Null> handleSignIn() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    FirebaseUser firebaseUser =
        (await firebaseAuth.signInWithCredential(credential));
    if (firebaseUser != null) {
      //If user is already Signed In
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        //Update data if user is new
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'nickname': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'flag': 0
        });
        //Save data locally
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        //Write Data Locally
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
      }
      setState(() {
        isLoading = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context)=>GroupList(firebaseUser.uid)));
    }
    else{
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/peace.jpg'),
          fit: BoxFit.cover
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
          body: Stack(children: <Widget>[
            Container(
              margin: EdgeInsets.only(top:height/8),
              child:Column(
                children: [
                  Center(
                    child: Text("Alliance",
                      style: TextStyle(
                        fontSize: 50,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  SizedBox(height:height/50),
                  Text("The real world is calling",
                    style: TextStyle(
                        fontSize: 30,
                        fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              )
            ),
                Container(
                  margin: EdgeInsets.only(top:height/1.2,left:width/6,right: width/6),
                  child: SizedBox(
                    width:double.infinity,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: handleSignIn,
                      child: Text(
                        "Google Sign In",
                        style: TextStyle(fontSize: 16),
                      ),
                      color: Color(0xffdd4b39),
                      highlightColor: Color(0xffff7f7f),
                      splashColor: Colors.transparent,
                      textColor: Colors.white,
            //    padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                    ),
                  ),
                ),
            Positioned(
                child: isLoading ? Center(child: const CircularProgressIndicator()) : Container()
            )
          ])),
    );
  }
}
