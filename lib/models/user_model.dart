import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;

import '../app.dart';
import '../common/config.dart';
import '../common/constants.dart';
import '../generated/l10n.dart';
import '../routes/flux_navigate.dart';
import '../services/index.dart';
import 'cart/cart_model.dart';
import 'entities/user.dart';

abstract class UserModelDelegate {
  void onLoaded(User? user);

  void onLoggedIn(User user);

  void onLogout(User? user);
}

class UserModel with ChangeNotifier {

  UserModel() {
    getUser();
  }

  final Services _service = Services();
  User? user;
  bool loggedIn = false;
  bool loading = false;
  UserModelDelegate? delegate;

  void updateUser(User newUser) {
    user = newUser;
    notifyListeners();
  }

  Future<String?> submitForgotPassword(
      {String? forgotPwLink, Map<String, dynamic>? data}) async {
    return await _service.api
        .submitForgotPassword(forgotPwLink: forgotPwLink, data: data);
  }

  /// Login by apple, This function only test on iPhone
  Future<void> loginApple({Function? success, Function? fail, context}) async {
    try {
      final result = await apple.TheAppleSignIn.performRequests([
        const apple.AppleIdRequest(
            requestedScopes: [apple.Scope.email, apple.Scope.fullName])
      ]);

      switch (result.status) {
        case apple.AuthorizationStatus.authorized:
          {
            user = await _service.api.loginApple(
                token: String.fromCharCodes(result.credential!.identityToken!));

            Services().firebase.loginFirebaseSMS(
                  authorizationCode: result.credential!.authorizationCode!,
                  identityToken: result.credential!.identityToken!,
                );

            loggedIn = true;
            await saveUser(user);
            success!(user);

            notifyListeners();
          }
          break;

        case apple.AuthorizationStatus.error:
          fail!(S.of(context).error(result.error!));
          break;
        case apple.AuthorizationStatus.cancelled:
          fail!(S.of(context).loginCanceled);
          break;
      }
    } catch (err) {
      fail!(S.of(context).loginErrorServiceProvider(err.toString()));
    }
  }

  /// Login by Firebase phone
  Future<void> loginFirebaseSMS(
      {String? phoneNumber,
      required Function success,
      Function? fail,
      context}) async {
    try {
      user = await _service.api.loginSMS(token: phoneNumber);
      loggedIn = true;
      await saveUser(user);
      success(user);

      notifyListeners();
    } catch (err) {
      fail!(S.of(context).loginErrorServiceProvider(err.toString()));
    }
  }

  /// Login by Facebook
  var firstTry = true;
  Future<void> loginFB({Function? success, Function? fail, context}) async {
    print('firstTry? $firstTry');
    try {
      final result = firstTry // my
          ? await FacebookAuth.instance
              .login(loginBehavior: LoginBehavior.nativeWithFallback)
          : await FacebookAuth.instance
              .login(loginBehavior: LoginBehavior.webViewOnly);
      switch (result.status) {
        case LoginStatus.success:
          final accessToken = await FacebookAuth.instance.accessToken;

          Services().firebase.loginFirebaseFacebook(token: accessToken!.token);

          user = await _service.api.loginFacebook(token: accessToken.token);
          loggedIn = true;
          await saveUser(user);
          success!(user);
          break;
        case LoginStatus.cancelled:
          firstTry = false;
          fail!(S.of(context).loginCanceled);
          break;
        default:
          firstTry = false;
          fail!(S.of(context).loginCanceled);
          break;
      }
      notifyListeners();
    } catch (err) {
      fail!(S.of(context).loginErrorServiceProvider(err.toString()));
    }
  }

  Future<void> loginGoogle({Function? success, Function? fail, context}) async {
    try {
      var _googleSignIn = GoogleSignIn(scopes: ['email']);
      var res = await _googleSignIn.signIn();

      if (res == null) {
        fail!(S.of(context).loginCanceled);
      } else {
        var auth = await res.authentication;
        Services().firebase.loginFirebaseGoogle(token: auth.accessToken);
        user = await _service.api.loginGoogle(token: auth.accessToken);
        loggedIn = true;
        await saveUser(user);
        success!(user);
        notifyListeners();
      }
    } catch (err, trace) {
      printLog(trace);
      printLog(err);
      fail!(S.of(context).loginErrorServiceProvider(err.toString()));
    }
  }

