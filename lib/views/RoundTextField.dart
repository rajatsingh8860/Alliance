import 'package:alliance/views/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_flutter/responsive_flutter.dart';


class RoundTextField extends StatelessWidget {
  final controller;
  final label;
  final input;
  final textValidator;
  const RoundTextField({ this.controller, this.label, this.input, this.textValidator});
  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: ResponsiveFlutter.of(context).scale(10),horizontal: ResponsiveFlutter.of(context).scale(20)),
      child: Container(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(
              color: Colors.black
            ),
            filled: true,
            fillColor: Colors.white,
            focusedBorder:  OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color:yellow,width: 1.0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: yellow,width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: yellow,width: 1.0),
            ),
          ),
          keyboardType: input,
          validator: textValidator
        ),
      ),
    );
  }
}
