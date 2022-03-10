
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart'
    show
        AppModel,
        CartModel,
        Order,
        PaymentMethodModel,
        ShippingMethodModel,
        TaxModel,
        UserModel;
import '../../../modules/native_payment/index.dart';
import '../../../services/index.dart';
import '../review_screen.dart';

class PaymentMethodsRadio extends StatefulWidget {
  final Function? onRadioChange;
  // final Function(bool)? onLoading;en

  PaymentMethodsRadio({this.onRadioChange});

  @override
  _PaymentMethodsRadioState createState() => _PaymentMethodsRadioState();
}

String? selectedPaymentId;
class _PaymentMethodsRadioState extends State<PaymentMethodsRadio> with RazorDelegate {
  // String? radioSelectionId;
  var order_status = '';
  bool isPaying = false;
  var showCheckoutLoading = false;

  @override
  void initState() {
    super.initState();

    final cartModel = Provider.of<CartModel>(context, listen: false);
    Future.delayed(Duration.zero, () {
      final userModel = Provider.of<UserModel>(context, listen: false);
      final getPaymentMethods = Provider.of<PaymentMethodModel>(context,
              listen: false)
          .getPaymentMethods(
              cartModel: cartModel,
              shippingMethod: cartModel.shippingMethod,
              token: userModel.user != null ? userModel.user!.cookie : null);

      // My
      // final paymentMethodModel = Provider.of<PaymentMethodModel>(context, listen: false);

      // final paymentMethod = paymentMethodModel.paymentMethods.first;
      // Provider.of<CartModel>(context, listen: false).setPaymentMethod(paymentMethod);
      // print('4 Deafult paymentMethod.title');

      print(cartModel.paymentMethod?.title ??
          'Null = cartModel.paymentMethod?.title');

      if (kPaymentConfig['EnableReview'] != true) {
        Provider.of<TaxModel>(context, listen: false)
            .getTaxes(Provider.of<CartModel>(context, listen: false),
                (taxesTotal, taxes) {
          Provider.of<CartModel>(context, listen: false).taxesTotal =
              taxesTotal;
          Provider.of<CartModel>(context, listen: false).taxes = taxes;
          setState(() {});
        });
      }
    });
  }

  var oldShippingMethodTitle = 'NULL';
  // var isFirstGetPaymentMethods = true;

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final paymentMethodModel = Provider.of<PaymentMethodModel>(context);
    final taxModel = Provider.of<TaxModel>(context);

