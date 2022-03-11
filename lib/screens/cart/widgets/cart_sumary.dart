import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show AppModel, CartModel, Coupons, Discount;
import '../../../services/index.dart';
import 'coupon_list.dart';

class ShoppingCartSummary extends StatefulWidget {
  ShoppingCartSummary({this.onApplyCoupon});

  final Function? onApplyCoupon;

  @override
  _ShoppingCartSummaryState createState() => _ShoppingCartSummaryState();
}

class _ShoppingCartSummaryState extends State<ShoppingCartSummary> {
  final services = Services();
  Coupons? coupons;
  bool _enable = true;
  bool _loading = false;
  Map<String, dynamic>? defaultCurrency = kAdvanceConfig['DefaultCurrency'];

  CartModel get model => Provider.of<CartModel>(context, listen: false);

  @override
  void initState() {
    super.initState();
    if (model.couponObj != null && model.couponObj!.amount! > 0) {
      _enable = false;
    }
    getCoupon();
  }

  Future<void> getCoupon() async {
    try {
      coupons = await services.api.getCoupons();
    } catch (e) {
//      print(e.toString());
    }
  }

  void showError(String message) {
    setState(() => _loading = false);
    final snackBar = SnackBar(
      // padding: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.only(bottom: 5),
      // content: Text(S.of(context).warning(message)),
      content: const Text('סליחה, הקופון נגמר או שאינו מתאים להזמנה'),
      duration: const Duration(seconds: 7),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {},
      ),
    );
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(snackBar);
  }

  /// Check coupon code
  void checkCoupon(String couponCode) {
    if (couponCode.isEmpty) {
      showError(S.of(context).pleaseFillCode);
      return;
    }

    setState(() => _loading = true);

    Services().widget.applyCoupon(
      context,
      coupons: coupons,
      code: couponCode,
      success: (Discount discount) async {
        await model.updateDiscount(discount: discount);
        setState(() {
          _enable = false;
          _loading = false;
        });
      },
      error: showError,
    );
  }

  Future<void> removeCoupon() async {
    await Services().widget.removeCoupon(context);
    setState(() {
      _enable = true;
      model.resetCoupon();
      model.discountAmount = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final smallAmountStyle = TextStyle(color: Theme.of(context).accentColor);
    final largeAmountStyle =
        TextStyle(color: Theme.of(context).accentColor, fontSize: 20);
    final formatter = NumberFormat.currency(
        locale: 'en',
        symbol: defaultCurrency!['symbol'],
        decimalDigits: defaultCurrency!['decimalDigits']);
    final savedCoupon = Provider.of<CartModel>(context).savedCoupon;
    final couponController = TextEditingController(text: savedCoupon ?? '');

    var couponMsg = S.of(context).couponMsgSuccess;
    if (model.couponObj != null) {
      if (model.couponObj!.discountType == 'percent') {
        couponMsg += '${model.couponObj!.amount}%';
      } else {
        couponMsg += ' - ${formatter.format(model.couponObj!.amount)}';
      }
    }
    final screenSize = MediaQuery.of(context).size;
    final totalPrice = PriceTools.getCurrencyFormatted(
        model.getTotal()! - model.getShippingCost()!, currencyRate,
        currency: currency);

    return Container(
      width: screenSize.width,
      child: Container(
        width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (kAdvanceConfig['EnableCouponCode'] ?? true)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                        decoration: _enable
                            ? BoxDecoration(
                                color: Theme.of(context).backgroundColor)
                            : const BoxDecoration(color: Color(0xFFF1F2F3)),
                        child: GestureDetector(
                          onTap: (kAdvanceConfig['ShowCouponList'] ?? false)
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      fullscreenDialog: true,
                                      builder: (context) => CouponList(
                                        isFromCart: true,
                                        coupons: coupons,
                                        onSelect: (String couponCode) {
                                          setState(() {
                                            // couponController.text = '${couponCode}App';
                                            couponController.text =
                                                '$couponCode';
                                          });
                                          print(
                                              'couponController ${couponController.text}');
                                          checkCoupon(couponController.text);
                                        },
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: AbsorbPointer(
                            absorbing:
                                (kAdvanceConfig['ShowCouponList'] ?? false),
                            child: TextField(
                              controller: couponController,
                              enabled: _enable && !_loading,
                              decoration: InputDecoration(
                                  prefixIcon:
                                      (kAdvanceConfig['ShowCouponList'] ??
                                              false)
                                          ? Icon(
                                              CupertinoIcons.search,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            )
                                          : null,
                                  labelText: _enable
                                      ? S.of(context).couponCode
                                      : model.couponObj!.code,
                                  //hintStyle: TextStyle(color: _enable ? Colors.grey : Colors.black),
                                  contentPadding: const EdgeInsets.all(2)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        primary: Theme.of(context).primaryColorLight,
                        onPrimary: Theme.of(context).primaryColor,
                      ),
                      label: Text(_loading || model.calculatingDiscount
                          ? S.of(context).loading
                          : _enable
                              ? S.of(context).apply
                              : S.of(context).remove),
                      icon: const Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        size: 18,
                      ),
                      onPressed: !model.calculatingDiscount
                          ? () {
                              if (_enable) {
                                checkCoupon(couponController.text);
                              } else {
                                removeCoupon();
                              }
                            }
                          : null,
                    )
                  ],
                ),
              ),
            _enable
                ? Container()
                : Padding(
                    padding:
                        const EdgeInsets.only(left: 40, right: 40, bottom: 15),
                    child: Text(
                      couponMsg,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Container(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColorLight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 15.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(S.of(context).products,
                                style: smallAmountStyle),
                          ),
                          Text(
                            'x${model.totalCartQuantity}',
                            style: smallAmountStyle,
                          ),
                        ],
                      ),
                      if (model.rewardTotal > 0) const SizedBox(height: 10),
                      if (model.rewardTotal > 0)
                        Row(
                          children: [
                            Expanded(
                              child: Text(S.of(context).cartDiscount,
                                  style: smallAmountStyle),
                            ),
                            Text(
                              PriceTools.getCurrencyFormatted(
                                  model.rewardTotal, currencyRate,
                                  currency: currency)!,
                              style: smallAmountStyle,
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text('${S.of(context).total}:',
                                style: largeAmountStyle),
                          ),
                          model.calculatingDiscount
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : Text(
                                  totalPrice!,
                                  style: largeAmountStyle,
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
/*            Center(
              child: Text(
                'בקנייה זו תרוויח ${totalPrice.toString().replaceAll('.0', '').replaceAll('₪', '')} ספיידרס',
                style: TextStyle(
                  fontSize: 15,
                  //    fontWeight: FontWeight.w600,
                  color: Theme.of(context).accentColor.withOpacity(0.75),
                ),
              ),
            ),
            SpidersPointScreen(
              isFullPage: false,
            )*/
          ],
        ),
      ),
    );
  }
}
