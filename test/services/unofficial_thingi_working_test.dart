
import 'package:html/parser.dart';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  print('start');
  // List<StlFinderPost> posts = await getPosts();
  List<StlFinderPost>? posts = await getPosts();
  if (posts?.length == 0 || posts?.length == null)
    posts = await getPosts(); // Try again..
  print('start 2');
  print(posts);
  posts?.map((e) => print(e.post_name));
  print('Done');
}

Future<List<StlFinderPost>?> getPosts() async {
  // Start the browser and go to a web page
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  // var posts_list = [];
  List<StlFinderPost>? posts_list;

  // Setup the dimensions and user-agent of a particular phone
  await page.emulate(puppeteer.devices.pixel2XL);

  await page.goto(
    'http://www.thingiverse.com/search?q=dog&type=things&sort=relevant',
    // 'http://www.flutter.dev',
    // wait: Until.networkIdle
  );
  var pageContent = await page.content;
  // print('pageContent');
  // print(pageContent.runtimeType);
  // print(pageContent);

  var parse_resp = parse(pageContent);
  // print(parse_resp.body);
  // print(parse_resp.body?.text);

  for (var item1 in parse_resp.getElementsByTagName('div')) {
    for (var item2 in item1.children) {
      for (var item3 in item2.children) {
        var href_url;
        var src_jpg;
        var title_name;

        if (item1.outerHtml.contains('thing:') &&
            !item1.outerHtml.contains('thing:0/edit')) {
          if (item3.attributes['href'] != null &&
              item3.outerHtml.contains('thing:')) {
            // print('href');
            // print(item3.attributes['href']);
            href_url = item3.attributes['href'];
          }
          if (item3.attributes['src'] != null) {
            // print('src');
            // print(item3.attributes['src']);
            src_jpg = item3.attributes['src'];
          }
          if (item3.attributes['title'] != null) {
            // print('title');
            // print(item3.attributes['title']);
            title_name = item3.attributes['title'];

            posts_list?.add(StlFinderPost(
                post_url: href_url,
                post_image: src_jpg,
                post_name: title_name));
          }
        }
      }
    }
  }
  print('posts_list length is ${posts_list?.length}');

  // var screenshot = await page.screenshot();
  // await File('_github.png',).writeAsBytes(screenshot);

  await browser.close();
  return posts_list;
}

class StlFinderPost {
  String? post_image;
  // String? post_id;
  String? post_name;
  String? post_url;

  StlFinderPost(
      {
      // this.post_id,
      this.post_image,
      this.post_name,
      this.post_url});
}

/// My woorewards API (Source: https://plugins.longwatchstudio.com/docs/woorewards-4/api/users-points/)

// Sample: https://spider3d.co.il/wp-json/woorewards/v1/pools?consumer_key=ck_be61455d30704ff30718f80b417dd41c320b0cb0&consumer_secret=cs_79c75a8e1c40acfe530e6254f3cbb61a2e01f872
// Show user points: [GET] /wp-json/woorewards/v1/points/<user_email>/<pool_id>
// Add/ Subtract points: [PUT] /wp-json/woorewards/v1/points/<user_email>/<pool_id>/<points_to_add_or_subtract>

/*void main() async {
  printLog('Start');
  // var dio = Dio();
  // final response = await dio.get(
  //     'https://www.thingiverse.com/search?q=dog&type=things&sort=relevant');
  // var parse_resp = parse(response.data);
  //
  // // var header = parser?.getElementsByClassName('title')[0].text;
  // // var subscribeCount = parser?.querySelector('.subscribers-count-note').text;
  // // var img = response?.querySelector('.jsx-1373700303 img').src;
  //
  // printLog(parse_resp.documentElement?.outerHtml);
  // printLog(parse_resp.querySelectorAll('a').length);
  // printLog(parse_resp.querySelectorAll('href').length);
  // printLog(parse_resp.querySelectorAll('div').length);

  http.Response response = await http.get(Uri.parse(
      'https://www.thingiverse.com/search?q=dog&type=things&sort=relevant'));

  Document document = parser.parse(response.body);

  document.querySelectorAll('a').forEach((Element element) {
    print(element.text);
  });

  printLog('Done');
}*/

/*Future myApi_req() async {
  var dio = Dio();
  final response =
      await dio.get('https://www.stlfinder.com/3dmodels/?search=dog&free=1');
  var parse_resp = parse(response.data);
  print(response.statusCode);
  // print(parse_resp.body);
  // print(parse_resp.body?.text);
  for (var s in parse_resp.getElementsByTagName('source')) {
    // >>> Get photo
    var current_url = s.outerHtml.toString();
    if (current_url.contains('.jpg')) {
      current_url = current_url.replaceAll('<source srcset="', '');
      current_url = current_url.replaceAll('" type="image/jpeg">', '');
      print(current_url);

      // >>> Get ID
      var current_id = current_url;
      current_id = current_id.replaceAll(
          'https://storage.googleapis.com/stlfinder/', '');
      current_id = current_id.replaceAll('_200.jpg', '');
      for (var l in current_id.split('')) {
        current_id = current_id.replaceFirst(l, '');
        // print(current_id);
        if (l == '/') break;
      }
      print(current_id);

      // >>> Get Url
    }
    // print(s.outerHtml);
  }
}*/

/*
Future myApi_req() async {
  var dio = Dio();
  final response = await dio.get(
      'https://www.thingiverse.com/search?q=dog&type=things&sort=relevant');
  // 'https://www.stlfinder.com/3dmodels/?search=dog&free=1');
  var parse_resp = response.data;
  print(response.statusCode);
  // print(parse_resp.body);
  print(parse_resp);
  var x = parse_resp.querySelectorAll('a');
  print(x);
  // print(x.first.outerHtml);
  // print(x.first.innerHtml);
  // print(x.first.text);
}
*/
