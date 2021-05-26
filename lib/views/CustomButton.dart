import 'package:alliance/views/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class CustomButton extends StatefulWidget {
  final label;
  final action;

  const CustomButton({this.label, this.action}) ;

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveFlutter.of(context).scale(10),horizontal: ResponsiveFlutter.of(context).scale(20)),
      child: Container(
        height : ResponsiveFlutter.of(context).scale(45),
        width: ResponsiveFlutter.of(context).scale(350),
        child: ElevatedButton(
          child: Padding(
            padding:EdgeInsets.all(_width*0.03),
            child: Text(widget.label,
            style: TextStyle(
              fontSize: 20.0,
            ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: yellow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            )
          ),
          onPressed:widget.action,
        ),
      ),
    );
  }
}
