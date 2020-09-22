import 'package:contactus/contactus.dart';
import 'package:flutter/material.dart';

class About extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body:Container(
        margin:EdgeInsets.only(top: height/10),
        child:ContactUs(
        textColor: Colors.black,
        cardColor: Colors.orangeAccent,
        logo: AssetImage("assets/profile.jpg"),
        email: 'rajatsingh9212@gmail.com',
        companyName: 'Rajat Kumar Singh',
        phoneNumber: '8860533811',
        githubUserName: 'rajatsingh8860',
        linkedinURL: 'https://www.linkedin.com/in/rajat-kumar-singh-480867185/',
        tagLine: 'Flutter Developer',
        instagram:'rajatsingh6891',
        companyFontSize: 35,
      )
      )
    );
  }

}