import 'package:alliance/views/auth.dart';
import 'package:alliance/views/bottomNavigation.dart';
import 'package:alliance/views/group_list.dart';
import 'package:alliance/views/loginpage.dart';
import 'package:alliance/views/new_intro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: AuthService(),
      child: MaterialApp(
          title: 'Alliance',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
      
          home:HomeController(),
        routes: <String , WidgetBuilder>{
            '/login' : (BuildContext context)=> Intro(),
          '/home': (BuildContext context) => HomeController()
        }
      ),
    );
  }
}

class HomeController extends StatelessWidget{
  AuthService services = AuthService();
  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context).auth;
    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context,AsyncSnapshot<String> snapshot){
        if(snapshot.connectionState == ConnectionState.active){
          final bool signedIn = snapshot.hasData;
          return signedIn ? navigation() : Intro();
        }
      return CircularProgressIndicator();
      }
    );
  }

}
class Provider extends InheritedWidget {
  final AuthService auth;
  Provider({Key key, Widget child, this.auth}) : super(key: key, child: child);
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
  static Provider of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<Provider>());
}
