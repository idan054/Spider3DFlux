import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  save_user_token() async {
    // Map<String, Object> values = <String, Object>{'user_token': 'Mock_XYZ'};
    Map<String, Object> values = <String, Object>{};
    SharedPreferences.setMockInitialValues(values);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? user_token = prefs.getString('user_token');
    user_token == null
        ? {
            selectedToken = await getThingiToken(),
            print('Set user_token to selectedToken ($selectedToken)'),
            await prefs.setString('user_token', '$selectedToken')
          }
        : print('user_token is $selectedToken');
  }

  await save_user_token();
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

