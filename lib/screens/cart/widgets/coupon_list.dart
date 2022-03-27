import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/widgets/coupon_card.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/coupon.dart';
import '../../../models/index.dart' show AppModel, UserModel;
import '../../../services/index.dart';
import '../../base_screen.dart';

class CouponList extends StatefulWidget {
  final String? couponCode;
  final Coupons? coupons;
  final Function? onSelect;
  final bool isFromCart;

  const CouponList({
    Key? key,
    this.couponCode,
    this.coupons,
    this.onSelect,
    this.isFromCart = false,
  }) : super(key: key);

  @override
  _CouponListState createState() => _CouponListState();
}

class _CouponListState extends BaseScreen<CouponList> {
  final services = Services();
  // final TextEditingController _couponTextController = TextEditingController();
  String couponText = "";

  final Map<String?, Coupon> _couponsMap = {};

  List<Coupon> coupons = [];
  String? email;
  bool isFetching = false;
  // int currentPage = 1;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    if (widget.couponCode != null) {
      setState(() {
        couponText = widget.couponCode!;
      });
    }

    email = Provider.of<UserModel>(context, listen: false).user?.email;
    await _displayCoupons(context);

    /// Fetch new coupons.
    setState(() {
      isFetching = true;
    });
    final cachedCoupons = widget.coupons ?? await services.api.getCoupons();
    cachedCoupons!.coupons.forEach((Coupon coupon) {
      _couponsMap[coupon.id] = coupon;
    });
    await _displayCoupons(context);
    setState(() {
      isFetching = false;
    });
  }

  Future<void> _displayCoupons(BuildContext context) async {
    coupons.clear();
    coupons.addAll(List.from(_couponsMap.values));

    final bool showAllCoupons = kAdvanceConfig['ShowAllCoupons'] ?? false;
    final bool showExpiredCoupons =
        kAdvanceConfig['ShowExpiredCoupons'] ?? false;

    // final searchQuery = _couponTextController.text.toLowerCase();
    final searchQuery = '${couponText}App'.toLowerCase(); // My

    // printLog("coupons list length is ${coupons.length}");

    coupons.retainWhere((c) {
      var shouldKeep = true;

      /// Hide expired coupons
      if (!showExpiredCoupons && c.dateExpires != null) {
        shouldKeep &= c.dateExpires!.isAfter(DateTime.now());
      }

      /// Search for coupons using code & description
      /// Users can search for any coupons by entering
      /// any part of code or description when showAllCoupons is true.
      // if (showAllCoupons && searchQuery.isNotEmpty) {
      if (searchQuery.isNotEmpty) {
        // print('KOLOLO A');
        shouldKeep &= ('${c.code}'.toLowerCase().contains(searchQuery) ||
            '${c.description ?? ''}'.toLowerCase().contains(searchQuery));
      }

      /// Search for coupons using exact code.
      /// Users can search for hidden coupons by entering
      /// exact code when showAllCoupons is false.
      // if (!showAllCoupons && searchQuery.isNotEmpty) {
      if (searchQuery.isNotEmpty) {
        // print('KOLOLO B');
        shouldKeep &= '${c.code}'.toLowerCase() == searchQuery;
      }

/*      /// Show only coupons which is restricted to user.
      // if (!showAllCoupons && searchQuery.isEmpty) {
      if (searchQuery.isEmpty) {
        print('KOLOLO C');
        shouldKeep &= c.emailRestrictions.contains(email);
      }

      /// Hide coupons which is restricted to other users.
      // if (showAllCoupons &&
      if (
          searchQuery.isEmpty &&
          c.emailRestrictions.isNotEmpty) {
        print('KOLOLO D');
        shouldKeep &= c.emailRestrictions.contains(email);
      }*/

      return shouldKeep;
    });

    // print("RETAINED COUPONS: ${coupons.map((c) => c.code).toList()}");
    // printLog("retained coupons list length is ${coupons.length}");

    // if (coupons.isEmpty) {
    //   invalidCoupon(context);
    // }

    // _coupons.sort((a, b) => b.emailRestrictions.contains(email) ? 0 : -1);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final model = Provider.of<AppModel>(context);

    return Scaffold(
      backgroundColor: isDarkTheme ? theme.backgroundColor : theme.cardColor,
      appBar: AppBar(
        backgroundColor: isDarkTheme ? theme.backgroundColor : theme.cardColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 22,
          ),
        ),
        titleSpacing: 0.0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.only(right: 24, left: 24.0),
          margin: const EdgeInsets.only(left: 10.0),
          child: TextField(
            onChanged: (s) async {
              // printLog("got vlaue of coupon changed $s");
              couponText = s;
              await myCouponRefresher(context);
            },
            // controller: _couponTextController,
            onSubmitted: (_) async {
              // printLog("submitting value ${couponText} ${coupons.length}");
              await myCouponRefresher(context, onSubmit: true);

            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              fillColor: Theme.of(context).accentColor,
              border: InputBorder.none,
              hintText: S.of(context).couponCode,
              focusColor: Theme.of(context).accentColor,
              suffixIcon: IconButton(
                onPressed: () async {
                  couponText = "";
                  await _displayCoupons(context);
                },
                icon: Icon(
                  Icons.cancel,
                  color: Theme.of(context).accentColor.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color:
                  isDarkTheme ? theme.backgroundColor : theme.primaryColorLight,
              child: (isFetching && coupons.isEmpty)
                  ? kLoadingWidget(context)
                  : SmartRefresher(
                      enablePullDown: false,
                      enablePullUp: true,
                      footer: kCustomFooter(context),
                      onLoading: () async {
                        await myCouponRefresher(context);
                      },
                      controller: refreshController,
                      child: ListView.builder(
                        itemCount: coupons.length,
                        itemBuilder: (BuildContext context, int index) {
                          final coupon = coupons[index];
                          if (coupon.code == null) {
                            return const SizedBox();
                          }
                          // if (coupons.isEmpty) {
                          //   return const SizedBox();
                          // }
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 8.0,
                            ),
                            child: CouponItem(
                              translate: CouponTrans(context),
                              getCurrencyFormatted: (data) {
                                return PriceTools.getCurrencyFormatted(
                                  data,
                                  model.currencyRate,
                                  currency: model.currency,
                                )!;
                              },
                              coupon: coupon,
                              onSelect: widget.onSelect,
                              email: email,
                              isFromCart: widget.isFromCart,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> myCouponRefresher(context, {bool onSubmit = false}) async {
    setState(() {
      isFetching = true;
    });
    // printLog("coupon value ${couponText}");
    final count = _couponsMap.length;
    // currentPage++;
    await services.api.getCoupons()!.then((Coupons coupons) {
      coupons.coupons.forEach((Coupon coupon) {
        _couponsMap[coupon.id] = coupon;
      });
      final newCount = _couponsMap.length;
      if (newCount == count) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
      _displayCoupons(context);
    });
    setState(() {
      isFetching = false;
    });
    if (coupons.isEmpty && onSubmit) {
      invalidCoupon(context);
    }
  }

  invalidCoupon(context) async {
    await showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('שים לב'),
        content: Text(S.of(context).couponInvalid),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
