import 'package:alliance/views/Constants.dart';
import 'package:alliance/views/CustomButton.dart';
import 'package:alliance/views/DataBaseHelper.dart';
import 'package:alliance/views/LoginScreen.dart';
import 'package:alliance/views/RoundTextField.dart';
import 'package:alliance/views/VerificationScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  bool _termsChecked = false;
  var numberAvailable = true;
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: blue,
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Stack(
            children: [
              Container(
                height: _height/1.04,
                width: _width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        'assets/design.png',
                      ),
                      fit: BoxFit.cover),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top:_height*0.06,left:_width/4),
                width: _width/2,
                height: _height * 0.3,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/logo.jpg'),
                
                  fit: BoxFit.cover,
                )),
              ),
              Padding(
                padding: EdgeInsets.only(top: _height / 2.3),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _width * 0.05, horizontal: _width * 0.05),
                      child: Text(
                        "Register",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveFlutter.of(context).fontSize(4),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    RoundTextField(
                      label: 'Name',
                      controller: name,
                      textValidator: (String value) {
                        if (value.isEmpty) {
                          return "Please enter Name.";
                        }
                      },
                    ),
                    RoundTextField(
                        label: 'Phone Number',
                        controller: phoneNumber,
                        input: TextInputType.number,
                        textValidator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter number.";
                          }
                        }),
                  
                    CustomButton(
                      label: "Register",
                      action: () async {
                        if (formKey.currentState.validate()) {
                            var number = await DatabaseHandler()
                                .checkNumber('+91${phoneNumber.text}');
                            setState(() {
                              numberAvailable = number;
                            });
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (
                                  BuildContext context,
                                ) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                });
                            Navigator.pop(context);
                            numberAvailable
                                ? Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                    return VerificationScreen(
                                      phoneNo: phoneNumber.text,
                                      name: name.text,
                                    );
                                  }))
                                : Fluttertoast.showToast(
                                    msg: 'Number Already Exists');
                         
                        }
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            (context),
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _width * 0.03, horizontal: _width * 0.05),
                        child: Text(
                          "Already Register? Login here.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
