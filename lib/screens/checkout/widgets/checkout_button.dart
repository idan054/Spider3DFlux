
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/tools.dart';
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
import 'payment_methods.dart';

class CheckoutButton extends StatefulWidget {
  final String? text;
  final void onBack;
  final Function? onFinish;
  final Function(bool)? onLoading;

  CheckoutButton({this.onBack, this.onFinish, this.onLoading, this.text});

  // const CheckoutButton({Key? key}) : super(key: key);

  @override
  _CheckoutButtonState createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<CheckoutButton> {
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

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final paymentMethodModel = Provider.of<PaymentMethodModel>(context);
    final taxModel = Provider.of<TaxModel>(context);
    var final_checkoutButton = widget.text == 'סיים הזמנה';

    return
      Container(
      margin: const EdgeInsets.only(bottom: 20, top: 5),
      child: IgnorePointer(
        ignoring: false,
        child: FloatingActionButton.extended(
          // enableFeedback: false,
          // splashColor: Theme.of(context).primaryColorLight,
          onPressed:
              () {
            // debugger();
            // print(cartModel.user);
            //     print('XXX');
            print(cartModel.user);
                checkoutAction(cartModel, paymentMethodModel);
          },
          isExtended: true,
          // backgroundColor: Theme.of(context).primaryColor,
          backgroundColor:
          final_checkoutButton
              ?
          // Theme.of(context).primaryColor
          Colors.green
              :
          Theme.of(context).primaryColorLight,
          // foregroundColor: Colors.white,
          foregroundColor: final_checkoutButton ? Colors.white : Theme.of(context).accentColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // icon: final_checkoutButton ? const Icon(Icons.payment, size: 20) : null,
          icon: final_checkoutButton ? const Icon(Icons.done_all, size: 20) : null,
          label:
          Text(
            // 'הכנס כתובת משלוח',
            '${widget.text}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.75,
            ),
          ),
        ),
      ),
    );

/*    return ButtonTheme(
      height: 45,
      // Processrocces order button
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          onPrimary: Colors.white,
          primary: Theme.of(context).primaryColor,
        ),
        onPressed: checkoutAction,
        child: const Text(
          'עבור לתשלום מאובטח',
          // S.of(context).placeMyOrder.toUpperCase()
        ),
      ),
    );*/
  }

  void checkoutAction(cartModel, paymentMethodModel){
    // final cartModel = Provider.of<CartModel>(context);
    // final currencyRate = Provider.of<AppModel>(context).currencyRate;
    // final paymentMethodModel = Provider.of<PaymentMethodModel>(context);
    // final taxModel = Provider.of<TaxModel>(context);

    // String? note = Provider.of<CartModel>(context, listen: false).notes ?? '';
    //   if (note.isNotEmpty && note != '') {Provider.of<CartModel>(context, listen: false).setOrderNotes(note);}

    // var cartModel = Provider.of<CartModel>(context);
    var addressModel = cartModel.address;
    var shipping_details_ready = false;
    var shipping_method_ready = false;
    var payment_details_ready = false;
    var payment_method_ready = false;

    order_status = '';
    var counter = 0;
    // if(ca){

    // print('Checking Shipping details:');
    if (addressModel!.firstName == null ||
        // region checkDetails
        addressModel.firstName == '' && addressModel.city == null ||
        addressModel.city == '' && addressModel.street == null ||
        addressModel.street == '' && addressModel.phoneNumber == null ||
        addressModel.phoneNumber == '' && addressModel.email == null ||
        addressModel.email == '') {
      print('>> Some Shipping details are missing.. <<');
      setState(() {
        counter += 1;
        order_status += '${counter.toString()}. ';
        order_status += 'הכנס פרטי משלוח \n';
      });
      print('order_status');
      print(order_status);
    } else {
      print('Full addressModel.toJson()');
      print(addressModel.toJson());
      shipping_details_ready = true;
    }

    // print('Checking shipping Method:');
    if (cartModel.shippingMethod == null ||
        cartModel.shippingMethod!.title == null ||
        cartModel.shippingMethod!.title == '') {
      print('>> Select A shipping method. <<');
      setState(() {
        counter += 1;
        order_status += '${counter.toString()}. ';
        order_status += 'בחר שיטת משלוח \n';
      });
      print('order_status');
      print(order_status);
    } else {
      print('cartModel.shippingMethod');
      print(cartModel.shippingMethod.runtimeType);
      print(cartModel.shippingMethod.runtimeType);
      print(cartModel.shippingMethod!.title);
      shipping_method_ready = true;
    }

    // print('Payment details:');
    if (addressModel.cardHolderName == null ||
        addressModel.cardHolderName == '' &&
            addressModel.cardHolderId == null ||
        addressModel.cardHolderId == '' &&
            addressModel.cardExpiryDate == null ||
        addressModel.cardExpiryDate == '' &&
            addressModel.cardNumber == null ||
        addressModel.cardNumber == '' && addressModel.cardCvv == null ||
        addressModel.cardCvv == '') {
      print('>> Some Payment details are missing.. <<');
      setState(() {
        counter += 1;
        order_status += '${counter.toString()}. ';
        order_status += 'הכנס פרטי אשראי \n';
      });
      print('order_status');
      print(order_status);
    } else {
      payment_details_ready = true;
    }

    // print(cartModel.paymentMethod);
    // print('Payment Method:');
    // print(cartModel.paymentMethod!.title);

    // If Radio button Selected on screen but not on cartModel.paymentMethod
/*    if (cartModel.paymentMethod == null ||
        cartModel.paymentMethod?.title == null ||
        cartModel.paymentMethod?.title == '' &&
            selectedPaymentId != null ||
        selectedPaymentId != '') {
      print(
          'Bug Fix! radioSelectionId is $selectedPaymentId But cartModel.paymentMethod is null!');
      if (paymentMethodModel.paymentMethods.isNotEmpty) {
        try {
          final paymentMethod = paymentMethodModel.paymentMethods
              .firstWhere((item) => item.id == selectedPaymentId);
          Provider.of<CartModel>(context, listen: false)
              .setPaymentMethod(paymentMethod);
        } catch (e, s) {
          print('WoOho: $e');
          // print(s);
        }

        print('Bug Fixed:');
        print('cartModel.paymentMethod');
        print(cartModel.paymentMethod?.title);
      }
    }*/

    if (cartModel.paymentMethod == null ||
        cartModel.paymentMethod!.title == null ||
        cartModel.paymentMethod!.title == ''
        // ||
        // selectedPaymentId == null ||
        // selectedPaymentId == ''
    ) {
      print('>> Select A Payment method. <<');
      setState(() {
        counter += 1;
        order_status += '${counter.toString()}. ';
        order_status += 'בחר אמצעי תשלום \n';
      });
      print('cartModel.paymentMethod');
      print(cartModel.paymentMethod?.title);

      print('radioSelectionId');
      print(selectedPaymentId);

      print('order_status');
      print(order_status);
    } else {
      print('cartModel.paymentMethod');
      print(cartModel.paymentMethod?.title);

      payment_method_ready = true;
    }

    print('Order Notes:');
    print(cartModel.notes);

    print('selectedId:');
    print(selectedPaymentId);

    print('isPaying:');
    print(isPaying);
    // endregion checkDetails

    if (shipping_details_ready &&
        shipping_method_ready &&
        payment_details_ready &&
        payment_method_ready) {
      print('-------------\nEverything is ready!');

      // ORIGINAL PAYMENT REDIRECT
      setState(() {
        showCheckoutLoading = true;
      });

      // isPaying || selectedId == null ? showSnackbar :
      // placeOrder(paymentMethodModel, cartModel);
    } else {
      print('-------------\nNot Everything is ready..');
      final snackBar = SnackBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        behavior: SnackBarBehavior.floating,
        // padding: const EdgeInsets.only(bottom: 15),
        // backgroundColor: kColorSpiderRed.withOpacity(0.80),
        backgroundColor: Colors.red[500]?.withOpacity(0.85),
        padding: const EdgeInsets.all(10),
        // content: Text(S.of(context).warning(message)),
        content: Text(
          '$order_status',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),

        ),
        duration: Duration(seconds: order_status.length < 35 ? 4 : 6),
        action: SnackBarAction(
          label: S.of(context).close,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      // ignore: deprecated_member_use
      Scaffold.of(context).showSnackBar(snackBar);
    }

    // }

    // isPaying || selectedId == null
    //     ? showSnackbar
    //     : placeOrder(paymentMethodModel, cartModel);

  }

  void showSnackbar() {
    Tools.showSnackBar(
        Scaffold.of(context), S.of(context).orderStatusProcessing);
  }
