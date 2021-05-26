import 'package:alliance/views/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class NoDataFoundWidget extends StatelessWidget {
  final label;

  const NoDataFoundWidget(this.label) ;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      child: Center(
        child: Container(
          height:  height*0.5,
          width: width/1.1,
          child: Image.network("https://i.pinimg.com/564x/c9/22/68/c92268d92cf2dbf96e3195683d9e14fb.jpg",fit: BoxFit.cover,)
        ),
      ),
    );
  }
}
