import 'package:flutter/material.dart';
// import 'package:fstore/models/cart/entities/payment_method.dart';
import 'package:provider/provider.dart';

import '../../../models/index.dart';
import 'checkoutV3_provider.dart';

// Todo change the colors in this files to based Theme
class CustomRadioButtonV3 extends StatelessWidget {
  final String text;
  final int index;
  final bool isPayment;
  final String? subText;

  CustomRadioButtonV3(this.text, this.index,
      {this.isPayment = true, this.subText});

  @override
  Widget build(BuildContext context) {
    Color? color = Theme.of(context).primaryColorLight.withOpacity(0.7);
    Color? selectedColor = Theme.of(context).accentColor;
    print('Widget render!');


    return Consumer<CheckoutProviderV3>(
    builder: (context, checkoutModel, child) {
      var cartModel = Provider.of<CartModel>(context, listen: false);
      // var shippingMethodModel = Provider.of<ShippingMethodModel>(context, listen: false);
      PaymentMethod? paymentMethod;
      ShippingMethod? shippingMethod;

       // Remember last choice:
       var selectedIndex = isPayment ? checkoutModel.paymentIndex : checkoutModel.shippingIndex;

      TextStyle? radioStyle = Theme.of(context).textTheme.subtitle2!.copyWith(
          fontWeight:
              (selectedIndex == index) ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.1,
          color: Theme.of(context).accentColor
          // (selectedIndex == index) ? Colors.white : Colors.black,
          );

      // On The cash will appear only if local pickup selected
      if (text == 'מזומן באיסוף עצמי'
          // isPayment && index == 2 // AKA if Cash Button
          && checkoutModel.shippingIndex != 3 ){
        return Container();
      }

      return
        ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 90.0),
            child:
        Container(
          // height: 80,
          width: 120,
          // width: MediaQuery.of(context).size.width * 0.4,
          // height: MediaQuery.of(context).size.height * 0.0525,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child:
            FlatButton(
            splashColor: color.withOpacity(0.3),
            // color: (selectedIndex == index) ?  selectedColor : color,
            color: color,
            onPressed: () async {
              // CREDIT CARD default sets on cart_model_woo.dart - paymentMethod = PaymentMethod(...
              /// CREDIT CARD default sets on cart_model_woo.dart - paymentMethod = PaymentMethod(...
              //// CREDIT CARD default sets on cart_model_woo.dart - paymentMethod = PaymentMethod(...
              selectedIndex = index;
              print('selectedIndex = index?');
              print('$selectedIndex = $index');
              if (isPayment) {
                checkoutModel.changePaymentIndex(index);
              } else {
                checkoutModel.changeShippingIndex(index);
              }

              // When delivery method is not local pickup,
              // Set credit card payment option
              // if(!isPayment && index != 3){
                checkoutModel.changePaymentIndex(1);
                cartModel.setPaymentMethod( PaymentMethod(
                    title: 'מאובטח באשראי Spider3D App - iCredit',
                    // title: 'Credit card - iCredit',
                    description: 'תשלום מאובטח באשראי - iCredit',
                    id: 'icredit_payment',
                    enabled: true));
              // }

              /// Payment form:
              if (isPayment) {
                // print('Set paymentMethod...');
                // region paymentMethod switch
                switch (index) {
                  case 1:
                    paymentMethod = PaymentMethod(
                        title: 'מאובטח באשראי Spider3D App - iCredit',
                        // title: 'Credit card - iCredit',
                        description: 'תשלום מאובטח באשראי - iCredit',
                        id: 'icredit_payment',
                        enabled: true);
                    break;

                  case 2:
                    paymentMethod = PaymentMethod(
                        title: 'מזומן באיסוף עצמי - Spider3D App',
                        // title: 'Cash on delivery',
                        description: 'מזומן באיסוף עצמי',
                        id: 'cod',
                        enabled: true);
                    break;
                }
                // endregion paymentMethod switch
                // print('paymentMethod');
                // print(paymentMethod?.title);

                cartModel.setPaymentMethod(paymentMethod);
                var _paymentMethod = cartModel.paymentMethod;
                // print('_paymentMethod');
                print(_paymentMethod?.title);
                print(_paymentMethod?.id);
              }

              /// Shipping form:
              else {
                // print('Set shippingMethod...');
                // region shippingMethod switch
                switch (index) {
                  case 1:
                    shippingMethod = ShippingMethod(
                      title: 'עד 3-4 ימי עסקים',
                      methodId: 'flat_rate',
                      cost: 29.0,
                      id: 'flat_rate:6',
                      methodTitle: 'עד 3-4 ימי עסקים',
                      description: null,
                      classCost: null,
                      min_amount: null,
                    );
                    break;

                  case 2:
                    shippingMethod = ShippingMethod(
                      title:
                      '🚀 מהיום להיום אשקלון-נתניה - (ללא ירושלים; ללא מושבים)',
                      methodId: 'flat_rate',
                      cost: 45.0,
                      id: 'flat_rate:11',
                      methodTitle:
                      '🚀 מהיום להיום אשקלון-נתניה - (ללא ירושלים; ללא מושבים)',
                      description: null,
                      classCost: null,
                      min_amount: null,
                    );
                    break;

                  case 3:
                    shippingMethod = ShippingMethod(
                      title:
                      'איסוף עצמי - לוקר ראשון לציון (קוד ופרטים ישלחו ב-SMS )',
                      methodId: 'local_pickup',
                      cost: 0.0,
                      id: 'local_pickup:15',
                      methodTitle:
                      'איסוף עצמי - לוקר ראשון לציון (קוד ופרטים ישלחו ב-SMS )',
                      description: null,
                      classCost: null,
                      min_amount: null,
                    );
                    break;
                }
                // endregion shippingMethod switch
                print('shippingMethod');
                print(shippingMethod?.id);
                print(shippingMethod?.title);

                cartModel.setShippingMethod(shippingMethod);
                var _shippingMethod = cartModel.shippingMethod?.title;
                // print('_shippingMethod');
                print(_shippingMethod);

                // region ShippingMethod Json resp

                /*
                  [
    {
          id: flat_rate: 6,
          method_id: flat_rate,
          instance_id: 6,
          label: עד3-4ימיעסקים,
          cost: 29.00,
          taxes: [

          ],
          shipping_tax: 0
    },
    {
          id: flat_rate: 11,
          method_id: flat_rate,
          instance_id: 11,
          label: 🚀מהיוםלהיוםאשקלון-נתניה-(ללאירושלים;ללאמושבים),
          cost: 45.00,
          taxes: [

          ],
          shipping_tax: 0
    },
    {
          id: local_pickup: 15,
          method_id: local_pickup,
          instance_id: 15,
          label: איסוףעצמי-לוקרראשוןלציון(קודופרטיםישלחוב-SMS),
          cost: 0.00,
          taxes: [

          ],
          shipping_tax: 0
    }
  ]
  */ /*
                  // endregion ShippingMethod Json resp
                  }*/
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              // side: BorderSide(color: color, width: 2, style: BorderStyle.solid),
              side: BorderSide(
                  color: (selectedIndex == index) ? selectedColor : color,
                  width: 3,
                  style: BorderStyle.solid),
            ),
            child:
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(text, textAlign: TextAlign.center, style: radioStyle),
                      subText != null
                          ? Text('$subText',
                          textAlign: TextAlign.center,
                          style: radioStyle.copyWith(fontSize: 10))
                          : Container(),
                    ],
                  ),
                )
            // borderSide: BorderSide(color: (value == index) ? Colors.green : Colors.black),
          ),
        ),
      );
    });
  }
}