/*
  void placeOrder(
      PaymentMethodModel paymentMethodModel,
      CartModel cartModel) {
    widget.onLoading!(true);
    isPaying = true;
    if (paymentMethodModel.paymentMethods.isNotEmpty) {
      final paymentMethod = paymentMethodModel.paymentMethods
          // .firstWhere((item) => item.id == selectedPaymentId);
          .firstWhere((item) => item.id == cartModel.paymentMethod?.id);
      debugger();
      print(paymentMethod.title);
      print('X');
      print('X');

      Provider.of<CartModel>(context, listen: false).setPaymentMethod(paymentMethod);

      /// Use Credit card. For Shopify only.
      if ((kPaymentConfig['EnableCreditCard'] ?? false) &&
          serverConfig['type'] == 'shopify') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreditCardPayment(
              onFinish: (number) {
                if (number == null) {
                  widget.onLoading!(false);
                  isPaying = false;
                  return;
                } else {
                  createOrder(paid: true).then((value) {
                    widget.onLoading!(false);
                    isPaying = false;
                  });
                }
              },
            ),
          ),
        );

        return;
      }


      /// PayPal Payment
      if (isNotBlank(PaypalConfig['paymentMethodId']) &&
          paymentMethod.id!.contains(PaypalConfig['paymentMethodId']) &&
          PaypalConfig['enabled'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaypalPayment(
              onFinish: (number) {
                if (number == null) {
                  widget.onLoading!(false);
                  isPaying = false;
                  return;
                } else {
                  createOrder(paid: true).then((value) {
                    widget.onLoading!(false);
                    isPaying = false;
                  });
                }
              },
            ),
          ),
        );
        return;
      }

      /// Use WebView Payment per frameworks
      Services().widget.placeOrder(
        context,
        cartModel: cartModel,
        onLoading: widget.onLoading,
        paymentMethod: paymentMethod,
        success: (Order? order) async {
          if (order != null) {
            // widget.onLoading;
            for (var item in order.lineItems) {
              var product = cartModel.getProductById(item.productId!);
              if (product?.bookingInfo != null) {
                product!.bookingInfo!.idOrder = order.id;
                var booking = await createBooking(product.bookingInfo)!;

                Tools.showSnackBar(Scaffold.of(context),
                    booking ? 'Booking success!' : 'Booking error!');
              }
            }
            widget.onFinish!(order);
          }
          widget.onLoading!(false);
          isPaying = false;
        },
        error: (message) {
          widget.onLoading!(false);
          if (message != null) {
            Tools.showSnackBar(Scaffold.of(context), message);
          }

          isPaying = false;
        },
      );
    }
  }
  //  I think its history saver..
  Future<bool>? createBooking(BookingModel? bookingInfo) async {
    return Services().api.createBooking(bookingInfo)!;
  }

  Future<void> createOrder( // # 3
      {paid = false, bacs = false, cod = false, transactionId = ''}) async {
    widget.onLoading!(true);
    await Services().widget.createOrder(
      context,
      paid: paid,
      cod: cod,
      bacs: bacs,
      transactionId: transactionId,
      onLoading: widget.onLoading,
      success: (Order order) async {
        widget.onFinish!(order);
      },
      error: (message) {
        Tools.showSnackBar(Scaffold.of(context), message);
      },
    );
    widget.onLoading!(false);
  }*/
}
