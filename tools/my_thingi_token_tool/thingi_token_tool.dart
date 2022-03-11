import 'dart:core';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

// This tool create  Based Login Cookies (PostMan Request)
void main() async {
  print('Start');
  var token;
  var token_list = [];
  // var i = Random().nextInt(2021);
  var i = 300; // Start From: 300 (U can also check it by looking for
  // the highest number here with CTRL F -> https://www.thingiverse.com/developers/my-apps)
  token = await get_token(i);

  while (i < 600) {
    // print('Wait 3 sec');
    await Future.delayed(const Duration(seconds: 0), () async {
      print('Start request $i..');
      token = await get_token(i);
      print('Token = $token');
      print(i);
      token_list.add('$token');
      i++;
    });
  }

  print(token_list);
}

// Built by PostMan
Future get_token(i) async {
  // if Not working or status is 200 -  CTRL F This on console to understand why:
  // <div class="alert alert-error">

  // >>> Create Token
  var headers = {
    'sec-ch-ua':
        '" Not;A Brand";v="99", "Microsoft Edge";v="97", "Chromium";v="97"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"macOS"',
    'Upgrade-Insecure-Requests': '1',
    'Content-Type': 'application/x-www-form-urlencoded',
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.45 Safari/537.36 Edg/97.0.1072.34',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'Cookie':
        'distinct_id=1c8fd38ebd71aa54351075fdd857acf8-1639756515; origin_req=%2Fapps%2Fcreate; PHPSESSID=d005825c625a6413f19356fe40e26409; _dd_s=logs=1&id=ae8f9add-b91d-467a-8021-bf7dbd986648&created=1639754581511&expire=1639757702070; dd_cookie_test_04c1c211-e032-4687-b492-332141e0b223=test; dd_cookie_test_04e6c999-e7f7-4cca-a2ad-ae8c41b73296=test; dd_cookie_test_16d87a4c-87b1-4729-8ad3-d6dcf973001f=test; dd_cookie_test_17555316-bdf6-46aa-9659-3ba96d35d366=test; dd_cookie_test_20f15a4b-10f0-42f5-bceb-b5d946e417f9=test; dd_cookie_test_4877857c-acaa-4ea0-ab03-8f6b33f4785d=test; dd_cookie_test_56c86124-04b1-4a33-a1a3-64eaba858303=test; dd_cookie_test_5ff97959-fbfd-4c7f-b4f9-a6a76665192f=test; dd_cookie_test_672e4dde-f4aa-4477-ba8b-cb0f4312288c=test; dd_cookie_test_6781e09a-cfd6-4b81-b921-2451e41828f7=test; dd_cookie_test_68621fbd-c504-4ff9-98c8-850a4d15b956=test; dd_cookie_test_76d81da9-fd97-4cf0-b26c-d0bcb4640df4=test; dd_cookie_test_7780ba26-fbf6-436f-bf8a-090ffe91ff8e=test; dd_cookie_test_9c27f0bd-35a3-41a8-9c6a-c18055f15dbc=test; dd_cookie_test_a6a7b207-98b7-497c-8d12-f989b992b67c=test; dd_cookie_test_b21aa78a-785e-42bf-b641-0e71816dc815=test; dd_cookie_test_b4c83988-1416-4f0b-a8cf-2775fb2d893d=test; dd_cookie_test_b6923765-b2f6-4595-9997-e32ab1f51173=test; dd_cookie_test_b8f2d0d6-d005-46ff-bc79-44155311422f=test; dd_cookie_test_c6627342-3e2d-49e5-9eb5-56710c26dd8c=test; dd_cookie_test_d137437e-8590-4228-a1ba-b54e6ff64211=test; dd_cookie_test_db34c0ac-590d-4ac7-acdd-3b7b9acf0daf=test; dd_cookie_test_de437d43-5e68-47cf-8485-e79bdac03b75=test; dd_cookie_test_e6b74555-59c7-45fe-84f8-6a4d1ca2ede4=test; dd_cookie_test_eb61be9b-2d66-477d-a15f-4378d1c1115a=test; dd_cookie_test_eca87467-0660-4728-abe9-f9c9118c7dda=test; dd_cookie_test_f10a73db-2f4c-47eb-80f3-9a4ba1878242=test; dd_cookie_test_faf41d75-8ecd-4c45-b06f-d6af879036f8=test'
  };
  var create_token_body = {
    '_CSRF_INDEX': 'Nm7wDCAxxnk/l0f+GEFk/TRU',
    '_CSRF_TOKEN': '8Lem7hFJU4NTDWDXVihxRM9FSx/xkqOygibMhMAsoFeY',
    'agree_terms': 'true',
    'app_type_id': '2',
    'description': '${i}Token',
    'name': '${i}Token'
  };
  final response = await http.post(
      Uri.parse('https://www.thingiverse.com/apps/create'),
      body: create_token_body,
      headers: headers);
  // print(response.statusCode);
  // print(response.body);

  // >>> Get Token Part 1/2
  var app_url = 'https://www.thingiverse.com/apps/${i}token';
  var app_resp = await http.get(Uri.parse(app_url), headers: headers);
  // print(app_resp.statusCode);
  var button_class = parse(app_resp.body)
      .getElementsByClassName('button blue-button bottom_content');
  var token_id = button_class.first.attributes['href'];
  // print(token_id); // >>> /app:3546/edit

  // >>> Get Token Part 2/2
  var edit_url = 'https://www.thingiverse.com$token_id';
  var edit_resp = await http.get(Uri.parse(edit_url), headers: headers);
  // print(edit_resp.statusCode);

  String? scrape_token(resp) {
    var parse_resp = parse(resp);
    // print(parse_resp.body);
    // print(parse_resp.body?.text);
    for (var item in parse_resp.getElementsByTagName('input')) {
      if (item.attributes['name'] == 'token-read-only') {
        return item.attributes['value'];
      }
    }
  }

  var _token = scrape_token(edit_resp.body);
  // print('_token');
  // print(_token);

  return _token;
}
