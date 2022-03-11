/// Flutter code sample for DropdownButton

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  print('start');
  await Firebase.initializeApp();

  // CollectionReference thingi = FirebaseFirestore.instance.collection('thingi');
  var thingi = FirebaseFirestore.instance.collection('thingi')
      .where('users_usage', whereIn: [2, 3, 4, 5, 6, 7, 8, 9]);
  var _users = await thingi.get();
  print(_users.docs.length);
  print(_users.docs.first.data());

  thingi = FirebaseFirestore.instance.collection('thingi')
      .where('users_usage', isEqualTo: 10).limit(1);
  _users = await thingi.get();
  print(_users.docs.length);
  print(_users.docs.first.data());

}
