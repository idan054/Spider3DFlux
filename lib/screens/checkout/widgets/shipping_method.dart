import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fstore/models/payment_method_model.dart';
import 'package:fstore/models/tax_model.dart';
import 'package:fstore/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../../common/config.dart' show kPaymentConfig, kLoadingWidget;
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/cart/cart_model.dart';
import '../../../models/shipping_method_model.dart';
import '../../../services/index.dart';

class ShippingMethods extends StatefulWidget {
  final Function? onBack;
  final Function? onNext;

  ShippingMethods({this.onBack, this.onNext});

  @override
  _ShippingMethodsState createState() => _ShippingMethodsState();
}


int? selectedShippingIndex; // to set radio default
class _ShippingMethodsState extends State<ShippingMethods> {
  // int? selectedIndex = 0; // right for 26.9.21, 0 means the "29₪ 2-3 day delivery" is default

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero,
      () async {
        final shippingMethod =
            Provider.of<CartModel>(context, listen: false).shippingMethod;

        final shippingMethods =
            Provider.of<ShippingMethodModel>(context, listen: false)
                .shippingMethods;
        if (shippingMethods != null &&
            shippingMethods.isNotEmpty &&
            shippingMethod != null) {
          final index = shippingMethods
              .indexWhere((element) => element.id == shippingMethod.id);
        }

        Services().widget.loadShippingMethods(
            context, Provider.of<CartModel>(context, listen: false), false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shippingMethodModel = Provider.of<ShippingMethodModel>(context);
    final currency = Provider.of<CartModel>(context).currency;
    final currencyRates = Provider.of<CartModel>(context).currencyRates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // const SizedBox(height: 20),
        ListenableProvider.value(
          value: shippingMethodModel,
          child: Consumer<ShippingMethodModel>(
            builder: (context, model, child) {
              if (model.isLoading) {
                return Container(height: 100, child: kLoadingWidget(context));
              }

              if (model.message != null) {
                return Container(
                  height: 100,
                  child: Center(
                      child: Text(model.message!,
                          style: const TextStyle(color: kErrorRed))),
                );
              }

              return Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      // S.of(context).shippingMethod,
                      'בחר מבין ${model.shippingMethods!.length.toString()} שיטות המשלוח ',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < model.shippingMethods!.length; i++)
                    Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: i == selectedShippingIndex
                                ? Theme.of(context).primaryColorLight
                                : Colors.transparent,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                      fontSize: 14, color: kGrey400),
                                ),
                                Radio(
                                  activeColor: kColorSpiderRed,
                                  focusColor: kColorSpiderRed,
                                  value: i,
                                  groupValue: selectedShippingIndex,
                                  onChanged: (dynamic i) async {
                                    setState(() {
                                      selectedShippingIndex = i;
                                    });

                                    if (shippingMethodModel
                                            .shippingMethods?.isNotEmpty ??
                                        false) {
                                      Provider.of<CartModel>(context, listen: false).setShippingMethod(shippingMethodModel.shippingMethods![selectedShippingIndex!]);

                                      await Future.delayed(Duration.zero, () async {
                                        final cartModel =
                                            Provider.of<CartModel>(context,
                                                listen: false);
                                        final userModel =
                                            Provider.of<UserModel>(context,
                                                listen: false);
                                        await Provider.of<PaymentMethodModel>(context,
                                                listen: false)
                                            .getPaymentMethods(
                                                cartModel: cartModel,
                                                shippingMethod:
                                                    cartModel.shippingMethod,
                                                token: userModel.user != null
                                                    ? userModel.user!.cookie
                                                    : null);
                                      });

                                      // Navigator.of(context).pop();

                                      // final review_screen_scroll_controller =
                                      //     ScrollController();
                                      // Timer( const Duration(seconds: 1),
                                      //   () => review_screen_scroll_controller
                                      //       .jumpTo(review_screen_scroll_controller.position.maxScrollExtent),);

                                      widget.onNext!();
                                      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: Checkout()));

                                    }
                                  },
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  width: 150,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Services()
                                          .widget
                                          .renderShippingPaymentTitle(context,
                                              model.shippingMethods![i].title!),
                                      const SizedBox(height: 5),
/*                                      if (model.shippingMethods![i].cost! >
                                              0.0 ||
                                          !isNotBlank(model
                                              .shippingMethods![i].classCost))
                                        Text(
                                          PriceTools.getCurrencyFormatted(
                                              model.shippingMethods![i].cost,
                                              currencyRates,
                                              currency: currency)!,
                                          style: const TextStyle(
                                              fontSize: 14, color: kGrey400),
                                        ),
                                      if (model.shippingMethods![i].cost ==
                                              0.0 &&
                                          isNotBlank(model
                                              .shippingMethods![i].classCost))
                                        Text(
                                          model.shippingMethods![i].classCost!,
                                          style: const TextStyle(
                                              fontSize: 14, color: kGrey400),
                                        )*/
                                    ],
                                  ),
                                ),
                                if (model.shippingMethods![i].cost! > 0.0 ||
                                    !isNotBlank(
                                        model.shippingMethods![i].classCost))
                                  Container(
                                    // color: Colors.green,
                                    width: 30,
                                    // height: 20,
                                    child: Text(
                                      PriceTools.getCurrencyFormatted(
                                          model.shippingMethods![i].cost,
                                          currencyRates,
                                          currency: currency)!,
                                      style: const TextStyle(
                                          fontSize: 14, color: kGrey400),
                                    ),
                                  ),
                                if (model.shippingMethods![i].cost == 0.0 &&
                                    isNotBlank(
                                        model.shippingMethods![i].classCost))
                                  Container(
                                    // color: Colors.green,
                                    width: 30,
                                    // height: 20,
                                    child: Text(
                                      model.shippingMethods![i].classCost!,
                                      style: const TextStyle(
                                          fontSize: 14, color: kGrey400),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        i < model.shippingMethods!.length - 1
                            ? const Divider(height: 1)
                            : Container(),
                      ],
                    )
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Visibility(
          visible: false,
          child: Row(
            children: [
              Expanded(
                child: ButtonTheme(
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      onPrimary: Colors.white,
                      primary: Theme.of(context).primaryColor,
                    ),
                    onPressed:
                        /*() {
                      if (shippingMethodModel.shippingMethods?.isNotEmpty ??
                          false) {
                        Provider.of<CartModel>(context, listen: false)
                            .setShippingMethod(shippingMethodModel
                            .shippingMethods![selectedIndex!]);
                        // widget.onNext!();
                      }
                    },*/
                        () {
                      if (shippingMethodModel.shippingMethods?.isNotEmpty ??
                          false) {
                        Provider.of<CartModel>(context, listen: false)
                            .setShippingMethod(shippingMethodModel
                                .shippingMethods![selectedShippingIndex!]);

                        Future.delayed(Duration.zero, () {
                          final cartModel =
                              Provider.of<CartModel>(context, listen: false);
                          final userModel =
                              Provider.of<UserModel>(context, listen: false);
                          Provider.of<PaymentMethodModel>(context,
                                  listen: false)
                              .getPaymentMethods(
                                  cartModel: cartModel,
                                  shippingMethod: cartModel.shippingMethod,
                                  token: userModel.user != null
                                      ? userModel.user!.cookie
                                      : null);

                          if (kPaymentConfig['EnableReview'] != true) {
                            Provider.of<TaxModel>(context, listen: false)
                                .getTaxes(
                                    Provider.of<CartModel>(context,
                                        listen: false), (taxesTotal, taxes) {
                              Provider.of<CartModel>(context, listen: false)
                                  .taxesTotal = taxesTotal;
                              Provider.of<CartModel>(context, listen: false)
                                  .taxes = taxes;
                              setState(() {});
                            });
                          }
                        });

                        Navigator.of(context).pop();
                        // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: DetailScreen()));

                        // widget.onNext!();
                      }
                    },
                    // child: Text(((kPaymentConfig['EnableReview'] ?? true)
                    //.         ? S.of(context).continueToReview
                    //         : S.of(context).continueToPayment)
                    //     .toUpperCase()),
                    child: const Text('שמור וחזור לקופה'),
                  ),
                ),
              ),
            ],
          ),
        ),

/*        if (kPaymentConfig['EnableAddress'])
          Center(
            child: TextButton(
              onPressed: () {
                widget.onBack!();
              },
              child: Text(
                S.of(context).goBackToAddress,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 15,
                    color: kGrey400),
              ),
            ),
          )*/
      ],
    );
  }
}

// Route myTransition() {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => ShippingAddress(),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       const begin = Offset(0.0, 1.0);
//       const end = Offset.zero;
//       const curve = Curves.ease;
//
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//
//       return SlideTransition(
//         position: animation.drive(tween),
//         child: child,
//       );
//     },
//   );
// }
