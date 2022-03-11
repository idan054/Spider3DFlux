import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show Order, UserModel, PointModel;
import '../../../routes/flux_navigate.dart';
import '../../../services/index.dart';
import '../../base_screen.dart';
import '../checkout_screen.dart';

class OrderedSuccess extends StatefulWidget {
  final Order? order;
  final bool? isModal;
  final PageController? controller;

  OrderedSuccess({this.order, this.isModal, this.controller});

  @override
  _OrderedSuccessState createState() => _OrderedSuccessState();
}

class _OrderedSuccessState extends BaseScreen<OrderedSuccess> {
  @override
  void afterFirstLayout(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false).user;
    if (user != null &&
        user.cookie != null &&
        kAdvanceConfig['EnablePointReward']) {
      Services().api.updatePoints(user.cookie, widget.order);
      Provider.of<PointModel>(context, listen: false).getMyPoint(user.cookie);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return ListView(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(color: Theme.of(context).primaryColorLight),
        ),
        const SizedBox(height: 30),
        Text(
          S.of(context).orderSuccessTitle1,
          style: TextStyle(fontSize: 18, color: Theme.of(context).accentColor),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              S.of(context).orderNo,
              style:
                  TextStyle(fontSize: 14, color: Theme.of(context).accentColor),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                '#${widget.order!.number}',
                style: TextStyle(
                    fontSize: 14, color: Theme.of(context).accentColor),
              ),
            )
          ],
        ),
        const SizedBox(height: 15),
        Text(
          'למעקב הכנס אל היסטוריית ההזמנות בעמוד הפרופיל',
          style: TextStyle(
              color: Theme.of(context).accentColor, height: 1.4, fontSize: 14),
        ),
        if (userModel.user != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Expanded(
                child: ButtonTheme(
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        newOrder = null;
                      });
                      widget.controller == null
                          ? widget.controller?.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                            )
                          : Navigator.of(context).pushNamed(RouteList.orders);
                      ;

                      final user =
                          Provider.of<UserModel>(context, listen: false).user;
                      FluxNavigate.pushNamed(
                        RouteList.orders,
                        arguments: user,
                      );

                      setState(() {
                        newOrder = null;
                      });
                    },
                    child: Text(
                      S.of(context).showAllMyOrdered.toUpperCase(),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Row(
            children: [
              Expanded(
                child: ButtonTheme(
                  height: 45,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder()),
                    onPressed: () {
                      Navigator.of(context).pushNamed(RouteList.cart);

/*                      setState(() {
                        newOrder = null;
                      });
                      widget.controller!.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                      );

                      if (widget.isModal != null && widget.isModal == true) {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      } else {
                        MainTabControlDelegate.getInstance()
                            .changeTab(RouteList.home.replaceFirst('/', ''));
                      }*/
                    },
                    child: Text(
                      // S.of(context).backToShop.toUpperCase(),
                      'חזור לעגלה',
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  void dispose() {
    print('Widget SuccessScreen disposed!');
    // MainTabControlDelegate.getInstance().changeTab('cart');
    Navigator.of(context).pushNamed(RouteList.cart);
    // TODO: implement dispose
    super.dispose();
  }
}
