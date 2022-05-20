import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:fstore/screens/my_thingi/thingi_screen.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../services/base_firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// region my thingiToken Setup

// 1. set_thingiToken() - Try prefs.getString('user_token');
// 2. if can't, use getThingiToken() & than prefs.setString('user_token', '$pref_token');

Future<String?> set_thingiToken() async {
  print('set_thingiToken.dart - save_user_token()');

  // Map<String, Object> values = <String, Object>{'user_token': 'Mock_XYZ'};
  // Map<String, Object> values = <String, Object>{};
  // SharedPreferences.setMockInitialValues(values);
  var prefs = await SharedPreferences.getInstance();
  // prefs.clear();
  // await storage.clear();

  String? pref_token = prefs.getString('pref_token');
  String? thingiToken_counter = prefs.getString('thingiToken_counter');
  if (pref_token == null || pref_token == 'null') {
    // Set new pref_token (if null)
    print('A X pref_token is null: ($pref_token)');
    print('Start set pref_token & thingiToken_counter..');
    var getThingiToken_list = await getThingiToken();
    pref_token = '${getThingiToken_list[0]}';
    thingiToken_counter = '${getThingiToken_list[1]}';
    print('B X pref_token after getThingiToken(): ($pref_token)');
    print('B X thingiToken_counter after getThingiToken(): ($thingiToken_counter)');
    await prefs.setString('pref_token', '$pref_token');
    await prefs.setString('thingiToken_counter', '$thingiToken_counter');
    // await prefs.setString('user_token', 'null');
    // Constants.thingiToken = pref_token;
    // Constants.thingiToken_counter = thingiToken_counter;
  } else {
    // Get pref_token

    // await prefs.setString('user_token', 'null');
    print('pref_token & thingiToken_counter Found on prefs!'
        '$thingiToken_counter - $pref_token');
    Constants.thingiToken = pref_token;
    Constants.thingiToken_counter = thingiToken_counter;
  }


  // return pref_token;
}

Future<List> getThingiToken() async {
  print('set_thingiToken.dart - getThingiToken()');
  String? selectedToken;
  String? id;
  String token;
  var user;
  var users_usage = 0;

// 1. Looking for token with users (usage) Less than 10
// 2. Found: Notify and add + 1 to users (usage), return  selectedToken
// 2. Not found: Notify, return  selectedToken as null

  // CollectionReference thingi_collection = FirebaseFirestore.instance.collection('thingi_collection');
  var thingi_collection = FirebaseFirestore.instance.collection('thingi');
  var tokens_in_use = await FirebaseFirestore.instance
      .collection('thingi')
      .where('users_usage', whereIn: [2, 3, 4, 5, 6, 7, 8, 9])
      .limit(1)
      .get();
  if (tokens_in_use.docs.isNotEmpty) {
    print('use tokens_in_use to set var user');
    user = tokens_in_use.docs.first; // theres only 1
  } else {
    var new_token = await FirebaseFirestore.instance
        .collection('thingi')
        .where('users_usage', whereIn: [0, 1])
        .limit(1)
        .get();
    print('use new_token to set var user');
    user = new_token.docs.first; // theres only 1
  }
  ;
  // var _users = await thingi_collection.get();
  // print('_users.docs.length');
  // print(_users.docs.length);
  print(user.data());
  // print(user.data());
  id = user.id;
  token = user.get('Token');
  users_usage = user.get('users_usage');
  print(
      '--------------\nusers_usage: $users_usage | Token: $token | doc id: $id');
  if (users_usage < 10) {
    selectedToken = token;
    await thingi_collection
        .doc(id)
        .update({'users_usage': users_usage + 1})
        .then((value) => print('users_usage ++'))
        .catchError((error) => print('Failed to update user: $error'));

    print(
        '${users_usage + 1} / 10 selectedToken: $selectedToken (Success) \n--------------');

    Constants.thingiToken = selectedToken;
    Constants.thingiToken_counter = '$users_usage';
    return [selectedToken, users_usage];
  }

  print('selectedToken = $selectedToken (Full)');
  Constants.thingiToken = selectedToken;
  Constants.thingiToken_counter = '$users_usage';
  return [selectedToken, users_usage];
}

//~ Run this to reset the thingi tokens
// rename to getThingiToken()
Future<String?> getThingiTokenReset() async {
// 1. Looking for token with users (usage) Less than 10
// 2. Found: Notify and add + 1 to users (usage), return  selectedToken
// 2. Not found: Notify, return  selectedToken as null

  var thingi = FirebaseFirestore.instance.collection('thingi');
  String? selectedToken;

  String? id;
  String token;
  int users_usage = 0;
  var _users = await thingi.get();
  print('_users.docs.length');
  print(_users.docs.length);
  print(_users.docs.first.data());
  for (var user in _users.docs) {
    // print(user.data());
    id = user.id;
    token = user.get('Token');
    users_usage = user.get('users_usage');
    print(
        '--------------\nusers_usage: $users_usage | Token: $token | doc id: $id');
    if (users_usage == 0) {
      selectedToken = token;
      await thingi
          .doc(id)
          .update({'users_usage': 1})
          .then((value) => print('users_usage ++'))
          .catchError((error) => print('Failed to update user: $error'));

      print(
          'firestore users_usage reset to 0 \n--------------');
      // return selectedToken;
    }
/*    if (users_usage < 10) {
      selectedToken = token;
      await thingi
          .doc(id)
          .update({'users_usage': users_usage + 1})
          .then((value) => print('users_usage ++'))
          .catchError((error) => print('Failed to update user: $error'));

      print(
          '${users_usage + 1} / 10 selectedToken: $selectedToken (Success) \n--------------');
      return selectedToken;
    }*/
  }
  print('selectedToken = $selectedToken (Full)');
  return selectedToken;
}

// Constants.thingiToken = await set_thingiToken();
// print('Constants.thingiToken ${Constants.thingiToken}');

// endregion my thingiToken Setup
