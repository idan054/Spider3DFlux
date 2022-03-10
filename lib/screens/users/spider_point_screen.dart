import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fstore/models/entities/user.dart';
import 'package:fstore/models/user_model.dart';
import 'package:fstore/services/dependency_injection.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/config.dart';

class SpidersPointScreen extends StatefulWidget {
  bool isFullPage;

  SpidersPointScreen({this.isFullPage = true});

  @override
  _StateUserPoint createState() => _StateUserPoint();
}

Future<String> my_Woorewards(
    {required String user_email, String? points}) async {
  try {
    // null safety
    // points = points ?? ''; // if null -> ''
    if (points == '' || points == null) points = '0';

    var url =
        'https://spider3d.co.il/wp-json/woorewards/v1/points/$user_email/_/$points?consumer_key=ck_be61455d30704ff30718f80b417dd41c320b0cb0&consumer_secret=cs_79c75a8e1c40acfe530e6254f3cbb61a2e01f872';
    print(url);

    var dio = Dio();
    // if points = '' -> get req | ELSE -> put req
    // final response = points == '' ? await dio.get(url) : await dio.put(url);
    final resp = await dio.put(url);

    // print(response.data);
    // print(response.data[0]['value']);
    return resp.data[0]['value'].toString();
    // return resp.data[0]['value'];
  } catch (e) {
    //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
    rethrow;
  }
}

class _StateUserPoint extends State<SpidersPointScreen> {
  final dateWidth = 100;
  final pointWidth = 50;
  final borderWidth = 0.5;
  var userEmail;

  User? get user => Provider.of<UserModel>(context, listen: false).user;
  // final user = Provider.of<UserModel>(context, listen: false).user;
  // final user_email = Provider.of<UserModel>(context).user!.email.toString();

  @override
  void initState() {
    // print('init user:');
    // print(user!.email.toString());

    // if (userEmail == 'Auto') {
    userEmail = user!.email.toString();
    // }
    super.initState();
  }

