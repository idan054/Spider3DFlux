
import 'package:flutter/material.dart';
import 'package:fstore/menu/maintab_delegate.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../models/index.dart' show CartModel, Order;
import '../base_screen.dart';
import 'review_screen.dart';
import 'widgets/success.dart';

class Checkout extends StatefulWidget {
  final PageController? controller;
  final bool? isModal;

  Checkout({this.controller, this.isModal});

  @override
  _CheckoutState createState() => _CheckoutState();
}

Order? newOrder;
bool showCheckoutButton = false;

class _CheckoutState extends BaseScreen<Checkout> {
  int tabIndex = 0;
  bool isPayment = false;
  bool isLoading = false;

  // var getAddressDetails;

  @override
  void initState() {
/*    Future.delayed(
      Duration.zero,
      () async {
        final addressValue =
            await Provider.of<CartModel>(context, listen: false).getAddress();
        getAddressDetails = addressValue;

        print('addressValue from checkout_screen.dart:');
        print(addressValue!.firstName);
        print(addressValue.city);
        // ignore: unnecessary_null_comparison
      },
    );*/
    super.initState();
  }

  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (!kPaymentConfig['EnableAddress']) {
      setState(() {
        tabIndex = 1;
      });
      if (!kPaymentConfig['EnableShipping']) {
        setState(() {
          tabIndex = 2;
        });
        if (!kPaymentConfig['EnableReview']) {
          setState(() {
            tabIndex = 3;
            isPayment = true;
          });
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);

    String? checkout_title;
    if (cartModel.address?.phoneNumber == null ||
        cartModel.address?.street == null) {
      checkout_title = 'הכנס כתובת משלוח';
    } else if (cartModel.paymentMethod == null ||
        cartModel.shippingMethod == null) {
      checkout_title = 'בחר שיטת משלוח ותשלום';
    } else if (cartModel.address?.cardNumber == null ||
        cartModel.address?.cardCvv == null) {
      checkout_title = 'הכנס פרטי אשראי';
    } else {
      checkout_title = 'סיים הזמנה';
      showCheckoutButton = true;
    }

/*    Timer(const Duration(seconds: 5), () {
      setState(() {
        // isKeyboardOpen = !isKeyboardOpen;
        isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom==0.0;
      });
      // print('isKeyboardOpen checkout_screen $isKeyboardOpen');
    });*/

    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          /*          floatingActionButton:
          // showCheckoutButton ||  checkout_title == 'סיים הזמנה' ?
          CheckoutButton(
                  text: checkout_title,
                  onBack: () {},
                  onFinish: (order) {
                    setState(() {
                      newOrder = order;
                    });
                    Provider.of<CartModel>(context, listen: false).clearCart();
                  },
                  // onLoading: setLoading
                  onLoading: setCheckoutLoading,
                )
              // : Container()
          ,*/
          resizeToAvoidBottomInset: false,
          // To do not float above the keyboard
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          appBar: AppBar(
            title: const Text('עמוד קופה'),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // print(newOrder);
                  setState(() {
                    // my comment: while newOrder is not null > set to null (otherwise do nothing)
                    newOrder != null ? newOrder = null : null;
                  });
                  // print(newOrder);

                  // Navigator.of(context)
                  //     .push(MaterialPageRoute(builder: (_) => Checkout()));

                  // goToShippingTab(true);
                  widget.controller != null ?
                  widget.controller?.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                  ) :  MainTabControlDelegate.getInstance().changeTab('home');
                  // print(newOrder);

                  // Navigator.of(context).pop();
                }),
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: 3.0,
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: newOrder != null
                        ? OrderedSuccess(
                            order: newOrder,
                            isModal: widget.isModal,
                            controller: widget.controller,
                          )
                        : Column(
                            children: <Widget>[
                              //. !isPayment ? progressBar : Container(),
                              Expanded(
                                child: ListView(
                                  key: const Key('checkOutScreenListView'),
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  children: <Widget>[
                                    // renderContent(),

                                    ReviewScreen(
                                        // addressDetails: getAddressDetails,
                                        onBack: () {
                                      goToShippingTab(true);
                                    }, onNext: () {
                                      goToPaymentTab();
                                    }),
                                  ],
                                ),
                              )
                            ],
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
        isLoading
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white.withOpacity(0.36),
                child: kLoadingWidget(context),
              )
            : Container()
      ],
    );
  }

  /// tabIndex: 0
  void goToAddressTab([bool isGoingBack = false]) {
    if (kPaymentConfig['EnableAddress']) {
      setState(() {
        tabIndex = 0;
      });
    } else {
      if (!isGoingBack) {
        goToShippingTab(isGoingBack);
      }
    }
  }

  /// tabIndex: 1
  void goToShippingTab([bool isGoingBack = false]) {
    if (kPaymentConfig['EnableShipping']) {
      setState(() {
        tabIndex = 1;
      });
    } else {
      if (isGoingBack) {
        goToAddressTab(isGoingBack);
      } else {
        goToReviewTab(isGoingBack);
      }
    }
  }

  /// tabIndex: 2
  void goToReviewTab([bool isGoingBack = false]) {
    if (kPaymentConfig['EnableReview'] ?? true) {
      setState(() {
        tabIndex = 2;
      });
    } else {
      if (isGoingBack) {
        goToShippingTab(isGoingBack);
      } else {
        goToPaymentTab(isGoingBack);
      }
    }
  }

  /// tabIndex: 3
  void goToPaymentTab([bool isGoingBack = false]) {
    if (!isGoingBack) {
      setState(() {
        tabIndex = 3;
      });
    }
  }
}
