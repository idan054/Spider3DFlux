
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/cart/cart_base.dart';
import 'my_creditcard_address.dart';

var show_creditCard_details = true;

class CreditCardInfo extends StatefulWidget {
  @override
  State<CreditCardInfo> createState() => _CreditCardInfoState();
}

class _CreditCardInfoState extends State<CreditCardInfo> {
/*  Future<void> initState() async {
    // TODO: implement initState
    var myAddress =
        await Provider.of<CartModel>(context, listen: false).getAddress();
    print("The CC Details (2):");
    print(myAddress!.cardHolderName);
    print(myAddress.cardNumber);
    print(myAddress.expiryDate);
    print(myAddress.cvv);
    super.initState();
  }*/
  @override
  @override
  Widget build(BuildContext context) {
    var cartModel = Provider.of<CartModel>(context);
    return ListenableProvider.value(
      value: cartModel,
      child: Consumer<CartModel>(
        builder: (context, myCart, child) {
          var ccLength = myCart.address?.cardNumber?.length;

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
                          'בעל הכרטיס :',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          // 'XX YY',
                          '${myCart.address!.cardHolderName}',
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
                          // S.of(context).firstName + ' :',
                          'מס׳ תעודת זהות :',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          // '**** **** **** 2743',
                          // '**** **** **** ${myCart.address!.cardNumber!.substring(12, ccLength)}',
                          '${myCart.address!.cardHolderId}',
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      )
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
                            builder: (_) => MyCreditCardForm(
                                  onNext: () {},
                                  isFullPage: true,
                                )));
                      },
                      child: Text(
                        'ערוך כרטיס אשראי',
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
        },
      ),
    );
  }
}
