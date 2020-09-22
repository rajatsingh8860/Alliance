import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

class QRcode extends StatefulWidget{
  String email,groupName;
  QRcode(this.email,this.groupName);
  @override
  State<StatefulWidget> createState() {
    return QRcodeState(this.email,this.groupName);
  }
}
class QRcodeState extends State<QRcode>{
  String email,groupName;
  QRcodeState(this.email,groupName);
  @override
  Widget build(BuildContext context) {
    final height=MediaQuery.of(context).size.height;
    return new Scaffold(
      body:Container(
        color:Hexcolor('#ffcc00'),
              child: new Center(
          child:new Column(children: <Widget>[
            SizedBox(height:100),
            Text("Scan QR code to register yourself",
            style:TextStyle(
              fontSize:20,
              fontWeight:FontWeight.bold
            )
            ),
            SizedBox(height:height/4),
            QrImage(
              data: "$email $groupName",
              size:200
            )
          ],)
        ),
      )
    );
  }
}

class Loader extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return LoaderState();
  }
}
class LoaderState extends State<Loader> with SingleTickerProviderStateMixin{
  AnimationController controller;
  Animation<double> animation_rotation;
  Animation<double> animation_radius_in;
  Animation<double> animation_radius_out;
  final double initial_radius=30.0;
  double radius=0.0;
  
  @override
  void initState(){
    super.initState();
      controller = AnimationController(vsync: this,duration:Duration(seconds: 2));

      animation_rotation=Tween<double>(
        begin:0.0,
        end:1.0,
      ).animate(CurvedAnimation(
         parent: controller,
         curve: Interval(0.0, 1.0,curve: Curves.linear)
      ));

      animation_radius_in=Tween<double>(
        begin:1.0,
        end:0.0,
      ).animate(CurvedAnimation(
         parent: controller,
         curve: Interval(0.75, 1.0,curve: Curves.elasticIn)
      ));
      animation_radius_out=Tween<double>(
        begin:0.0,
        end:1.0,
      ).animate(CurvedAnimation(
         parent: controller,
         curve: Interval(0.0, 0.25,curve: Curves.elasticOut)
      ));
      controller.addListener((){
        setState(() {
          if(controller.value >=0.75 && controller.value <=1.0){
          radius=animation_radius_in.value*initial_radius;
        }
        else if(controller.value >=0.0 && controller.value <=0.25){
          radius=animation_radius_out.value*initial_radius;
        }
        }); 
      });
      controller.repeat();


  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width:100,
      height:100,
      child:Center(
       // child:RotationTransition(
         // turns:animation_rotation,
                  child: new Stack(
            children:<Widget>[
              Dot(
                radius:30.0,
                color:Colors.blue
              ),
              Transform.translate(
                offset: Offset(radius*cos(pi/4), radius*sin(pi/4)),
                            child: Dot(
                  radius:5.0,
                  color:Colors.redAccent
                ),
              ),
              Transform.translate(
                offset: Offset(radius*cos(2*pi/4), radius*sin(2*pi/4)),
                            child: Dot(
                  radius:5.0,
                  color:Colors.blueAccent
                ),
              ),
              Transform.translate(
                offset: Offset(radius*cos(3*pi/4), radius*sin(3*pi/4)),
                            child: Dot(
                  radius:5.0,
                  color:Colors.redAccent
                ),
              ),Transform.translate(
                offset: Offset(radius*cos(4*pi/4), radius*sin(4*pi/4)),
                            child: Dot(
                  radius:5.0,
                  color:Colors.blueAccent
                ),
              ),Transform.translate(
                offset: Offset(radius*cos(5*pi/4), radius*sin(5*pi/4)),
                            child: Dot(
                  radius:5.0,
                  color:Colors.redAccent
                ),
              ),Transform.translate(
                offset: Offset(radius*cos(6*pi/4), radius*sin(6*pi/4)),
                            child: Dot(
                  radius:5.0,
                  color:Colors.blueAccent
                ),
              ),Transform.translate(
                offset: Offset(radius*cos(7*pi/4), radius*sin(7*pi/4)),
                            child: Dot(
                  radius:5.0,
                  color:Colors.redAccent
                ),
              ),Transform.translate(
                offset: Offset(radius*cos(8*pi/4), radius*sin(8*pi/4)),
                            child: Dot(
                  radius:5.0,
                  color:Colors.blueAccent
                ),
              )
            ]
          ),
      //  )//
        )
    );
  }
  
}

class Dot extends StatelessWidget{
  final double radius;
  final Color color;
  Dot({this.radius,this.color});
  @override
  Widget build(BuildContext context) {
    return Center(
          child: Container(
       width:this.radius,
       height:this.radius,
       decoration: BoxDecoration(
         color:this.color,
         shape:BoxShape.circle
       )
      ),
    );
  }

}