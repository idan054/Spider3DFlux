import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../services/base_firebase_services.dart';
import 'dynamic_link_service.dart';
import 'firebase_analytics_service.dart';
import 'firebase_remote_service.dart';
import 'realtime_chat/chat_screen.dart';
import 'realtime_chat/list_chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fstore/models/user_model.dart' as appUser;

class FirebaseServices extends BaseFirebaseServices {
  static final FirebaseServices _instance = FirebaseServices._internal();

  factory FirebaseServices() => _instance;

  FirebaseServices._internal();

  bool _isEnabled = false;

  @override
  bool get isEnabled => _isEnabled;

  @override
  Future<void> init() async {
    var startTime = DateTime.now();
    await Firebase.initializeApp();
    _isEnabled = kAdvanceConfig['EnableFirebase'] ?? false;

    /// Not require Play Services
    /// https://firebase.google.com/docs/android/android-play-services
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    var _user_uid = _auth?.currentUser?.uid; // my
    print('MY _user_uid $_user_uid');

    if (!kIsWeb) {
      _remoteConfig = RemoteConfig.instance;
    }

    /// Require Play Services
    const message = '[FirebaseServices] Init successfully';
    if (GmsTools().isGmsAvailable) {
      _messaging = FirebaseMessaging.instance;
      _dynamicLinks = FirebaseDynamicLinks.instance;
      printLog(message, startTime);
    } else {
      printLog('$message (without Google Play Services)', startTime);
    }
  }

  @override
  FirebaseAnalyticsService getAnalytic() {
    return FirebaseAnalyticsService();
  }

  /// Firebase Auth
  FirebaseAuth? _auth;

  FirebaseAuth? get auth => _auth;

  /// Firebase Cloud Firestore
  FirebaseFirestore? _firestore;

  FirebaseFirestore? get firestore => _firestore;

  /// Firebase Dynamic Links
  FirebaseDynamicLinks? _dynamicLinks;

  FirebaseDynamicLinks? get dynamicLinks => _dynamicLinks;

  /// Firebase Remote Config
  RemoteConfig? _remoteConfig;

  RemoteConfig? get remoteConfig => _remoteConfig;

  FirebaseMessaging? _messaging;

  FirebaseMessaging? get messaging => _messaging;

  @override
  void loginFirebaseSMS({authorizationCode, identityToken}) async {
    if (FirebaseServices().isEnabled) {
      final AuthCredential credential = OAuthProvider('apple.com').credential(
        accessToken: String.fromCharCodes(authorizationCode),
        idToken: String.fromCharCodes(identityToken),
      );
      await FirebaseServices().auth!.signInWithCredential(credential);
    }
  }

  @override
  void loginFirebaseFacebook({token}) async {
    if (FirebaseServices().isEnabled) {
      AuthCredential credential = FacebookAuthProvider.credential(token);
      await FirebaseServices().auth!.signInWithCredential(credential);
    }
  }

  @override
  void loginFirebaseGoogle({token}) async {
    if (FirebaseServices().isEnabled) {
      AuthCredential credential =
          GoogleAuthProvider.credential(accessToken: token);
      await FirebaseServices().auth!.signInWithCredential(credential);
    }
  }

  @override
  void loginFirebaseEmail({email, password}) async {
    if (FirebaseServices().isEnabled) {
      try {
        await FirebaseServices().auth?.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
      } catch (err) {
        /// In case this user was registered on web
        /// so Firebase user was not created.
        if (err is FirebaseAuthException && err.code == 'user-not-found') {
          /// Create Firebase user automatically.
          /// createUserWithEmailAndPassword will auto sign in after success.
          /// No need to call signInWithEmailAndPassword again.
          await FirebaseServices().auth?.createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
        }

        /// Ignore other cases.
      }
    }
  }

  @override
  Future<User?>? loginFirebaseCredential({credential}) async {
    return (await FirebaseServices().auth!.signInWithCredential(credential))
        .user;
  }

  @override
  void saveUserToFirestore({user}) async {
    final token = await FirebaseServices().messaging!.getToken();
    printLog('token: $token');
    await FirebaseServices()
        .firestore!
        .collection('users')
        .doc(user!.email)
        .set(
      {'deviceToken': token, 'isOnline': true},
      SetOptions(merge: true),
    );
  }

  @override
  PhoneAuthCredential getFirebaseCredential({verificationId, smsCode}) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  @override
  StreamController<PhoneAuthCredential> getFirebaseStream() {
    return StreamController<PhoneAuthCredential>.broadcast();
  }

  @override
  void verifyPhoneNumber(
      {phoneNumber,
      codeAutoRetrievalTimeout,
      codeSent,
      verificationCompleted,
      verificationFailed}) async {
    await FirebaseServices().auth!.verifyPhoneNumber(
          phoneNumber: phoneNumber!,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
          codeSent: codeSent,
          timeout: const Duration(seconds: 120),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
        );
  }

  @override
  Widget renderListChatScreen() {
    return ListChatScreen();
  }

  // @override
  // Widget renderVendorListChatScreen() {
  //   return VendorListChatScreen();
  // }

  @override
  Widget renderChatScreen({senderUser, receiverEmail, receiverName}) {
    return ChatScreen(
      senderUser: senderUser,
      receiverEmail: receiverEmail,
      receiverName: receiverName,
    );
  }

  @override
  void createUserWithEmailAndPassword({email, password}) {
    if (isEnabled) {
      FirebaseServices().auth?.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
    }
  }

  @override
  User? getCurrentUser() {
    try {
      return FirebaseServices().auth?.currentUser;
    } catch (e) {
      printLog('[Tabbar] getCurrentUser error ${e.toString()}');
    }
  }

  @override
  Future<String?> getMessagingToken() async {
    return await messaging!.getToken();
  }

  void initDynamicLinkService(context) {
    DynamicLinkService.initDynamicLinks(context);
  }

  @override
  void loadRemoteConfig({onUpdate}) async {
    await FirebaseRemoteServices.loadRemoteConfig(
      onUpdate: onUpdate,
    );
  }

  @override
  void shareDynamicLinkProduct({context, productUrl, productId}) {
    DynamicLinkService().shareProductLink(
      productUrl: productUrl,
      productId: productId,
    );
  }

  @override
  void signOut() async {
    if (isEnabled) {
      await FirebaseServices().auth?.signOut();
    }
  }

  Future<bool> reloadUser() async {
    print("reloading user");
    try{
      await FirebaseServices().auth?.currentUser?.getIdToken(true);
    } catch(e){
      print("logging out the user");
      await appUser.UserModel().logout();
      return false;
    } finally{
      print("user intact");
    }
    return true;
  }
}
