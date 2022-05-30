import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inspireui/inspireui.dart';
import 'package:provider/provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app_model.dart';
import '../../models/user_model.dart';
import '../../services/index.dart';
import '../../services/service_config.dart';
import '../../widgets/common/login_animation.dart';
import '../../widgets/common/webview.dart';
import '../base_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreenArgument {
  final bool fromCart;

  LoginScreenArgument({required this.fromCart});
}

class LoginScreen extends StatefulWidget {
  final bool fromCart;

  LoginScreen({this.fromCart = false});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends BaseScreen<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _loginButtonController;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  final usernameNode = FocusNode();
  final passwordNode = FocusNode();

  late var parentContext;
  bool isLoading = false;
  bool isAvailableApple = false;

  @override
  void initState() {
    super.initState();
    _loginButtonController = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    try {
      isAvailableApple = await TheAppleSignIn.isAvailable();
      setState(() {});
    } catch (e) {
      printLog('[Login] afterFirstLayout error');
    }
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    username.dispose();
    password.dispose();
    usernameNode.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loginButtonController.forward();
    } on TickerCanceled {
      printLog('[_playAnimation] error');
    }
  }

  Future<Null> _stopAnimation() async {
    try {
      await _loginButtonController.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {
      printLog('[_stopAnimation] error');
    }
  }

  Future _welcomeMessage(user, context) async {
    if (widget.fromCart) {
      Navigator.of(context).pop();
    } else {
      if (user.name != null) {
        Tools.showSnackBar(
            Scaffold.of(context), S.of(context).welcome + ' ${user.name} !');
      }
      final canPop = ModalRoute.of(context)!.canPop;
      if (canPop) {
        // When not required login
        Navigator.of(context).pop();
      } else {
        // When required login
        await Navigator.of(App.fluxStoreNavigatorKey.currentContext!)
            .pushReplacementNamed(RouteList.dashboard);
      }
    }
  }

  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      // content: Text(S.of(context).warning(message)), // Exception blah blah..
      content: Text(S.of(context).warning('משהו השתבש. אנא נסה שוב')),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    Scaffold.of(context)
      // ignore: deprecated_member_use
      ..removeCurrentSnackBar()
      // ignore: deprecated_member_use
      ..showSnackBar(snackBar);
  }

  void _loginFacebook(context) async {
    //showLoading();
    await _playAnimation();
    await Provider.of<UserModel>(context, listen: false).loginFB(
        success: (user) {
          //hideLoading();
          _stopAnimation();
          _welcomeMessage(user, context);
        },
        fail: (message) {
          //hideLoading();
          _stopAnimation();
          _failMessage(message, context);
        },
        context: context);
  }

  void _loginApple(context) async {
    await _playAnimation();
    await Provider.of<UserModel>(context, listen: false).loginApple(
        success: (user) {
          _stopAnimation();
          _welcomeMessage(user, context);
        },
        fail: (message) {
          _stopAnimation();
          _failMessage(message, context);
        },
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;
    final appModel = Provider.of<AppModel>(context);
    final screenSize = MediaQuery.of(context).size;
    final themeConfig = appModel.themeConfig;

    var forgetPasswordUrl = Config().forgetPassword;

    Future launchForgetPassworddWebView(String url) async {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              WebView(url: url, title: S.of(context).resetPassword),
          fullscreenDialog: true,
        ),
      );
    }

    void launchForgetPasswordURL(String? url) async {
      if (url != null && url != '') {
        /// show as webview
        await launchForgetPassworddWebView(url);
      } else {
        /// show as native
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
        );
      }
    }

    void _login(context) async {
      if (username.text.isEmpty || password.text.isEmpty) {
        Tools.showSnackBar(Scaffold.of(context), S.of(context).pleaseInput);
      } else {
        await _playAnimation();
        await Provider.of<UserModel>(context, listen: false).login(
          username: username.text.trim(),
          password: password.text.trim(),
          success: (user) {
            _stopAnimation();
            _welcomeMessage(user, context);
          },
          fail: (message) {
            _stopAnimation();
            _failMessage(message, context);
          },
        );
      }
    }

    void _loginSMS(context) {
      Navigator.of(context).pushNamed(
        RouteList.loginSMS,
        arguments: widget.fromCart,
      );
    }

    void _loginGoogle(context) async {
      await _playAnimation();
      await Provider.of<UserModel>(context, listen: false).loginGoogle(
          success: (user) {
            //hideLoading();
            _stopAnimation();
            _welcomeMessage(user, context);
          },
          fail: (message) {
            //hideLoading();
            _failMessage(message, context);
            _stopAnimation();
          },
          context: context);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Tools.hideKeyboard(context),
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Stack(
                children: [
                  ListenableProvider.value(
                    value: Provider.of<UserModel>(context),
                    child:
                        Consumer<UserModel>(builder: (context, model, child) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Container(
                          alignment: Alignment.center,
                          width: screenSize.width /
                              (2 / (screenSize.height / screenSize.width)),
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: AutofillGroup(
                            child: Column(
                              children: <Widget>[
                                const SizedBox(height: 40.0),
                                Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          height: 50,
                                          child: FluxImage(
                                            imageUrl: themeConfig.logo,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30.0),
/*                                    if (kLoginSetting['showAppleLogin'] &&
                                        isAvailableApple)
                                      Text(
                                        // 'Its rec to login as the web for full sync',
                                        // 'מומלץ להתחבר בהתאם לאתר לסנכרון מיטבי',
                                        'התחברות מהירה',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 24,
                                            // color: Colors.grey.shade400
                                            color: Colors.grey.shade700),
                                      ),*/
                                    const SizedBox(height: 50.0),
                                    Column(
                                      mainAxisAlignment:
                                          // MainAxisAlignment.spaceAround,
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        if (kLoginSetting['showFacebook'])
                                          InkWell(
                                            onTap: () =>
                                                _loginFacebook(context),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              width: 220,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                color: const Color(0xFF1873EB),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  const Icon(
                                                    FontAwesomeIcons.facebookF,
                                                    color: Colors.white,
                                                    size: 26,
                                                  ),
                                                  const Text(
                                                    'התחבר עם פייסבוק',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        letterSpacing: 0.5,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        // color: Colors.grey.shade400
                                                        // color: Colors.grey.shade700
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 5.0),
                                        if (kLoginSetting['showGoogleLogin'] && !isAvailableApple) // Android Only
                                          InkWell(
                                            onTap: () => _loginGoogle(context),
                                            // _failMessage('', context),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              width: 220,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                color: const Color(0xFFEA4336),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  const Icon(
                                                    FontAwesomeIcons.google,
                                                    color: Colors.white,
                                                    size: 22.0,
                                                  ),
                                                  const Text(
                                                    'התחבר עם גוגל',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        letterSpacing: 0.5,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        // color: Colors.grey.shade400
                                                        // color: Colors.grey.shade700
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 10.0),
                                        if (kLoginSetting['showAppleLogin'] &&
                                            isAvailableApple)
                                          InkWell(
                                            onTap: () => _loginApple(context),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              width: 220,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                color: Colors.black87,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  const Icon(
                                                    FontAwesomeIcons.apple,
                                                    color: Colors.white,
                                                    size: 26,
                                                  ),
                                                  const Text(
                                                    'התחברות עם אפל',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        letterSpacing: 0.5,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        // color: Colors.grey.shade400
                                                        // color: Colors.grey.shade700
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 5.0),
                                        if (kLoginSetting['showSMSLogin'])
                                          InkWell(
                                            onTap: () => _loginSMS(context),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                color: Colors.lightBlue,
                                              ),
                                              child: const Icon(
                                                FontAwesomeIcons.sms,
                                                color: Colors.white,
                                                size: 26,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: <Widget>[
                                        SizedBox(
                                            height: 50.0,
                                            width: 200.0,
                                            child: Divider(
                                                color: Colors.grey.shade300)),
                                        Container(
                                            height: 30,
                                            width: 40,
                                            color: Theme.of(context)
                                                .backgroundColor),
                                        if (kLoginSetting['showFacebook'] ||
                                            kLoginSetting['showSMSLogin'] ||
                                            kLoginSetting['showGoogleLogin'] ||
                                            kLoginSetting['showAppleLogin'])
                                          Text(
                                            S.of(context).or,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade400),
                                          )
                                      ],
                                    ),
                                  ],
                                ),
                                TextField(
                                  key: const Key('loginEmailField'),
                                  controller: username,
                                  autofillHints: [AutofillHints.email],
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  onSubmitted: (_) => FocusScope.of(context)
                                      .requestFocus(passwordNode),
                                  decoration: InputDecoration(
                                    labelText: S.of(parentContext).username,
                                    hintText: S
                                        .of(parentContext)
                                        .enterYourEmailOrUsername,
                                  ),
                                ),
                                const SizedBox(height: 12.0),
                                Stack(children: <Widget>[
                                  TextField(
                                    key: const Key('loginPasswordField'),
                                    autofillHints: [AutofillHints.password],
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    controller: password,
                                    focusNode: passwordNode,
                                    decoration: InputDecoration(
                                      labelText: S.of(parentContext).password,
                                      hintText:
                                          S.of(parentContext).enterYourPassword,
                                    ),
                                  ),
                                  Positioned(
                                    left: appModel.langCode == 'ar' ? null : 4,
                                    right: appModel.langCode == 'ar' ? 4 : null,
                                    bottom: 20,
                                    child: GestureDetector(
                                      onTap: () {
                                        launchForgetPasswordURL(
                                            forgetPasswordUrl);
                                      },
                                      child: Text(
                                        ' ' + S.of(context).reset,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  )
                                ]),
                                const SizedBox(
                                  height: 50.0,
                                ),
                                StaggerAnimation(
                                  key: const Key('loginSubmitButton'),
                                  titleButton: S.of(context).signInWithEmail,
                                  buttonController: _loginButtonController.view
                                      as AnimationController,
                                  onTap: () {
                                    if (!isLoading) {
                                      _login(context);
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 30.0,
                                ),
                                Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        // Text(S.of(context).dontHaveAccount),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context)
                                                .pushNamed(RouteList.register);
                                          },
                                          child: Text(
                                            // ' ${S.of(context).signup}',
                                            'הרשמה רגילה',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: Container(
          padding: const EdgeInsets.all(50.0),
          child: kLoadingWidget(context),
        ));
      },
    );
  }

  void hideLoading() {
    Navigator.of(context).pop();
  }
}
