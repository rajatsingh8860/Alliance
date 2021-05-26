import 'package:alliance/views/Constants.dart';
import 'package:alliance/views/CustomButton.dart';
import 'package:alliance/views/DataBaseHelper.dart';
import 'package:alliance/views/RegisterScreen.dart';
import 'package:alliance/views/RoundTextField.dart';
import 'package:alliance/views/VerificationScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController name = TextEditingController();

  TextEditingController phoneNumber = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var numberAvailable = true;
  var error = '';

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
                padding: EdgeInsets.only(top: _height * 0.5),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _width * 0.03, horizontal: _width * 0.05),
                      child: Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    RoundTextField(
                      label: 'Phone Number',
                      controller: phoneNumber,
                      input: TextInputType.number,
                      textValidator: (String value) {
                        if (value.isEmpty) {
                          return "Please enter number.";
                        }
                      },
                    ),
                    CustomButton(
                      label: "Login",
                      action: () async {
                        if (formKey.currentState.validate()) {
                          var number = await DatabaseHandler()
                              .checkNumber('+91${phoneNumber.text}');
                          setState(() {
                            numberAvailable = number;
                          });
                          // if (value.user != null) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (
                                BuildContext context,
                              ) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              });
                          Navigator.pop(context);
                          numberAvailable
                              ? Fluttertoast.showToast(
                                  msg: 'Number not registered. Please Register')
                              : Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                  return VerificationScreen(
                                    phoneNo: phoneNumber.text,
                                  );
                                }));
                        }
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            (context),
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()));
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _width * 0.03, horizontal: _width * 0.05),
                        child: Text(
                          "Not Registered? Register here.",
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
    ;
  }
}
