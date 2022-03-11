import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart' show AutoHideKeyboard, printLog;
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../menu/index.dart' show MainTabControlDelegate;
import '../../models/index.dart' show AppModel, CartModel, Product, UserModel;
import '../../services/index.dart';
import '../../widgets/product/cart_item.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import 'widgets/cart_sumary.dart';
import 'widgets/empty_cart.dart';
import 'widgets/wishlist.dart';

class MyCart extends StatefulWidget {
  final PageController? controller;
  final bool? isModal;
  final bool? isBuyNow;

  MyCart({this.controller, this.isModal, this.isBuyNow = false});

  @override
  _MyCartState createState() => _MyCartState();
}

List<Widget> createShoppingCartRows(CartModel model, BuildContext context) {
  return model.productsInCart.keys.map(
        (key) {
      var productId = Product.cleanProductID(key);
      var product = model.getProductById(productId);

      return ShoppingCartRow(
        my_is_review_screen:
        false, // My adjustments for review_screen.dart only
        product: product!,
        addonsOptions: model.productAddonsOptionsInCart[key],
        variation: model.getProductVariationById(key),
        quantity: model.productsInCart[key],
        options: model.productsMetaDataInCart[key],
        onRemove: () {
          model.removeItemFromCart(key);
        },
        onChangeQuantity: (val) {
          var message = Provider.of<CartModel>(context, listen: false)
              .updateQuantity(product, key, val, context: context);
          if (message.isNotEmpty) {
            final snackBar = SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 1),
            );
            Future.delayed(
                const Duration(milliseconds: 300),
                // ignore: deprecated_member_use
                    () => Scaffold.of(context).showSnackBar(snackBar));
          }
        },
      );
    },
  ).toList();
}


