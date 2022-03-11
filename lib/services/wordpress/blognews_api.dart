import 'dart:convert';
import 'dart:core';
import 'dart:io' show HttpHeaders;

import 'package:http/http.dart' as http;
import 'package:inspireui/extensions.dart';

import '../https.dart';

class QueryString {
  static Map parse(String query) {
    var search = RegExp('([^&=]+)=?([^&]*)');
    var result = {};

    if (query.startsWith('?')) query = query.substring(1);
    String decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

    for (Match match in search.allMatches(query)) {
      result[decode(match.group(1)!)] = decode(match.group(2)!);
    }
    return result;
  }
}

class BlogNewsApi {
  String? url;
  bool? isHttps;

  BlogNewsApi(this.url) {
    if (url!.startsWith('https')) {
      isHttps = true;
    } else {
      isHttps = false;
    }
  }

  Uri? _getOAuthURL(String requestMethod, String endpoint) {
    return '$url/wp-json/wp/v2/$endpoint'.toUri();
  }

  Future<dynamic> getBlogs({page = 1}) async {
//    final response = await getAsync('${this.url}/wp-json/wp/v2/posts?_embed&page=$page');
//    return jsonDecode(response.body);
  }

  Future<http.StreamedResponse> getStream(String endPoint) async {
    var client = http.Client();
    var request = http.Request('GET', Uri.parse(url!));
    return client.send(request);
  }

  Future<dynamic> getAsync(String endPoint) async {
    final url = _getOAuthURL('GET', endPoint)!;

    final response = await httpCache(url);
    return json.decode(response.body);
  }

  Future<dynamic> postAsync(String endPoint, Map? data) async {
    var url = _getOAuthURL('POST', endPoint)!;

    var client = http.Client();
    var request = http.Request('POST', url);
    request.headers[HttpHeaders.contentTypeHeader] =
        'application/json; charset=utf-8';
    request.headers[HttpHeaders.cacheControlHeader] = 'no-cache';
    request.body = json.encode(data);
    var response =
        await client.send(request).then((res) => res.stream.bytesToString());
//    await client.post(url, body: request.body).toString();
    var dataResponse = await json.decode(response);
    return dataResponse;
  }

  Future<dynamic> putAsync(String endPoint, Map data) async {
    var url = _getOAuthURL('PUT', endPoint)!;

    var client = http.Client();
    var request = http.Request('PUT', url);
    request.headers[HttpHeaders.contentTypeHeader] =
        'application/json; charset=utf-8';
    request.headers[HttpHeaders.cacheControlHeader] = 'no-cache';
    request.body = json.encode(data);
    var response =
        await client.send(request).then((res) => res.stream.bytesToString());
    var dataResponse = await json.decode(response);
    return dataResponse;
  }
}
