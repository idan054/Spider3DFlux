import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/utils/logs.dart';

import '../common/constants.dart';
import '../services/index.dart';
import 'entities/point.dart';

class PointModel extends ChangeNotifier {
  final Services _service = Services();
  Point? point;

  Future<void> getMyPoint(String? token) async {
    // var url = 'https://spider3d.co.il/wp-json/woorewards/v1/points/$user_email/_/$points?consumer_key=ck_be61455d30704ff30718f80b417dd41c320b0cb0&consumer_secret=cs_79c75a8e1c40acfe530e6254f3cbb61a2e01f872';
    // print(url);

    var dio = Dio();

    try {
      point = await _service.api.getMyPoint(token); // original
      // point = await dio.put(url);
    } catch (err) {
      printLog('getMyPoint $err');
    }
    notifyListeners();
  }
}