class _MyCartState extends State<MyCart> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  String errMsg = '';


  void _loginWithResult(BuildContext context) async {
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => LoginScreen(
    //       fromCart: true,
    //     ),
    //     fullscreenDialog: kIsWeb,
    //   ),
    // );
    await Navigator.of(context)
        .pushNamed(RouteList.login, arguments: true)
        .then((value) {
      final user = Provider.of<UserModel>(context, listen: false).user;
      if (user != null && user.name != null) {
        Tools.showSnackBar(
            Scaffold.of(context), S.of(context).welcome + ' ${user.name} !');
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    printLog('[Cart] build');

    final localTheme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    var layoutType = Provider.of<AppModel>(context).productDetailLayout;
    var cartModel = Provider.of<CartModel>(context);
    var userModel = Provider.of<UserModel>(context);
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final canPop = parentRoute?.canPop ?? false;

    print('userModel.loggedIn');
    print(userModel.loggedIn);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: cartModel.calculatingDiscount
              ? null
              : () {
                  if(cartModel.totalCartQuantity > 0) {
                      if (userModel.loggedIn) {
                        MainTabControlDelegate.getInstance().changeTab('cart');
                        onCheckout(cartModel);
                     } else {
                        Navigator.of(context).pushNamed(RouteList.login); }
                  } else {
                  MainTabControlDelegate.getInstance().changeTab('home');
                 }

                /*                // MainTabControlDelegate.getInstance().changeTab('checkout');
                    // return;

                  // cartModel.user?.email == null
                  // FirebaseAuth.instance.currentUser?.uid == null
                  // Navigator.of(context).pushReplacementNamed(rou)*/

                },
          isExtended: true,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          icon: const Icon(Icons.payment, size: 20),
          label: cartModel.totalCartQuantity > 0
              ? (isLoading
                  ? Text(S.of(context).loading.toUpperCase())
                  : Text(S.of(context).checkout.toUpperCase()))
              : Text(
                  S.of(context).startShopping.toUpperCase(),
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            leading: widget.isModal == true
                ? CloseButton(
                    onPressed: () {
                      if (widget.isBuyNow!) {
                        Navigator.of(context).pop();
                        return;
                      }

                      if (Navigator.of(context).canPop() &&
                          layoutType != 'simpleType') {
                        Navigator.of(context).pop();
                      } else {
                        ExpandingBottomSheet.of(context, isNullOk: true)
                            ?.close();
                      }
                    },
                  )
                : canPop
                    ? const BackButton()
                    : const SizedBox(),
            backgroundColor: Theme.of(context).backgroundColor,
            largeTitle: Text(
              S.of(context).myCart,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer<CartModel>(
              builder: (context, model, child) {
                return AutoHideKeyboard(
                  child: Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).backgroundColor),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 80.0),
                        child: Column(
                          children: [
                            if (model.totalCartQuantity > 0)
                              Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorLight),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15.0, top: 4.0),
                                  child: Container(
                                    width: screenSize.width,
                                    child: Container(
                                      width: screenSize.width /
                                          (2 /
                                              (screenSize.height /
                                                  screenSize.width)),
                                      child: Row(
                                        // crossAxisAlignment: CrossAxisAlignment.,
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 25.0,
                                          ),
                                          Text(
                                            S.of(context).total.toUpperCase(),
                                            style: localTheme
                                                .textTheme.subtitle1!
                                                .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    // color: Theme.of(context).primaryColor,
                                                    // color: Colors.grey[600],
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                    fontSize: 14),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            '${model.totalCartQuantity} ${S.of(context).items}',
                                            style: TextStyle(
                                              // color: Theme.of(context).primaryColor,
                                              // color: Colors.grey[600],
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                left: 20,
                                              ),
                                              alignment: Alignment.centerLeft,
                                              child: TextButton(
                                                onPressed: () {
                                                  if (model.totalCartQuantity >
                                                      0) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            content: Text(S
                                                                .of(context)
                                                                .confirmClearTheCart),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(S
                                                                    .of(context)
                                                                    .keep),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  model
                                                                      .clearCart();
                                                                },
                                                                child: Text(
                                                                  S
                                                                      .of(context)
                                                                      .clear,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                  }
                                                },
                                                child: Text(
                                                  S
                                                      .of(context)
                                                      .clearCart
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: kColorSpiderRed
                                                          .withOpacity(0.70),
                                                      fontSize: 12),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (model.totalCartQuantity > 0)
                              const Divider(
                                height: 1,
                                indent: 25,
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const SizedBox(height: 16.0),
                                if (model.totalCartQuantity > 0)
                                  Column(
                                    children:
                                        createShoppingCartRows(model, context),
                                  ),
                                // FlutterLogo(),
                                if (model.totalCartQuantity > 0)
                                  ShoppingCartSummary(),
                                if (model.totalCartQuantity == 0) EmptyCart(),
                                if (errMsg.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: Text(
                                      errMsg,
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                const SizedBox(height: 4.0),
                                WishList()
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void onCheckout(CartModel model) {
    var isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    final currency = Provider.of<AppModel>(context, listen: false).currency;

    // if (isLoading) return; // Original
    if (isLoading) {
      const Center(child: Text('Loading'));
    }
    ;

    if (kCartDetail['minAllowTotalCartValue'] != null) {
      if (kCartDetail['minAllowTotalCartValue'].toString().isNotEmpty) {
        var totalValue = model.getSubTotal() ?? 0;
        var minValue = PriceTools.getCurrencyFormatted(
            kCartDetail['minAllowTotalCartValue'], currencyRate,
            currency: currency);
        if (totalValue < kCartDetail['minAllowTotalCartValue'] &&
            model.totalCartQuantity > 0) {
          showFlash(
            context: context,
            duration: const Duration(seconds: 3),
            builder: (context, controller) {
              return SafeArea(
                child: Flash(
                  borderRadius: BorderRadius.circular(3.0),
                  backgroundColor: Theme.of(context).errorColor,
                  controller: controller,
                  style: FlashStyle.grounded,
                  position: FlashPosition.top,
                  horizontalDismissDirection:
                      HorizontalDismissDirection.horizontal,
                  child: FlashBar(
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    message: Text(
                      'Total order\'s value must be at least $minValue',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            },
          );

          return;
        }
      }
    }

    if (model.totalCartQuantity == 0) {
      if (widget.isModal == true) {
        try {
          ExpandingBottomSheet.of(context)!.close();
        } catch (e) {
          Navigator.of(context).pushNamed(RouteList.dashboard);
        }
      } else {
        final modalRoute = ModalRoute.of(context);
        if (modalRoute?.canPop ?? false) {
          Navigator.of(context).pop();
          return;
        }
        MainTabControlDelegate.getInstance().tabAnimateTo(0);
      }
    } else if (isLoggedIn || kPaymentConfig['GuestCheckout'] == true) {
      doCheckoutV3();
    } else {
      _loginWithResult(context);
    }
  }

  Future<void> doCheckoutV3() async {
    showLoading();

    await Services().widget.doCheckout(
      context,
      success: () async {
        hideLoading('');
        await Provider.of<CartModel>(context, listen: false).getAddress();
        // New Checkout page V3
        await Navigator.of(context).pushNamed(RouteList.checkoutV3);
        // await widget.controller!.animateToPage(1, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
      },
      error: (message) async {
        if (message ==
            Exception('Token expired. Please logout then login again')
                .toString()) {
          setState(() {
            isLoading = false;
          });
          //logout
          final userModel = Provider.of<UserModel>(context, listen: false);
          await userModel.logout();
          Services().firebase.signOut();

          _loginWithResult(context);
        } else {
          hideLoading(message);
          Future.delayed(const Duration(seconds: 3), () {
            setState(() => errMsg = '');
          });
        }
      },
      loading: (isLoading) {
        setState(() {
          this.isLoading = isLoading;
        });
      },
    );
  }

/*  Future<void> doCheckout() async {
    showLoading();

    await Services().widget.doCheckout(
      context,
      success: () async {
        hideLoading('');
        await widget.controller!.animateToPage(1,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut);
      },
      error: (message) async {
        if (message ==
            Exception('Token expired. Please logout then login again')
                .toString()) {
          setState(() {
            isLoading = false;
          });
          //logout
          final userModel = Provider.of<UserModel>(context, listen: false);
          await userModel.logout();
          Services().firebase.signOut();

          _loginWithResult(context);
        } else {
          hideLoading(message);
          Future.delayed(const Duration(seconds: 3), () {
            setState(() => errMsg = '');
          });
        }
      },
      loading: (isLoading) {
        setState(() {
          this.isLoading = isLoading;
        });
      },
    );
  }*/

  void showLoading() {
    setState(() {
      isLoading = true;
      errMsg = '';
    });
  }

  void hideLoading(error) {
    setState(() {
      isLoading = false;
      errMsg = error;
    });
  }
}
