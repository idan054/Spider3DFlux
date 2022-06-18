import 'package:flutter/material.dart';
import 'package:fstore/models/cart/cart_base.dart';
import 'package:provider/provider.dart';
import 'RadioButtonV3.dart';
import 'checkoutV3_provider.dart';
import 'widgets/checkout_buttonV3.dart';
import 'infoCardV3.dart';
import 'widgets/build_checkoutScreenV3.dart';

// Todo Get products on cart         (From provider)
// Todo Get coupon in use            (From provider)
// Todo Get user detail(s) is logged (From provider)

// Todo Redirect to payment gate and validate (Based /success url)
// Todo Create order on Woo
// Todo Reset order in App
class CheckoutScreenV3 extends StatelessWidget {
  const CheckoutScreenV3({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    cartModel.changeBillingStatus('Stop');

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: const Text('עמוד קופה'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Provider.of<CheckoutProviderV3>(context, listen: false).dispose();
              Navigator.of(context).pop();
            }),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 3.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            InfoCardV3(
              mainTitle: 'כתובת משלוח',
              title: 'לחץ לעדכון כתובת משלוח',
              icon: Icons.home,
              isPayment: false,
            ),
            InfoCardV3(
              mainTitle: 'פרטי תשלום',
              title: 'לחץ לעדכון פרטי תשלום',
              icon: Icons.credit_card,
              isPayment: true,
            ),
            buildMainTitle(context, 'שיטת משלוח'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                  // shrinkWrap: true, // Set this
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomRadioButtonV3(
                      'עד 3-4 ימי עסקים ₪29', 1,
                      isPayment: false,
                    ),
                    CustomRadioButtonV3('מהיום להיום ₪45', 2,
                        isPayment: false,
                        subText: 'לאשקלון - נתניה, ללא ירושלים ומושבים'),
                    CustomRadioButtonV3(
                      'איסוף עצמי ₪0', 3,
                      isPayment: false,
                      subText: 'פרטי איסוף ישלחו ב SMS',
                    ),
                  ],
                ),
              ),
            ),
            // region payment option - commented
/*            buildMainTitle(context, 'שיטת תשלום'),
            SizedBox(
              height: 80,
              child: Row(
                // shrinkWrap: true, // Set this
                // scrollDirection: Axis.horizontal,
                children: [
                  CustomRadioButtonV3(
                    'כרטיס אשראי', 1,
                  ),
                  CustomRadioButtonV3(
                    'מזומן באיסוף עצמי', 2,
                  ),
                ],
              ),
            ),*/
            // endregion payment option - commented
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      // width: 140,
                      child: buildAddNoteButton(context)),
                  Flexible(
                    child: Column(
                      children: [
                        buildRowPrices(context, 'הזמנה:'),
                        buildRowPrices(context, 'משלוח:'),
                        Provider.of<CartModel>(context, listen: false).getCoupon() != '' ?
                        buildRowPrices(context,'קופון:', isCoupon: true) : const SizedBox(),
                        buildRowPrices(context, 'סה"כ:'),
                      ],
                    ),
                  ) ]
              )),
            const SizedBox(height: 10),
            const CheckoutButtonV3(),
          ]
        ))
    );
  }
}
