import 'dart:async';

import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/order.dart';
import '../../../models/index.dart' show AppModel;
import '../../../services/index.dart';
import '../../../widgets/common/box_comment.dart';
import '../../base_screen.dart';
import '../models/order_history_detail_model.dart';
import 'widgets/product_order_item.dart';

class OrderHistoryDetailScreen extends StatefulWidget {
  OrderHistoryDetailScreen();

  @override
  _OrderHistoryDetailScreenState createState() =>
      _OrderHistoryDetailScreenState();
}

class _OrderHistoryDetailScreenState
    extends BaseScreen<OrderHistoryDetailScreen> {
  OrderHistoryDetailModel get orderHistoryModel =>
      Provider.of<OrderHistoryDetailModel>(context, listen: false);

  @override
  void afterFirstLayout(BuildContext context) {
    super.afterFirstLayout(context);
    orderHistoryModel.getTracking();
    orderHistoryModel.getOrderNote();
  }

  void cancelOrder() {
    orderHistoryModel.cancelOrder();
  }

  void _onNavigate(context, model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebviewScaffold(
          url: "${afterShip['tracking_url']}/${model.tracking}",
          appBar: AppBar(
            brightness: Theme.of(context).brightness,
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.arrow_back_ios),
            ),
            title: Text(S.of(context).trackingPage),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyRate = Provider.of<AppModel>(context).currencyRate;

    return Consumer<OrderHistoryDetailModel>(builder: (context, model, child) {
      final order = model.order;
      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Text(
            S.of(context).orderNo + ' #${order.number}',
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...List.generate(
                order.lineItems.length,
                (index) => ProductOrderItem(orderId: order.id!, orderStatus: order.status!, product: order.lineItems[index]),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          S.of(context).subtotal,
                          style:
                              Theme.of(context).textTheme.subtitle1!.copyWith(
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                        Text(
                          PriceTools.getCurrencyFormatted(
                              order.lineItems.fold(
                                  0,
                                  (dynamic sum, e) =>
                                      sum + double.parse(e.total!)),
                              currencyRate)!,
                          style:
                              Theme.of(context).textTheme.subtitle1!.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    (order.shippingMethodTitle != null &&
                            kPaymentConfig['EnableShipping'])
                        ? Row(
                            children: <Widget>[
                              Text(S.of(context).shippingMethod,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                        fontWeight: FontWeight.w400,
                                      )),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  order.shippingMethodTitle!,
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              )
                            ],
                          )
                        : Container(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          S.of(context).totalTax,
                          style:
                              Theme.of(context).textTheme.subtitle1!.copyWith(
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                        Text(
                          PriceTools.getCurrencyFormatted(
                              order.totalTax, currencyRate)!,
                          style:
                              Theme.of(context).textTheme.subtitle1!.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        )
                      ],
                    ),
                    Divider(
                      height: 20,
                      color: Theme.of(context).accentColor,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          S.of(context).total,
                          style:
                              Theme.of(context).textTheme.subtitle1!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                        Text(
                          PriceTools.getCurrencyFormatted(
                              order.total, currencyRate)!,
                          style:
                              Theme.of(context).textTheme.subtitle1!.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              if (model.tracking != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: GestureDetector(
                    onTap: () => _onNavigate(context, model),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: <Widget>[
                          Text('${S.of(context).trackingNumberIs} '),
                          Text(
                            model.tracking!,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              Services().widget.renderOrderTimelineTracking(context, order),
              const SizedBox(height: 20),

              /// Render the Cancel and Refund
              if (kPaymentConfig['EnableRefundCancel'])
                Services()
                    .widget
                    .renderButtons(context, order, cancelOrder, refundOrder),

              const SizedBox(height: 20),

              if (order.billing != null) ...[
                Text(S.of(context).shippingAddress,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  ((order.billing!.apartment?.isEmpty ?? true)
                          ? ''
                          : '${order.billing!.apartment} ') +
                      ((order.billing!.block?.isEmpty ?? true)
                          ? ''
                          : '${(order.billing!.apartment?.isEmpty ?? true) ? '' : '- '} ${order.billing!.block}, ') +
                      order.billing!.street! +
                      ', ' +
                      order.billing!.city! +
                      ', ' +
                      getCountryName(order.billing!.country),
                ),
              ],
              if (order.status == OrderStatus.processing &&
                  kPaymentConfig['EnableRefundCancel'])
                Column(
                  children: <Widget>[
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ButtonTheme(
                            height: 45,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  onPrimary: Colors.white,
                                  primary: HexColor('#056C99'),
                                ),
                                onPressed: refundOrder,
                                child: Text(
                                    S.of(context).refundRequest.toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700))),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              if (kPaymentConfig['ShowOrderNotes'] ?? true)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Builder(
                    builder: (context) {
                      final listOrderNote = model.listOrderNote;
                      if (listOrderNote?.isEmpty ?? true) {
                        return const SizedBox();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            S.of(context).orderNotes,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(
                                listOrderNote!.length,
                                (index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        CustomPaint(
                                          painter: BoxComment(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  top: 15,
                                                  bottom: 25),
                                              child: HtmlWidget(
                                                listOrderNote[index].note!,
                                                textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    height: 1.2),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              formatTime(DateTime.parse(
                                                  listOrderNote[index]
                                                      .dateCreated!)),
                                              style: const TextStyle(fontSize: 13),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

              const SizedBox(height: 50)
            ],
          ),
        ),
      );
    });
  }

  String getCountryName(country) {
    try {
      return CountryPickerUtils.getCountryByIsoCode(country).name;
    } catch (err) {
      return country;
    }
  }

  Future<void> refundOrder() async {
    _showLoading();
    try {
      await orderHistoryModel.createRefund();
      _hideLoading();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).refundOrderSuccess)));
    } catch (err) {
      _hideLoading();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).refundOrderFailed)));
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                kLoadingWidget(context),
                // const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(S.of(context).cancel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }

  String formatTime(DateTime time) {
    return DateFormat('dd/MM/yyyy, HH:mm').format(time);
  }
}
