import 'package:cloud_firestore/cloud_firestore.dart';
// Import the firebase_core and cloud_firestore plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirestorePage(),
    );
  }
}

class FirestorePage extends StatefulWidget {
  const FirestorePage({Key? key}) : super(key: key);

  @override
  _FirestorePageState createState() => _FirestorePageState();
}

class _FirestorePageState extends State<FirestorePage> {
  CollectionReference thingi = FirebaseFirestore.instance.collection('thingi');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(children: [
      const SizedBox(
        height: 100,
      ),
      const TextButton(
        onPressed: addTokens,
        child: Text(
          'Add Tokens',
        ),
      ),
      ElevatedButton(
          onPressed: () async {
            await getThingiToken();
          },
          child: const Text('get Thingi Token')),
      Text('get token $selectedToken (Hot restart to update) \n+1 users_usage'),
      const SizedBox(
        height: 100,
      ),
    ])));
  }
}

CollectionReference thingi = FirebaseFirestore.instance.collection('thingi');
String? selectedToken;

Future<String?> getThingiToken() async {
// 1. Looking for token with users (usage) Less than 10
// 2. Found: Notify and add + 1 to users (usage), return  selectedToken
// 2. Not found: Notify, return  selectedToken as null

  String? id;
  String token;
  int users_usage = 0;
  var _users = await thingi.get();
  print(_users.docs.length);
  // print(_users.docs.first.data());
  for (var user in _users.docs) {
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
      return selectedToken;
    }
  }
  print('selectedToken = $selectedToken (Full)');
  return selectedToken;
}

void addTokens() {
  // List sample_tokens = ['x', 'y', 'z'];
// >> [x, y, z]  -> ['x', 'y', 'z'] (String Values)
  var copied_list = '[]'; // REPLACE THIS LIST!;
  copied_list = copied_list.replaceAll('[', '');
  copied_list = copied_list.replaceAll(']', '');
  var copied_list_str = copied_list.split(', ');
  print(copied_list_str.first.runtimeType);
  print(copied_list_str.length);
  // print(copied_list_str);

  var forIndex = 0;
  for (var _token in copied_list_str) {
    forIndex++;
    // print(_token);
    // print(forIndex);
    addCustom(_token, forIndex);
  }
  print('$forIndex tokens added');
}

Future<void> addCustom(token, index) {
  var token_id = 'Token $index ${UniqueKey()}';
  return thingi
      // existing document in 'users' collection: "ABC123"
      .doc(token_id)
      .set(
    {
      'Token': '$token',
      'users_usage': 1,
      'token_doc_id': token_id,
    },
    SetOptions(merge: true),
  ).then((value) {
    print('Token $index Added');
  }).catchError((error) => print("Failed to merge data: $error"));
}
