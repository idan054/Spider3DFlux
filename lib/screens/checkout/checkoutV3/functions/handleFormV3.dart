import 'package:flutter/material.dart';
import 'package:fstore/screens/checkout/checkoutV3/widgets/delivery_formV3.dart';
import 'package:fstore/screens/checkout/checkoutV3/widgets/payment_formV3.dart';

void showFormDialogV3(BuildContext context, bool isPayment) async {
  return showDialog<void>(
    barrierColor: Colors.black26,
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text( isPayment ? 'פרטי תשלום' : 'פרטי משלוח',
              style: const TextStyle(
                // color: Colors.white,
                // color: Theme.of(context).primaryColor,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
/*            Text( isPayment ? 'בתשלום במזומן יש להכניס אשראי כביטחון בלבד.' : '',
              style: const TextStyle(
                // color: Colors.white,
                // color: Theme.of(context).primaryColor,
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.0,
              ),
            ),*/
          ],
        ),
        // actions: <Widget>[],
        titlePadding: const EdgeInsets.only(right: 15, top: 10, bottom: 5, left: 15),
        contentPadding: const EdgeInsets.all(0), // inside
        insetPadding: const EdgeInsets.all(10), // outside
        content: SingleChildScrollView(
            child: isPayment ?
            const PaymentFormV3()
          : const DeliveryFormV3()),
      );
    },
  );
}

void showBottomSheetFormDialogV3(BuildContext context) async {
  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 200,
        color: Colors.amber,
        child: const Center(child: DeliveryFormV3()),
      );
    },
  );
}
