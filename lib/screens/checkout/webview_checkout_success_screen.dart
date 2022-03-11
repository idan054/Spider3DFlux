import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../models/index.dart' show Order;
import 'widgets/success.dart';

// class SuccessScreen extends StatelessWidget {
//   final Order? order;
//   SuccessScreen({this.order});

class SuccessScreen extends StatefulWidget {
  final Order? order;
  SuccessScreen({this.order});
  // const SuccessScreen({Key? key}) : super(key: key);

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ההזמנה התקבלה!'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // MainTabControlDelegate.getInstance().changeTab('home');
              // Navigator.of(context).popAndPushNamed(RouteList.home);
              Navigator.of(context).pushNamed(RouteList.cart);
            }
          ),
        backgroundColor: kGrey200,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: OrderedSuccess(
          order: widget.order,
          isModal: true,
        ),
      ),
    );
  }
}
