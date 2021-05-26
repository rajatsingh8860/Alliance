import 'dart:async';
import 'package:alliance/views/Constants.dart';
import 'package:alliance/views/CustomButton.dart';
import 'package:alliance/views/DataBaseHelper.dart';
import 'package:alliance/views/LoaderDialog.dart';
import 'package:alliance/views/bottomNavigation.dart';
import 'package:alliance/views/group_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class VerificationScreen extends StatefulWidget {
  final name, phoneNo;

  const VerificationScreen({this.name, this.phoneNo});
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String verificationCode;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  FirebaseAuth auth = FirebaseAuth.instance;
  String teamId, smsPin = '';
  String errorMsg = '';
  var timeLeft = 120;
  var _timeleft;

  Timer _timer;
  int second1 = 120;
  int seconds = 0;
  int minutes = 2;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (minutes < 0) {
            timer.cancel();
            setState(() {
              timeLeft = 0;
            });
          } else {
            seconds = seconds - 1;
            if (seconds < 0) {
              minutes -= 1;
              seconds = 59;
            }
          }
          _timeleft = '${minutes}:${seconds}';
        },
      ),
    );
  }

  verifyPhoneNo() async {
    setState(() {
      timeLeft = 120;
      minutes = 2;
      smsPin = '';
      errorMsg = '';
      _pinPutController.text = '';
    });
    startTimer();
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phoneNo}',
        verificationCompleted: (AuthCredential credential) {},
        verificationFailed: (AuthException e) {
          setState(() {
            errorMsg = "Something went wrong";
          });
        },
        codeSent: (String verificationId, [int]) {
          setState(() {
            verificationCode = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            verificationCode = verificationId;
          });
        },
        timeout: Duration(seconds: 120));
  }

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: yellow),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  void initState() {
    verifyPhoneNo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    final _pinPutController = TextEditingController();
    final _pinPutFocusNode = FocusNode();
    return Scaffold(
      backgroundColor: blue,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: _height / 1.04,
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
              margin: EdgeInsets.only(top: _height * 0.06, left: _width / 4),
              width: _width / 2,
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
                        vertical: _width * 0.01, horizontal: _width * 0.05),
                    child: Text(
                      "Mobile Verification",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: _width * 0.01, horizontal: _width * 0.05),
                    child: Text(
                      "Enter OTP send to +91${widget.phoneNo}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveFlutter.of(context).fontSize(2),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: _width * 0.08, vertical: _height * 0.05),
                    child: PinPut(
                      textStyle: TextStyle(color: Colors.white),
                      fieldsCount: 6,
                      onSubmit: (String pin) {
                        smsPin = smsPin + pin;
                      },
                      focusNode: _pinPutFocusNode,
                      controller: _pinPutController,
                      submittedFieldDecoration: _pinPutDecoration.copyWith(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      selectedFieldDecoration: _pinPutDecoration,
                      followingFieldDecoration: _pinPutDecoration.copyWith(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: yellow.withOpacity(.5),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: _width * 0.08, vertical: _height * 0.03),
                    child: Center(
                      child: Container(
                        child: RichText(
                          text: TextSpan(
                              text: "Didn't received an OTP?",
                              style: TextStyle(
                                color: yellow,
                                fontSize: _width > 400
                                    ? LargeScreenSubLabel
                                    : SmallScreenSubLabel,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      timeLeft == 0 ? 'Send Again' : _timeleft,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      verifyPhoneNo();
                                    },
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: yellow,
                                  ),
                                )
                              ]),
                        ),
                      ),
                    ),
                  ),
                  CustomButton(
                      label: 'Verify',
                      action: () async {
                        try {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (
                                BuildContext context,
                              ) {
                                return LoaderDialog();
                              });
                          await FirebaseAuth.instance
                              .signInWithCredential(
                                  PhoneAuthProvider.getCredential(
                                      verificationId: verificationCode,
                                      smsCode: smsPin))
                              .then((value) async {
                            if (value.uid != null) {
                              var currUser =
                                  await FirebaseAuth.instance.currentUser();
                              setState(() {
                                teamId = currUser.uid;
                              });
                              if (widget.name != null) {
                                await DatabaseHandler().addUserDetail(
                                    widget.name, widget.phoneNo, teamId);
                              }
                              Navigator.pop(context);
                                                            Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return navigation();
                              }));
                            }
                          });
                        } catch (e) {
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context);
                          setState(() {
                            errorMsg = "Something went wrong";
                          });
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
