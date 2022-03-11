import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/cart/cart_base.dart';
import '../functions/handleNotesDialogV3.dart';

/// A build methods widgets for checkout_screenV3.dart
Widget buildRowPrices(BuildContext context, String type,
    {bool isCoupon = false}) {
  TextStyle _style(bool isBold) {
    return Theme.of(context).textTheme.subtitle2!.copyWith(
        fontWeight: isBold ? FontWeight.w600 : FontWeight.w500, fontSize: 15);
  }

  return Consumer<CartModel>(builder: (context, cartModel, child) {
    /*                 buildRowPrices(context, '249', 'עלות הזמנה'),
                  buildRowPrices(context, '29', 'עלות משלוח'),
                  buildRowPrices(context, '29', 'הנחת קופון'),
                  buildRowPrices(context, '278', 'סה"כ'),*/
    String? price;
    switch (type) {
      case 'הזמנה:':
        price = '${cartModel.getSubTotal()}';
        break;
      case 'משלוח:':
        price = '${cartModel.getShippingCost()}';
        break;
      case 'קופון:':
        price = '${cartModel.getCouponCost()}';
        break;
      case 'סה"כ:':
        price = '${cartModel.getTotal()}';
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            ' $type',
            style: _style(false),
          ),
          // const SizedBox(width: 5),
          const Spacer(),
          Text(
            isCoupon ? '$price - ₪' : '₪$price',
            style: _style(true),
          )
        ],
        // Text('$price₪ -', style: _style(true),)],
      ),
    );
  });
}

Container buildMainTitle(BuildContext context, String title) {
  return Container(
    alignment: Alignment.centerRight,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Text('$title',
        style: Theme.of(context)
            .textTheme
            .subtitle2!
            .copyWith(fontWeight: FontWeight.w600)
            .copyWith(fontSize: 18)),
  );
}

Widget buildAddNoteButton(BuildContext context) {
  Color? color = Theme.of(context).primaryColorLight.withOpacity(0.7);
  TextStyle? radioStyle = Theme.of(context).textTheme.subtitle2!.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: Theme.of(context).accentColor
      // (selectedIndex == index) ? Colors.white : Colors.black,
      );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FlatButton(
        splashColor: color.withOpacity(0.3),
        // color: (selectedIndex == index) ?  selectedColor : color,
        color: color,
        onPressed: () => showNotesDialogV3(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          // side: BorderSide(color: color, width: 2, style: BorderStyle.solid),
          side: BorderSide(color: color, width: 2, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              color: Theme.of(context).accentColor,
              size: 15,
            ),
            const SizedBox(width: 5),
            Text('הוסף הערה', textAlign: TextAlign.center, style: radioStyle),
          ],
        ),
        // borderSide: BorderSide(color: (value == index) ? Colors.green : Colors.black),
      ),
      ValueListenableBuilder(
        valueListenable: noteController,
        builder: (context, value, child) => Container(
          // color: Colors.green,
          margin: const EdgeInsets.only(right: 3),
          // width: 200,
          width: MediaQuery.of(context).size.width * 0.5,
          child: Text(
            noteController.text,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.start,
            maxLines: 1,
            style: TextStyle(color: Theme.of(context).accentColor.withOpacity(0.7)),
          ),
        ),
      ),
    ],
  );
}
