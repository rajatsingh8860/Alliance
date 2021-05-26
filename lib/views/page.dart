
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alliance/views/crud.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';

class addGroup extends StatefulWidget {
  String photoUrl;
  addGroup();
  State<StatefulWidget> createState() {
    return GroupPageState();
  }
}

/////Copied from Stack overflow

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  MultiSelectDialog({Key key, this.items, this.initialSelectedValues})
      : super(key: key);

  final List<MultiSelectDialogItem<V>> items;
  final Set<V> initialSelectedValues;


  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = Set<V>();
    String documentId;

  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues);
    }
  }

  

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues);
  }
  

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose Interests'),
      contentPadding: EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: widget.items.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('CANCEL'),
          onPressed: _onCancelTap,
        ),
        FlatButton(
          child: Text('OK'),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return CheckboxListTile(
      value: checked,
      title: Text(item.label),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked),
    );
  }
}

/////////////////////

class GroupPageState extends State<addGroup> {
  GroupPageState();
  String photoUrl;
 // bool isLoading;
  TimeOfDay time = TimeOfDay.now();

   @override
  void initState() {
    isLoading = true;
    super.initState();
    getPhotoUrl();
  }
   
  

  getPhotoUrl() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      if (user.photoUrl != null) {
        photoUrl = user.photoUrl;
      } else {
        photoUrl = "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fphotos%2Fone-person&psig=AOvVaw0xphJEp-I1hhtp5VAOsOaT&ust=1622110033168000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCPing_eM5_ACFQAAAAAdAAAAABAD";
      }
    });
    isLoading = false;
  }
  

  DateTime selectedDate = DateTime.now();

  Future<DateTime> selectDate(BuildContext context) {
    return showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(seconds: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
  }

  Future<TimeOfDay> selectTime(BuildContext context) {
    //DateTime time = showTimePicker(context: context, initialTime: time);
    return showTimePicker(context: context, initialTime: time);
  }

  String groupName, description, email, distanceInKm;
  String location;
  var latitude,longitude;
  String id;
  List<String> interest = List();
  int seat_count;
  File selectedImage;
  bool isLoading = false;
  List<DropdownMenuItem<String>> ListDrop = [];
  int distance_in_km;
  int currentValue = 0;
  String selected = null;
  final _formKey = GlobalKey<FormState>();

  List<String> teamCreatorInterest = List();
  CrudeMethod crudeMethod = CrudeMethod();
  List<MultiSelectDialogItem<int>> multiItem = List();
  var startPoint = TextEditingController();
  String documentId;
  List<String> x =List();
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = image;
    });
  }
  
  getLatitudeAndLongitude(String eventAddress) async {
      List<Placemark> placemark = await Geolocator().placemarkFromAddress(eventAddress);
      setState(() {
        latitude = placemark.first.position.latitude;
        longitude = placemark.first.position.longitude;
      });
  }

  uploadData() async {
     FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      documentId = user.uid;
    });
   
   
   Firestore.instance.collection("User_Group_$documentId").snapshots().listen((event) {
       event.documents.forEach((element) {
         setState(() {
           x.add(element["joinedGroupName"]);
         });
       });
   });
    if (selectedImage != null) {
      setState(() {
        isLoading = true;
      });
      //This is used to upload image to firebase database.
      StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("Alliance")
          .child("${randomAlphaNumeric(9)}.jpg");
      final StorageUploadTask task = firebaseStorageRef.putFile(selectedImage);
      var downloadUrl = await (await task.onComplete).ref.getDownloadURL();
      Map<String, dynamic> blogMap = {
        'id':randomAlphaNumeric(9),
        "imgUrl": downloadUrl,
        "groupName": groupName,
        "description": description,
        "location": startPoint.text,
        "latitude": latitude,
        "longitude": longitude,
        "interest": teamCreatorInterest,
        "email": email,
        "seat": currentValue,
        "flag": 0,
        "time": time.toString(),
        "date": selectedDate,
      };
    //  Fluttertoast.showToast(msg: x.toString());
    if(x.contains(groupName)){
      Map<String , dynamic >notificationData={
         'date': selectedDate,
         'groupName': groupName,
         "imgUrl": downloadUrl,
      };
      Firestore.instance.collection("Notification_data_$documentId").add(notificationData).catchError((e){
      print(e);
    });
    Firestore.instance
          .collection('Notification_Icon')
          .document(documentId)
          .setData({'icon_count': '0'});
    }
      crudeMethod.addData(blogMap).then((value) {
        Navigator.pop(context);
      });
     
     
    }
  }

  
  

  loadData() {
    ListDrop = [];
    ListDrop.add(
        new DropdownMenuItem(child: new Text("Music"), value: "Music"));
    ListDrop.add(
        new DropdownMenuItem(child: new Text("Dance"), value: "Dance"));
    ListDrop.add(
        new DropdownMenuItem(child: new Text("Drama"), value: "Drama"));
         ListDrop.add(
        new DropdownMenuItem(child: new Text("Drama"), value: "Coding"));
  }

  showNumberDialog(BuildContext context) {
    showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: 0,
            maxValue: 5000,
            initialIntegerValue: 0,
            cancelWidget: Container(),
            highlightSelectedValue: true,
          );
        }).then((value) {
      setState(() {
        if (value > 0) {
          currentValue = value;
        }
      });
    });
  }

  final valuestopopulate = {1: "Music", 2: "Dance", 3: "Drama",4: "Coding"};

  void populateMultiSelect() {
    for (int v in valuestopopulate.keys) {
      multiItem.add(MultiSelectDialogItem(v, valuestopopulate[v]));
    }
  }

  void _showMultiSelect(BuildContext context) async {
    multiItem = [];
    populateMultiSelect();
    final items = multiItem;
    final selectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: items,
          initialSelectedValues: [1].toSet(),
        );
      },
    );
    getValueFromSet(selectedValues);
  }

  getValueFromSet(Set selection) {
    if (selection != null) {
      for (int x in selection.toList()) {
        setState(() {
          teamCreatorInterest.add(valuestopopulate[x]);
        });
      }
    } 
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    loadData();
    return Scaffold(
        body: new Form(
      key: _formKey,
      //   width: double.infinity,
      // color: new_color
      child: isLoading
          ? Container(
              color: Colors.white, alignment: Alignment.center, child: Loader())
          : new ListView(
              //crossAxisAlignment: CrossAxisAlignment.start,
              //   child: new Column(
              children: <Widget>[
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.all(0.0),
                  // child: Form(
                  //  key: _formKey,
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          height: height / 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              new Center(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                  child: Image(
                                    height: height / 6,
                                    width: width / 2.8,
                                    fit: BoxFit.cover,
                                    image: NetworkImage(photoUrl),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text("Start a new Meetup group",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Oswald',
                                  ))
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        new Container(
                          // padding:EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              border: Border(
                            bottom: BorderSide(color: Colors.white),
                          )),
                          child: new Column(children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: new Container(
                                color: Colors.white,
                                child: new Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        getImage();
                                      },
                                      child: selectedImage != null
                                          ? Container(
                                              //  child: ClipRRect(
                                              //    borderRadius:
                                              //      BorderRadius.circular(
                                              //        90),
                                              child: Image.file(selectedImage,
                                                  fit: BoxFit.cover),
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 16),
                                              height: 170,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                            )
                                          : Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 16),
                                              height: 170,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(top: 50),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "Add Event Image",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 25,
                                                          fontFamily: 'Oswald',
                                                          color: Colors.grey),
                                                    ),
                                                    Icon(
                                                      Icons.add_a_photo,
                                                      color: Colors.grey,
                                                    )
                                                  ],
                                                ),
                                              )),
                                    ),
                                    SizedBox(height: 20),
                                    new Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: TextFormField(
                                        validator: (String value) {
                                          if (value.isEmpty) {
                                            return "Please enter event name";
                                          }
                                        },
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.only(left: 10),
                                            hintText: "Event Name",
                                            hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontFamily: "Trojan",
                                                fontWeight: FontWeight.w600),
                                            border: InputBorder.none),
                                        onChanged: (val) {
                                          groupName = val;
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    //  SizedBox(height: 10.0),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: new Row(
                                        children: <Widget>[
                                          new Container(
                                              // margin:
                                              //  EdgeInsets.only(left: 10.0),
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]),
                                              )),
                                              child: RaisedButton(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text("Interest"),
                                                      SizedBox(
                                                          width: width / 7),
                                                      Icon(Icons
                                                          .check_circle_outline)
                                                    ],
                                                  ),
                                                  onPressed: () {
                                                    _showMultiSelect(context);
                                                  })),
                                          SizedBox(width: width / 16),
                                          Expanded(
                                            child: RaisedButton(
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                      "Slots : ${currentValue}"),
                                                  SizedBox(width: width / 8),
                                                  // Icon(Icons.arrow_drop_down)
                                                ],
                                              ),
                                              onPressed: () {
                                                showNumberDialog(context);
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: new Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: RaisedButton(
                                                  onPressed: () async {
                                                    final selectedDate =
                                                        await selectDate(
                                                            context);
                                                    if (selectedDate == null)
                                                      return;

                                                    setState(() {
                                                      this.selectedDate =
                                                          selectedDate;
                                                    });
                                                  },
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text("Date"),
                                                      SizedBox(
                                                        width: width / 5,
                                                      ),
                                                      Icon(Icons.calendar_today)
                                                    ],
                                                  )),
                                            ),
                                          ),
                                          SizedBox(width: width / 18),
                                          Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: RaisedButton(
                                                  onPressed: () async {
                                                    final selectedTime =
                                                        await selectTime(
                                                            context);
                                                    setState(() {
                                                      if (selectedTime !=
                                                          null) {
                                                        this.time =
                                                            selectedTime;
                                                      }
                                                    });
                                                  },
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text("Time"),
                                                      SizedBox(
                                                          width: width / 6),
                                                      Icon(Icons.access_time)
                                                    ],
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    new Container(
                                      // color: Colors.grey[200],
                                      margin: EdgeInsets.only(
                                          left: width / 22, right: width / 20),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: TextFormField(
                                        validator: (String value) {
                                          if (value.isEmpty) {
                                            return "Please add location";
                                          }
                                        },
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.only(left: 10),
                                            hintText: "Add Location",
                                            hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontFamily: "Trojan",
                                                fontWeight: FontWeight.w600),
                                            border: InputBorder.none),
                                        controller: startPoint,
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return MapBoxAutoCompleteWidget(
                                                apiKey:
                                                    "pk.eyJ1IjoicmFqYXQta3VtYXIiLCJhIjoiY2tjbG16dzJtMXowbzJ0bHBsM3l6dDJvdiJ9.NN4o5bdtODCPPCvpYluKAA",
                                                hint: "Choose Location",
                                                onSelect: (place) {
                                                  startPoint.text =
                                                      place.placeName;
                                                   getLatitudeAndLongitude(place.placeName);
                                                },
                                                limit: 10);
                                          }));
                                        },
                                        enabled: true,
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    new Container(
                                      margin: EdgeInsets.only(
                                          left: width / 22, right: width / 20),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: TextFormField(
                                        validator: (String value) {
                                          Pattern pattern =
                                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                          RegExp regex = new RegExp(pattern);
                                          if (!regex.hasMatch(value)) {
                                            return "Not a valid email";
                                          }
                                        },
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.only(left: 10),
                                            hintText: "Email",
                                            hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontFamily: "Trojan",
                                                fontWeight: FontWeight.w600),
                                            border: InputBorder.none),
                                        onChanged: (val) {
                                          email = val;
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    new Container(
                                      margin: EdgeInsets.only(
                                          left: width / 22, right: width / 20),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        border: Border.all(color: Colors.black),
                                      ),
                                      child: TextFormField(
                                        validator: (String value) {
                                          if (value.isEmpty) {
                                            return "Please add description";
                                          }
                                        },
                                        minLines: 5,
                                        maxLines: 6,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.only(left: 10),
                                            hintText: "Description",
                                            hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontFamily: "Trojan",
                                                fontWeight: FontWeight.w600),
                                            border: InputBorder.none),
                                        onChanged: (val) {
                                          description = val;
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    GestureDetector(
                                      onTap: () {
                                        if (_formKey.currentState.validate()) {
                                          uploadData();
                                        }
                                      },
                                      child: new Container(
                                        height: 40,
                                        margin: EdgeInsets.only(
                                            left: width / 22,
                                            right: width / 20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors:[Colors.orange,Colors.pink]
                                          ),
                                          border:
                                              Border.all(color: Colors.black),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(width: width / 3),
                                            Text("Create Event",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'Oswald',
                                                )),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ]),
                        )
                      ]),
                  //)
                ),
                SizedBox(height: 20.0),
              ],
              // )
            ),
    ));
  }
}

