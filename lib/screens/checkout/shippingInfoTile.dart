
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/index.dart'
    show
        Address,
        AppModel,
        CartModel,
        PaymentMethodModel,
        Product,
        ShippingMethodModel,
        TaxModel,
        UserModel;
import 'widgets/shipping_form.dart';


class ShippingInfoTile extends StatefulWidget {
  @override
  State<ShippingInfoTile> createState() => _ShippingInfoTileState();
}

class _ShippingInfoTileState extends State<ShippingInfoTile> {
  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    // final address = cartModel.address!;
    var address = cartModel.address; // My

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    // S.of(context).firstName + ' :',
                    'שם לחשבונית :',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address!.firstName!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),
/*
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).lastName + ' :',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address.lastName!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),
*/

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).city + ' :',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address.city ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    // S.of(context).streetName + ' :',
                    'רחוב, מס׳ בית :',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address.street ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),

          /*   FutureBuilder(
            future: Services().widget.getCountryName(context, address.country),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 120,
                        child: Text(
                          S.of(context).country + ' :',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          snapshot.data as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          ),*/
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    // S.of(context).phoneNumber + ' :',
                    'טלפון :',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address.phoneNumber ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).email + ' :',
                    // 'אימייל :',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 20),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 0, bottom: 5, top: 10),
            child: ButtonTheme(
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  primary: Theme.of(context).primaryColorLight,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ShippingForm(
                            onNext: () {},
                            isFullPage: true,
                          )));

                },
                child: Text(
                  'ערוך כתובת משלוח',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
