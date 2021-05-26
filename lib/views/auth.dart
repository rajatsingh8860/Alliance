import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Stream<String> get onAuthStateChanged{
    return FirebaseAuth.instance.onAuthStateChanged.map(
        (FirebaseUser user){
          return user?.uid;
        }
    );
  }
Future<String> currentUser() async{
    FirebaseUser user=await FirebaseAuth.instance.currentUser();
    return user.uid;
}
//Sign out
signOut() async{
    return FirebaseAuth.instance.signOut();
}

user() async {
  GoogleSignInAccount googleUser = await googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
  FirebaseUser firebaseUser =
  (await firebaseAuth.signInWithCredential(credential));
  return firebaseUser;
}
}