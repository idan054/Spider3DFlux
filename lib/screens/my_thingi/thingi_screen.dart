/// Flutter code sample for DropdownButton

// This sample shows a `DropdownButton` with a large arrow icon,
// purple text style, and bold purple underline, whose value is one of "One",
// "Two", "Free", or "Four".
//
// ![](https://flutter.github.io/assets-for-api-docs/assets/material/dropdown_button.png)

import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fstore/common/config.dart';
import 'dart:convert';
// import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:fstore/common/constants.dart';
import 'package:fstore/screens/my_thingi/set_thingitoken.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This is the main application widget.
class ThingiPage extends StatefulWidget {
  const ThingiPage({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  State<ThingiPage> createState() => _ThingiPageState();
}

// var thingiToken = '76a96e8a8905232b8f9d1645eeada242';

var showLoading = false;

var defaultList = ['featured', 'popular', 'verified', 'newest'];
var randomHome = defaultList[Random().nextInt(defaultList.length)];

var categoriesList = [
  '3d-printing',
  'art',
  'fashion',
  'gadgets',
  'hobby',
  'household',
  'learning',
  'models',
  'tools',
  'toys-and-games',
];
var randomCategory = categoriesList[Random().nextInt(categoriesList.length)];

class Constants {
  static String? thingiToken;
  static String? thingiToken_counter;

  //https://api.thingiverse.com/popular/?access_token=$thingiToken
  static String defaultFeed =
      'https://api.thingiverse.com/$randomHome/?access_token=$thingiToken';
  // 'https://api.thingiverse.com/search/dog/?access_token=$thingiToken';
  // static String defaultFeed = 'https://api.thingiverse.com/$randomHome/?access_token=$thingiToken';

  static String feedByKeyword(String keyword) {
    return 'https://api.thingiverse.com/search/$keyword?access_token=$thingiToken'; //אפשר לשים כאן כל דבר, לייתר ביטחון...
  }

  // static String feedByCategory(String category) {
  static String feedByCategory() {
    return 'https://api.thingiverse.com/categories/$randomCategory/things?access_token=$thingiToken'; //אפשר לשים כאן כל דבר, לייתר ביטחון...
  }
}

Future<void> _check_thingiToken() async {
  print('thingi_screen.dart - _check_thingiToken()');
  print('thingiToken ${Constants.thingiToken_counter} | ${Constants.thingiToken}');
  await getThingiToken();
  // Constants.thingiToken == null || Constants.thingiToken == 'null'
  //     ? await set_thingiToken() : null;
  print('thingiToken ${Constants.thingiToken_counter} | ${Constants.thingiToken}');
}

Future<Map<String, dynamic>> _setFeedByPopular() async {
  print('_setFeedByPopular:');
  await _check_thingiToken();
  // showLoading = true;

  final response = await http.get(Uri.parse(Constants.defaultFeed));
  if (response.statusCode == 200) {
    // print(response.body);
    List<dynamic> postList = jsonDecode(response.body);
    Map<String, dynamic> postDictionary = {'hits': postList};

    // showLoading = false;
    return postDictionary;
  } else {
    // throw Exception('Failed to get news');
    return {'hits': 'my null'};
  }
}

Future<Map<String, dynamic>> _setFeedByKeyword(String keyword) async {
  showLoading = true;
  print('_setFeedByKeyword:');
  await _check_thingiToken();

  /// קטע זה מאפשר את יכולת החיפוש
  final response = await http.get(Uri.parse(Constants.feedByKeyword(keyword)));
  if (response.statusCode == 200) {
    // print(response.body);
    return jsonDecode(response.body);
  } else {
    // throw Exception('Failed to get news');
    return {'hits': 'my null'};
  }
}

Future<Map<String, dynamic>> _setFeedByCategory() async {
  showLoading = true;
  randomCategory = categoriesList[Random().nextInt(categoriesList.length)];

  print('_setFeedByCategory:');
  await _check_thingiToken();

  final response = await http.get(Uri.parse(Constants.feedByCategory()));
  if (response.statusCode == 200) {
    // print(response.body);
    List<dynamic> postList = jsonDecode(response.body);
    Map<String, dynamic> postDictionary = {'hits': postList};
    return postDictionary;
  } else {
    throw Exception('Failed to get feed by category');
  }
}

class _ThingiPageState extends State<ThingiPage> {
  var showSearch = false;
  var searchController = TextEditingController();
  var setFeedBy = _setFeedByPopular();

//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Theme.of(context).backgroundColor,
        toolbarHeight: 55.0, // double
        title: Row(
          children: [
            showSearch
                ? Flexible(
              flex: 14,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: Container(
                  color: kGrey200,
                  child: TextField(
                    textAlign: TextAlign.right,
                    // textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 15.0),
                      hintText: 'חפש מודלים בעברית..',
                      hintStyle: GoogleFonts.heebo(
                        // fontWeight: FontWeight.bold,
                          color:
                          Theme.of(context).colorScheme.onBackground,
                          fontSize: 16),
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                    ),

                    controller: searchController,
                    onSubmitted: (keyword) =>
                        searchThing(), // based controller.text
                  ),
                ),
              ),
            )
                : Container(
              alignment: Alignment.bottomRight,
              child: Text(
                  'רעיונות בשבילך'
                  // 'הדפס משהו..'
                  ,
                  // textDirection: TextDirection.rtl,
                  /*               style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 25)*/

                  style: GoogleFonts.heebo(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 25)),
            ),
            const Spacer(
              flex: 1,
            ),
            IconButton(
                color: Theme.of(context).accentColor.withOpacity(1),
                icon: const Icon(Icons.shuffle),
                onPressed: shuffleThings),
            GestureDetector(
              onTap: searchThing, // and show/hide text field
              child: Image.asset(
                'assets/icons/tabs/icon-search.png',
                // fit: BoxFit.fitHeight,
                // fit: BoxFit.fill,
                height: 25,
                fit: BoxFit.cover,
                color: Theme.of(context).accentColor.withOpacity(1),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            child: FutureBuilder(
              future: setFeedBy,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  // print(snapshot.data);
                  List<dynamic> thing_details = snapshot.data['hits'];
                  // print('thing_details');
                  // print(thing_details);
                  return GridView.builder(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: thing_details.length,
                      itemBuilder: (BuildContext context, int i) {
                        return CardGrid(
                            title: thing_details[i]['name'],
                            puclic_url: thing_details[i]['public_url'],
                            image_url: thing_details[i]['preview_image']);
                      });
                }
                return Center(
                  child: kLoadingWidget(context),
                );
              },
            ),
          ),
          showLoading ? Center(child: kLoadingWidget(context)) : Container()
        ],
      ),
    );
  }

  shuffleThings() async {
    setState(() {
      showLoading = true;
    });

    setFeedBy = _setFeedByCategory();

    await Future.delayed(const Duration(seconds: 2)).then((value) {
      setState(() {
        showLoading = false;
      });
    });
  }

  searchThing() async {
    setState(() {
      if (showSearch) {
        showSearch = false;
      } else {
        showSearch = true;
      }
      ;
    });

    if (searchController.text != '') {
      setState(() {
        showLoading = true;
      });

      final translator = GoogleTranslator();
      var t_search = await translator.translate(searchController.text,
          from: 'iw', to: 'en');
      print(searchController.text);
      print(t_search.text);

      setFeedBy = _setFeedByKeyword(t_search.text);
      searchController.clear();

      await Future.delayed(const Duration(seconds: 3)).then((value) {
        setState(() {
          showLoading = false;
        });
      });
    }
  }
}

class CardGrid extends StatelessWidget {
  final String title;
  final String puclic_url;
  final String image_url;

  CardGrid({this.title = '', this.puclic_url = '', this.image_url = ''});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          launch(puclic_url);
          print(puclic_url);
        },
        child: Container(
          width: double.infinity,
          height: 500,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor.withOpacity(0.8),
            boxShadow: <BoxShadow>[
              BoxShadow(
                offset: const Offset(-1.0, 1.5),
                blurRadius: 2.0,
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
              ),
            ],
            image: DecorationImage(
                image: NetworkImage(
                  image_url,
                ),
                fit: BoxFit.cover),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Container(
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.only(left: 5, bottom: 5, right: 5),
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  height: 1.25, // line spacing
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(-1.0, 1.5),
                      blurRadius: 4.0,
                      color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}