class Loader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoaderState();
  }
}

class LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation_rotation;
  Animation<double> animation_radius_in;
  Animation<double> animation_radius_out;
  final double initial_radius = 30.0;
  double radius = 0.0;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    animation_rotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: controller, curve: Interval(0.0, 1.0, curve: Curves.linear)));

    animation_radius_in = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.75, 1.0, curve: Curves.elasticIn)));
    animation_radius_out = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.25, curve: Curves.elasticOut)));
    controller.addListener(() {
      setState(() {
        if (controller.value >= 0.75 && controller.value <= 1.0) {
          radius = animation_radius_in.value * initial_radius;
        } else if (controller.value >= 0.0 && controller.value <= 0.25) {
          radius = animation_radius_out.value * initial_radius;
        }
      });
    });
    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100,
        height: 100,
        child: Center(
          // child:RotationTransition(
          // turns:animation_rotation,
          child: new Stack(children: <Widget>[
            Dot(radius: 30.0, color: Colors.blue),
            Transform.translate(
              offset: Offset(radius * cos(pi / 4), radius * sin(pi / 4)),
              child: Dot(radius: 5.0, color: Colors.redAccent),
            ),
            Transform.translate(
              offset:
                  Offset(radius * cos(2 * pi / 4), radius * sin(2 * pi / 4)),
              child: Dot(radius: 5.0, color: Colors.blueAccent),
            ),
            Transform.translate(
              offset:
                  Offset(radius * cos(3 * pi / 4), radius * sin(3 * pi / 4)),
              child: Dot(radius: 5.0, color: Colors.redAccent),
            ),
            Transform.translate(
              offset:
                  Offset(radius * cos(4 * pi / 4), radius * sin(4 * pi / 4)),
              child: Dot(radius: 5.0, color: Colors.blueAccent),
            ),
            Transform.translate(
              offset:
                  Offset(radius * cos(5 * pi / 4), radius * sin(5 * pi / 4)),
              child: Dot(radius: 5.0, color: Colors.redAccent),
            ),
            Transform.translate(
              offset:
                  Offset(radius * cos(6 * pi / 4), radius * sin(6 * pi / 4)),
              child: Dot(radius: 5.0, color: Colors.blueAccent),
            ),
            Transform.translate(
              offset:
                  Offset(radius * cos(7 * pi / 4), radius * sin(7 * pi / 4)),
              child: Dot(radius: 5.0, color: Colors.redAccent),
            ),
            Transform.translate(
              offset:
                  Offset(radius * cos(8 * pi / 4), radius * sin(8 * pi / 4)),
              child: Dot(radius: 5.0, color: Colors.blueAccent),
            )
          ]),
          //  )//
        ));
  }
}

class Dot extends StatelessWidget {
  final double radius;
  final Color color;
  Dot({this.radius, this.color});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: this.radius,
          height: this.radius,
          decoration: BoxDecoration(color: this.color, shape: BoxShape.circle)),
    );
  }
}