    return Stack(
      children: [
        ListenableProvider.value(
          value: cartModel,
          child: ListenableProvider.value(
              value: paymentMethodModel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(S.of(context).paymentMethods,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 5),
                  Text(
                    // 'בחר את שיטת התשלום שלך',
                    'ניתן לשלם במזומן באיסוף עצמי',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<CartModel>(builder: (context, cartModel, child) {
                    return Consumer<PaymentMethodModel>(
                        builder: (context, model, child) {
                      if (model.isLoading) {
                        return Container(
                            height: 100, child: kLoadingWidget(context));
                      }

                      if (model.message != null) {
                        return Container(
                          height: 100,
                          child: Center(
                              child: Text(model.message!,
                                  style: const TextStyle(color: kErrorRed))),
                        );
                      }

                      // MY COMMENTED - DEFAULT PAYMENT OPTION
                      /*                                if (selectedId == null && model.paymentMethods.isNotEmpty) {
                    selectedId = model.paymentMethods
                        .firstWhere((item) => item.enabled!)
                        .id;
                  }*/

                      // return ChangeNotifierProvider.value(
                      // return ListenableProvider.value(

                      // if (cartModel.shippingMethod!.title != oldShippingMethodTitle) {
                      //   print(oldShippingMethodTitle);
                      //   oldShippingMethodTitle = cartModel.shippingMethod!.title!;
                      //   print(oldShippingMethodTitle);
                      //
                      // }

                      // printLog(cartModel.shippingMethod!.title);

                      // print('P Payment methods:');
                      /*                model.paymentMethods.map((item) {
                        print('STart it.');
                        if (item.title == 'PayPal') {
                          model.paymentMethods.remove(item);
                        } else {
                          print(item.title);
                        }
                      });*/
                      for (int i = 0; i < model.paymentMethods.length; i++) {
                        var item = model.paymentMethods[i];
                        if (item.title == 'PayPal') {
                          model.paymentMethods.remove(item);
                          // } else {
                          // print(item.title);
                          // }
                        }
                      }

                      return Column(
                        children: <Widget>[
                          // Text(cartModel.shippingMethod!.title ?? 'my null',),
                          // Text(oldShippingMethodTitle //.?? 'my null',),

                          for (int i = 0; i < model.paymentMethods.length; i++)
                            model.paymentMethods[i].enabled!
                                ? Column(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedPaymentId =
                                                model.paymentMethods[i].id;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  model.paymentMethods[i].id ==
                                                          selectedPaymentId
                                                      ? Theme.of(context)
                                                          .primaryColorLight
                                                      : Colors.transparent),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 10),
                                            child: Row(
                                              children: <Widget>[
                                                Radio(
                                                    activeColor: kColorSpiderRed,
                                                    focusColor: kColorSpiderRed,
                                                    value: model
                                                        .paymentMethods[i].id,
                                                    groupValue: selectedPaymentId,
                                                    onChanged: (dynamic i) {
                                                      // widget.onRadioChange;

                                                      setState(() {
                                                        selectedPaymentId = i;
                                                      });

                                                      if (paymentMethodModel
                                                          .paymentMethods
                                                          .isNotEmpty) {
                                                        final paymentMethod =
                                                            paymentMethodModel
                                                                .paymentMethods
                                                                .firstWhere((item) =>
                                                                    item.id ==
                                                                    selectedPaymentId);

                                                        Provider.of<CartModel>(
                                                                context,
                                                                listen: false)
                                                            .setPaymentMethod(
                                                                paymentMethod);

                                                        print('paymentMethod.title');
                                                        print(paymentMethod.title);
                                                        print(paymentMethod.id);

                                                      }

                                                      setState(() {
                                                        paymentFormOpen = true;
                                                      });

                                                      widget.onRadioChange;
                                                      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Checkout()));
                                                      // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: Checkout()));
                                                    }),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      if (Payments[model
                                                              .paymentMethods[i]
                                                              .id] !=
                                                          null)
                                                        Image.asset(
                                                          Payments[model
                                                              .paymentMethods[i]
                                                              .id],
                                                          width: 120,
                                                          height: 30,
                                                        ),
                                                      if (Payments[model
                                                              .paymentMethods[i]
                                                              .id] ==
                                                          null)
                                                        Services()
                                                            .widget
                                                            .renderShippingPaymentTitle(
                                                                context,
                                                                model
                                                                    .paymentMethods[
                                                                        i]
                                                                    .title!),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(height: 1)
                                    ],
                                  )
                                : Container()
                        ],
                      );
                    });
                  }),
                  const SizedBox(height: 20),
                  // Services().widget.renderShippingMethodInfo(context),
                  if (cartModel.getCoupon() != '')
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            S.of(context).discount,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.8),
                            ),
                          ),
                          Text(
                            cartModel.getCoupon(),
                            style:
                                Theme.of(context).textTheme.subtitle1!.copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .accentColor
                                          .withOpacity(0.8),
                                    ),
                          )
                        ],
                      ),
                    ),
                  // Services().widget.renderTaxes(taxModel, context),
                  // Services().widget.renderRewardInfo(context),

/*
                  Visibility(
                    visible: false,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(S.of(context).subtotal,
                              // style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor),
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.8),
                              )),
                          Text(
                              PriceTools.getCurrencyFormatted(
                                  cartModel.getTotal(), currencyRate,
                                  currency: cartModel.currency)!,
                              // style: TextStyle(
                              //   fontSize: 20,
                              //   color: Theme.of(context).accentColor,
                              //   fontWeight: FontWeight.w600,
                              //   decoration: TextDecoration.underline,
                              // ),
                              style:
                                  const TextStyle(fontSize: 14, color: kGrey400))
                        ],
                      ),
                    ),
                  ),
*/
                  const SizedBox(height: 15),
                  order_status == ''
                      ? Container()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: kColorSpiderRed.withOpacity(0.85),
                            padding: const EdgeInsets.only(
                                right: 12, bottom: 0, top: 18, left: 12),
                            child: Text(order_status,

                                // style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    // color: Theme.of(context).accentColor.withOpacity(0.8),
                                    color: Theme.of(context).backgroundColor
                                    // .withOpacity(0.8),
                                    )),
                          ),
                        ),

/*            if (kPaymentConfig['EnableShipping'] ||
                  kPaymentConfig['EnableAddress'] ||
                  (kPaymentConfig['EnableReview'] ?? true))
                Center(
                  child: TextButton(
                    onPressed: () {
                      isPaying ? showSnackbar : widget.onBack!();
                    },
                    child: Text(
                      (kPaymentConfig['EnableReview'] ?? true)
                          ? S.of(context).goBackToReview
                          : kPaymentConfig['EnableShipping']
                              ? S.of(context).goBackToShipping
                              : S.of(context).goBackToAddress,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 15,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                )*/
                ],
              )),
        ),
        showCheckoutLoading
            ? Center(child: kLoadingWidget(context))
            : Container(),
      ],
    );
  }


}
