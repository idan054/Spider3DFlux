
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
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


  // String? selectedToken;
  //
  // String? id;
  // String token;
  // int users_usage = 0;

  // print(_users.docs.first.data());
/*  for (var user in _users.docs) {
    // print(user.data());
    id = user.id;
    token = user.get('Token');
    users_usage = user.get('users_usage');
    print(
        '--------------\nusers_usage: $users_usage | Token: $token | doc id: $id');
    if (users_usage < 10) {
      selectedToken = token;
      await thingi
          .doc(id)
          .update({'users_usage': users_usage + 1})
          .then((value) => print('users_usage ++'))
          .catchError((error) => print('Failed to update user: $error'));

      print(
          '${users_usage + 1} / 10 selectedToken: $selectedToken (Success) \n--------------');
      print('selectedToken = $selectedToken (Full)');
    }
  }*/

}