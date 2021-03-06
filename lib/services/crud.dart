import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class CrudMethods {
  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }

  // Widget build(BuildContext context) {
  //   String userId = 'userId';
  //   return new StreamBuilder(
  //       stream:
  //           Firestore.instance.collection('user').document(userId).snapshots(),
  //       builder: (context, snapshot) {
  //         if (!snapshot.hasData) {
  //           return new Text("Loading");
  //         }
  //         var userDocument = snapshot.data;
  //         myAddress = userDocument["address"];
  //         myPcode =userDocument["postalCode"];
  //         print(myAddress);
  //         return new Text(userDocument["name"]);
  //       });
  // }

  Future<void> addData(profileData) async {
    if (isLoggedIn()) {
      Firestore.instance.collection('profile').add(profileData).catchError((e) {
        print(e);
      });
    }
  }

  Future<void> addLetter(letterData) async {
    if (isLoggedIn()) {
      Firestore.instance.collection('letters').add(letterData).catchError((e) {
        print(e);
      });
    }
  }
  getAdmin() async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
        var userDocument = await Firestore.instance.collection('user').document(user.uid).get();
        bool _myAdmin = userDocument["admin"];
        print(_myAdmin);
  }
  getData() async {
    return await Firestore.instance
          .collection('cases')
          .document('hNZISn2aVmS6Ow5Ipye3')
          .get();
  }
  getProfile() async {
    return Firestore.instance.collection('profile').snapshots();
  }

  getDataFromUserFromDocument() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance.collection('user').document(user.uid).get();
  }

  getDataFromUserFromDocumentWithID(userID) async {
    return await Firestore.instance.collection('user').document(userID).get();
  }

  getDataFromUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return Firestore.instance.collection('user').document(user.uid).snapshots();
  }

  createOrUpdateUserData(Map<String, dynamic> userDataMap) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
//    print('USERID ' + user.uid);
    DocumentReference ref =
        Firestore.instance.collection('user').document(user.uid);
    return ref.setData(userDataMap, merge: true);
  }
    createOrUpdateAdminData(Map<String, dynamic> userDataMap) async {
    DocumentReference ref =
        Firestore.instance.collection('user').document();
    return ref.setData(userDataMap, merge: true);
  }

  updateData(newValues) {
    Firestore.instance
        .collection('cases')
        .document("hNZISn2aVmS6Ow5Ipye3")
        .updateData(newValues)
        .catchError((e) {
      print(e);
    });
  }

  deleteData(docId) {
    Firestore.instance
        .collection('markers')
        .document(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }
}