  Widget shareButton({icon, label}) {
    var prefs = injector<SharedPreferences>();
    print('isFirstShare Before click: ${prefs.getBool('isFirstShare')}');

    return TextButton.icon(
      style: ButtonStyle(
          overlayColor:
              MaterialStateProperty.all(Colors.grey[700]!.withOpacity(0.30)),
          foregroundColor: MaterialStateProperty.all(Colors.grey[700]),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          // backgroundColor: MaterialStateProperty.all(Colors.grey[100]),
          elevation: MaterialStateProperty.all(2)),
      onPressed: () {
        bool checkFirstShare() {
          var _isFirstShare = prefs.getBool('isFirstShare') ?? true;
          return _isFirstShare;
        }

        const snackBar = SnackBar(
            duration: Duration(seconds: 6), // default is 4
            content: Text('תודה ששיתפת אותנו! ניתן להרוויח רק פעם אחת'));

        var isFirstShare = checkFirstShare();
        isFirstShare
            ? {
                my_Woorewards(user_email: userEmail, points: '50'),
                Share.share(
                    'היי, ספיידר 3D נותנים מבצעים ומשלוח חינם מתנה ללקוחות האפליקציה! שווה ממש להצטרף \n https://rebrand.ly/Spider3D-App'),
                print(
                    'היי, ספיידר 3D נותנים מבצעים ומשלוח חינם מתנה ללקוחות האפליקציה! שווה ממש להצטרף \n https://rebrand.ly/Spider3D-App'),
                print('You got 50 spiders'),
                isFirstShare = false,
                prefs.setBool('isFirstShare', false),
                print('isFirstShare Before After: $isFirstShare'),
              }
            : {
                Share.share(
                    'היי, ספיידר 3D נותנים מבצעים ומשלוח חינם מתנה ללקוחות האפליקציה! שווה ממש להצטרף \n https://rebrand.ly/Spider3D-App'),
                print(
                    'היי, ספיידר 3D נותנים מבצעים ומשלוח חינם מתנה ללקוחות האפליקציה! שווה ממש להצטרף \n https://rebrand.ly/Spider3D-App'),
                print('isFirstShare Before After: $isFirstShare'),
                ScaffoldMessenger.of(context).showSnackBar(snackBar),
              };

        print(isFirstShare);
      },
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          // fontSize: 20.0,
          // color: kGrey900,
        ),
      ),
    );
  }

  Widget spiderPoints() {
    return FutureBuilder<String>(
      future: my_Woorewards(user_email: userEmail),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Align(
            alignment: Alignment.center,
            child: kLoadingWidget(context),
          );
        }
        if (!snapshot.hasData) return Container();
        var spiderPoints = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  trailing: Text(
                    // 'snapshot.data!.points.toString()',
                    // '54321',
                    spiderPoints,
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                          fontSize: 30,
                        ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'הספיידרס שלך:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Transform.translate(
                          offset: const Offset(-10, -2),
                          child: Image.asset('assets/images/spider_coin.png',
                              color: Theme.of(context).primaryColor,
                              height: 29,
                              width: 29)

                          // Icon(
                          //   CupertinoIcons.money_dollar_circle,
                          //   size: 30,
                          //   color: Theme.of(context).primaryColor,
                          // ),
                          ),
                    ],
                  ),
                  // subtitle: Text(
                  //   'יש לך 30 ספיידרס ששווים 3₪ \nהקאשבק שלך יופעל אוטומטית ברכישה הבאה.',
                  //   style: TextStyle(
                  //
                  //       fontWeight: FontWeight.w600,
                  // color:
                  //     Theme.of(context).accentColor.withOpacity(0.75),
                  // ),
                  // ),
                ),
                const Divider(indent: 15.0, endIndent: 15.0),
                ListTile(
                  title: Text(
                    'יש לך $spiderPoints ספיידרס ששווים ${double.parse(spiderPoints) / 10}₪ \nהקאשבק שלך יופעל אוטומטית ברכישה הבאה.',
                    style: TextStyle(
                      fontSize: 15,
                      //    fontWeight: FontWeight.w600,
                      color: Theme.of(context).accentColor.withOpacity(0.75),
                    ),
                  ),
                ),
                const Divider(indent: 15.0, endIndent: 15.0),
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'איך משיגים ספיידרס?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      // for (var event in snapshot.data!.events)
                      ListTile(
                        trailing: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            '50+',
                            style:
                                Theme.of(context).textTheme.subtitle1!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                          ),
                        ),
                        title: const Text('שיתוף האפליקציה במדיה חברתית',
                            style: TextStyle(fontSize: 16)),
                        subtitle: Text(
                          'תקבל 50 ספיידר על השיתוף',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                      ListTile(
                        trailing: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            '50+',
                            style:
                                Theme.of(context).textTheme.subtitle1!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                          ),
                        ),
                        title: Row(
                          children: [
                            const Text('הזמנת חבר לאפליקציה',
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Container(
                                color: Colors.amber,
                                padding: const EdgeInsets.all(3.0),
                                child: const Text(' מומלץ! ',
                                    style: TextStyle(fontSize: 15)),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'תקבל 50 ספיידר על ההזמנה',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          shareButton(
                              icon: Icons.person_add, label: 'הזמן חבר'),
                          const SizedBox(
                            width: 20,
                          ),
                          shareButton(icon: Icons.share, label: 'שתף אותנו'),
                        ],
                      ),

                      ListTile(
                        trailing: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            '10+',
                            style:
                                Theme.of(context).textTheme.subtitle1!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                          ),
                        ),
                        title: const Text('דירוג מוצרים באתר',
                            style: TextStyle(fontSize: 16)),
                        subtitle: Text(
                          'תקבל 10 ספיידר על כל דירוג',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                      ListTile(
                        trailing: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            '1+',
                            style:
                                Theme.of(context).textTheme.subtitle1!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                          ),
                        ),
                        title: const Text('הזמנת פילמנטים וחומרי הדפסה',
                            style: TextStyle(fontSize: 16)),
                        subtitle: Text(
                          'תקבל 1 ספיידר על כל ₪1',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isFullPage
        ? Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              brightness: Theme.of(context).brightness,
              backgroundColor: Theme.of(context).primaryColorLight,
              title: Text(
                'קאשבק & ספיידרס',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            body: spiderPoints())
        : spiderPoints();
  }
}
