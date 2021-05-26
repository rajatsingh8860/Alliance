import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHandler{


  Future<bool> checkNumber(String phoneNumber) async{
    var number = [];
    await  Firestore.instance.collection('User Detail').getDocuments().then((QuerySnapshot querySnapshot) =>{
      querySnapshot.documents.forEach((doc) {
        if(doc.data.containsValue(phoneNumber)){
          number.add(false);
          print(false);
        }else if(!doc.data.containsValue(phoneNumber)){
          number.add(true);
          print(true);
        }
        print('array ${number}');
      })
    });
    if(number.contains(false)){
      return false;
    }else if(!number.contains(false)){
      return true;
    }
  }

  

 Future addUserDetail(String name,String phoneNumber, String Uid) {
    Firestore.instance.collection('User Detail').document(Uid).setData({
      'name': name,
      'phoneNumber': '+91${phoneNumber}',
      'url':
      'https://firebasestorage.googleapis.com/v0/b/league-f3900.appspot.com/o/images%2Fimage_picker3141734319901713599.jpg?alt=media&token=9c994b87-ffce-4a59-9691-3f1ef4bd2df3',
      'products':[]
    });
  }
}