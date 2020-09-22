import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'group_detail.dart';
import 'package:alliance/views/group_detail.dart';

class CrudeMethod{
  Future<void> addData(blogData) async{
    Firestore.instance.collection("Alliance").add(blogData).catchError((e){
      print(e);
    });
  }

  Future<void> addemail(blogData) async{
    Firestore.instance.collection("Email Collection").add(blogData).catchError((e){
      print(e);
    });
  }


  updateData(selectedDoc, newValues) {
        Firestore.instance
        .collection('Alliance')
        .document(selectedDoc)
        .updateData(newValues)
        .catchError((e){
      print(e);
    });
  }



  
}



