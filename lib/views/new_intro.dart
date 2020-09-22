import 'dart:io';
import 'package:alliance/data/data.dart';
import 'package:alliance/views/group_list.dart';
import 'package:alliance/views/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Intro extends StatefulWidget {
  @override
  IntroState createState() => IntroState();
}

class IntroState extends State<Intro> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  List<String> selectedChoice = List();
  SharedPreferences prefs;
  bool isLoading = false;
  AuthService authService = AuthService();
  bool isLoggedIn = false;
  List<Widget> choices = List();
  FirebaseUser currentUser;
  List<SliderModel> mySLides = new List<SliderModel>();
  List<String> reportList = ["Music", "Dance", "Coding", "Drama","Music", "Dance", "Coding", "Drama","Music", "Dance", "Coding", "Drama"];
  int slideIndex = 0;
  PageController controller;

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
    } else {
      setState(() {
        isLoading = false;
      });
    }
    return firebaseUser.uid;
  }


  Widget _buildPageIndicator(bool isCurrentPage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      height: isCurrentPage ? 10.0 : 6.0,
      width: isCurrentPage ? 10.0 : 6.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mySLides = getSlides();
    controller = new PageController();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    buildChoiceList(){
      List<Widget> choices = List();
      reportList.forEach((element) {
        choices.add(Container(
            padding: EdgeInsets.only(top: height / 8),
            child: ChoiceChip(
              backgroundColor: Hexcolor('#ffcc00'),
              label: Text(element,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,fontFamily: 'Oswald',)),
              selected: selectedChoice.contains(element),
              onSelected: (selected) async {
                setState(() {
                  selectedChoice.contains(element) ? selectedChoice.remove(element) : selectedChoice.add(element);
                });
                FirebaseUser user =
                await FirebaseAuth.instance.currentUser();
                String userId = user.uid;
                if(userId.length < 2){
                  Fluttertoast.showToast(msg: "Rajat");
                }
                else{
                  Fluttertoast.showToast(msg: userId);
                }
                Firestore.instance
                    .collection('Interest')
                    .document(userId)
                    .setData({
                  'data': FieldValue.arrayUnion(selectedChoice)
                });
              },
            )
        ),
        );
      }
      );
      Fluttertoast.showToast(msg: selectedChoice.toString());
      return choices;
    }


    return Stack(
      children: [
        Container(
          child: Scaffold(
            // backgroundColor: Colors.white,
            body: Container(
              height: MediaQuery.of(context).size.height-100,
              child: PageView(
                controller: controller,
                onPageChanged: (index) {
                  setState(() {
                    slideIndex = index;
                  });
                },
                children: <Widget>[
                  SlideTile(
                    imagePath: mySLides[0].getImageAssetPath(),
                    title: mySLides[0].getTitle(),
                    desc: mySLides[0].getDesc(),
                  ),
                  SlideTile(
                    imagePath: mySLides[1].getImageAssetPath(),
                    title: mySLides[1].getTitle(),
                    desc: mySLides[1].getDesc(),
                  ),
                  SlideTile(
                    imagePath: mySLides[2].getImageAssetPath(),
                    title: mySLides[2].getTitle(),
                    desc: mySLides[2].getDesc(),
                  ),

                ],
              ),
            ),
            bottomSheet: slideIndex !=2
                ? Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            controller.animateToPage(2,
                                duration: Duration(milliseconds: 400),
                                curve: Curves.linear);
                          },
                          splashColor: Colors.blue[50],
                          child: Text(
                            "SKIP",
                            style: TextStyle(
                                color: Color(0xFF0074E4),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              for (int i = 0; i < 3; i++)
                                i == slideIndex
                                    ? _buildPageIndicator(true)
                                    : _buildPageIndicator(false),
                            ],
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            print("this is slideIndex: $slideIndex");
                            controller.animateToPage(slideIndex + 1,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.linear);
                          },
                          splashColor: Colors.blue[50],
                          child: Text(
                            "NEXT",
                            style: TextStyle(
                                color: Color(0xFF0074E4),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ):
                Container(
                      margin: EdgeInsets.only(
                          bottom: height / 8,
                          left: width / 8,
                          right: width / 8),
                      height: Platform.isIOS ? 50 : 60,
                      child: SizedBox(
                        child: InkWell(
                          onTap: handleSignIn,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color:Colors.black),
                              color: Hexcolor('#ffcc00'),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: width / 15),
                                Container(
                                  height: 25,
                                  child: Image(
                                    image:
                                        AssetImage("assets/google_sign_in.png"),
                                  ),
                                ),
                                new SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "Sign In With Google",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Oswald',
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            //    padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                          ),
                        ),
                      ),
                    )
                  ),
          ),

        Positioned(
            child: isLoading
                ? Center(child: const CircularProgressIndicator())
                : Container())
      ],
    );
  }
}

class SlideTile extends StatelessWidget {
  String imagePath, title, desc;

  SlideTile({this.imagePath, this.title, this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),

      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(imagePath),
          SizedBox(
            height: 40,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40,fontFamily: 'Oswald',),
          ),
          SizedBox(
            height: 20,
          ),
          Text(desc,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25,fontFamily: 'Oswald',))
        ],
      ),
    );
  }
}