  Future<void> saveUser(User? newUser) async {
    final storage = LocalStorage('fstore');
    user = newUser;
    try {
      if (Services().firebase.isEnabled &&
          kFluxStoreMV.contains(serverConfig['type'])) {
        Services().firebase.saveUserToFirestore(user: newUser);
      }

      // save to Preference
      var prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true);

      // save the user Info as local storage
      final ready = await storage.ready;
      if (ready) {
        print("Saved new user info to local storage ${newUser?.lastName ?? ""}");
        await storage.setItem(kLocalKey['userInfo']!, newUser);
        delegate?.onLoaded(newUser);
      }
    } catch (err) {
      printLog(err);
    }
  }

  int getUserRetries = 0;

  Future<void> getUser() async {
    print("getting user attempt ${getUserRetries}");
    final storage = LocalStorage('fstore');
    try {
      final ready = await storage.ready;
      if(!ready && getUserRetries < 10){
        await Future.delayed(const Duration(milliseconds: 500));
        getUserRetries += 1;
        getUser();
      }
      if(!ready && getUserRetries >= 10){
        print("cant get user after 10 retries");
      }
      if (ready) {
        final json = storage.getItem(kLocalKey['userInfo']!);
        print("The json we get from local ${json}");
        if (json != null) {
          print("The json we got from local ${json}");
          user = User.fromLocalJson(json);
          print("received user from local ${user?.lastName ?? ""}");
          loggedIn = true;
          if(user == null){
            final userInfo = await _service.api.getUserInfo(user!.cookie);
            print("received user from server ${user?.lastName ?? ""}");
            if (userInfo != null) {
              userInfo.isSocial = user!.isSocial;
              user = userInfo;
            }
          }
          if(user != null){
            updateUser(user!);
          }
          delegate?.onLoaded(user);
          notifyListeners();
        }
      }
    } catch (err) {
      print("We got error while getting user");
      printLog(err);
    }
  }

  void setLoading(bool isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> createUser({
    String? username,
    String? password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isVendor,
    required Function success,
    Function? fail,
  }) async {
    try {
      loading = true;
      notifyListeners();
      Services().firebase.createUserWithEmailAndPassword(
          email: username!, password: password!);

      user = await _service.api.createUser(
        firstName: firstName,
        lastName: lastName,
        username: username,
        password: password,
        phoneNumber: phoneNumber,
        isVendor: isVendor ?? false,
      );
      loggedIn = true;
      await saveUser(user);
      success(user);

      loading = false;
      notifyListeners();
    } catch (err) {
      fail!(err.toString());
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    Services().firebase.signOut();

    await FacebookAuth.instance.logOut();

    delegate?.onLogout(user);
    user = null;
    loggedIn = false;
    final storage = LocalStorage('fstore');
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.deleteItem(kLocalKey['userInfo']!);
        await storage.deleteItem(kLocalKey['shippingAddress']!);
        await storage.deleteItem(kLocalKey['recentSearches']!);
        await storage.deleteItem(kLocalKey['opencart_cookie']!);
        await storage.setItem(kLocalKey['userInfo']!, null);

        var prefs = await SharedPreferences.getInstance();
        await prefs.setBool('loggedIn', false);
      }
      await _service.api.logout();
    } catch (err) {
      printLog(err);
    }
    notifyListeners();
  }

  Future<void> login(
      {username, password, required Function success, Function? fail}) async {
    try {
      loading = true;
      notifyListeners();
      user = await _service.api.login(
        username: username,
        password: password,
      );

      Services()
          .firebase
          .loginFirebaseEmail(email: username, password: password);

      loggedIn = true;
      await saveUser(user);
      success(user);
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      fail!(err.toString());
      notifyListeners();
    }
  }

  Future<bool> isLogin() async {
    final storage = LocalStorage('fstore');
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = storage.getItem(kLocalKey['userInfo']!);
        return json != null;
      }
      return false;
    } catch (err) {
      return false;
    }
  }

  onTapLogout(context) async {
    await Provider.of<UserModel>(context,
        listen: false).logout();
    if (kLoginSetting['IsRequiredLogin'] ??
        false) {
      await Navigator.of(App
          .fluxStoreNavigatorKey
          .currentContext!)
          .pushNamedAndRemoveUntil(
        RouteList.login,
            (route) => false,
      );
    }

    // My show / clear all SharedPreferences data
    var prefs =
        await SharedPreferences.getInstance();

    print(
        'loadInitData - prefs.getKeys ${prefs.getKeys()}');
    await prefs.remove('loggedIn');
    await prefs.clear(); // remove all ces.getInstance() data
    await prefs.setBool('seen', true);

    final fstore_storage =
    LocalStorage('fstore');
    final address_storage =
    LocalStorage('address');
    final data_order_storage =
    LocalStorage('data_order');

    await fstore_storage.clear();
    await address_storage.clear();
    await data_order_storage.clear();

    Provider.of<CartModel>(context).dispose();
    // Provider.of<AppModel>(context).dispose();

  }
}
