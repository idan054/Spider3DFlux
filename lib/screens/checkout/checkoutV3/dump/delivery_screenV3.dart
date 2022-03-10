import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/theme/colors.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/cart/cart_base.dart';
import '../widgets/delivery_formV3.dart';

/// Not in use
class DeliveryScreenV3 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          // backgroundColor: Theme.of(context).backgroundColor,
          backgroundColor: const Color(0xfff1f1f1),
          title: Text(
            S.of(context).shippingAddress,
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          leading: Center(
            child: IconButton(
              onPressed: () async {
                // Provider.of<CartModel>(context, listen: false).setAddress(address);
                // Navigator.pop(context);
                // await Navigator.of(context).push(MaterialPageRoute(builder: (_) => Checkout()));
                var myAddress =
                await Provider.of<CartModel>(context, listen: false)
                    .getAddress();
              },
              icon: const Icon(Icons.arrow_back_ios),
              color: Theme.of(context).accentColor,
              iconSize: 20,
            ),
          ),
        ),
        body: Center(
          child: Container(
              decoration: BoxDecoration(
                color: kGrey200.withOpacity(0.10),
                border: Border.all(
                  color: kGrey200.withOpacity(0.99),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(15.0),
              child: const DeliveryFormV3()),
        )
    );
  }


}
