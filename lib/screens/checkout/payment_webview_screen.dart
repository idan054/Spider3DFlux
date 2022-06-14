// PWVS.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fstore/common/config.dart';
import 'package:fstore/frameworks/woocommerce/services/woo_commerce.dart';
import 'package:fstore/models/cart/cart_base.dart';
import 'package:fstore/screens/checkout/webview_checkout_success_screen.dart';
import 'package:provider/provider.dart';

//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/index.dart';
import '../base_screen.dart';


// void main() async {
//   var url = await iCreditGetUrl(
//       buyer_name: 'IDAN TEST',
//       city: 'Gedera test',
//       street: 'Hedera',
//       email: 'idan@test.cocom',
//       phone: '0543232761',
//       total_price: 301);
//   print(url);
//   runApp(MaterialApp(home: PaymentWebview(url: url)));
// }

class PaymentWebview extends StatefulWidget {
  final String? url;
  final Function? onFinish;
  final Function? onClose;

  PaymentWebview({this.onFinish, this.onClose, this.url});

  @override
  State<StatefulWidget> createState() {
    return PaymentWebviewState();
  }
}

class PaymentWebviewState extends BaseScreen<PaymentWebview> {
  /*
  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    initWebView();
  }

  void initWebView() {
    final flutterWebviewPlugin = FlutterWebviewPlugin();

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.contains('/order-received/')) {
        final items = url.split('/order-received/');
        if (items.length > 1) {
          final number = items[1].split('/')[0];
          widget.onFinish!(number);
          Navigator.of(context).pop();
        }
      }
      if (url.contains('checkout/success')) {
        widget.onFinish!('0');
        Navigator.of(context).pop();
      }

      // shopify url final checkout
      if (url.contains('thank_you')) {
        widget.onFinish!('0');
        Navigator.of(context).pop();
      }
    });

    // this code to hide some classes in website, change site-header class based on the website
    flutterWebviewPlugin.onStateChanged.listen((viewState) {
      if (viewState.type == WebViewState.finishLoad) {
        flutterWebviewPlugin.evalJavascript(
            'document.getElementsByClassName(\'site-header\')[0].style.display=\'none\';');
        flutterWebviewPlugin.evalJavascript(
            'document.getElementsByClassName(\'site-footer\')[0].style.display=\'none\';');
      }
    });

//    var givenJS = rootBundle.loadString('assets/extra_webview.js');
//    // ignore: missing_return
//    givenJS.then((String js) {
//      flutterWebviewPlugin.onStateChanged.listen((viewState) async {
//        if (viewState.type == WebViewState.finishLoad) {
//          await flutterWebviewPlugin.evalJavascript(js);
//        }
//      });
//    });
  }

   */

  bool isLoading = true;
  bool firstSucceedRedirect = true;
  var _controller;
  var click_checkoutButton = true;

  @override
  Widget build(BuildContext context) {
    final addressModel = Provider.of<CartModel>(context).address;

    final cartModel = Provider.of<CartModel>(context);
    print('URL is ${widget.url}');
    if (cartModel.getTotal()!.toDouble() > 1000.0) click_checkoutButton = false;
    print('click_checkoutButton is $click_checkoutButton');

    var checkoutMap = <dynamic, dynamic>{
      'url': '',
      'headers': <String, String>{}
    };

    if (widget.url != null) {
      checkoutMap['url'] = widget.url;
    } else {
      final paymentInfo = Services().widget.getPaymentUrl(context)!;
      checkoutMap['url'] = paymentInfo['url'];
      if (paymentInfo['headers'] != null) {
        checkoutMap['headers'] =
        Map<String, String>.from(paymentInfo['headers']);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('תשלום מתבצע, אנא המתן...'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.onFinish!(null);
              Provider.of<CartModel>(context, listen: false).changeBillingStatus('Stop');
              Navigator.of(context).pop();

              if (widget.onClose != null) {
                widget.onClose!();
              }
            }),
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        elevation: 3.0,
      ),
      body: Stack(
        children: [
          WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: checkoutMap['url'],
            onProgress: (progress) async {
              // var url = await _controller.currentUrl() ?? '';
              // succeedRedirect(url);
            },
            onPageStarted: succeedRedirect, // Every new page.
            onWebViewCreated: (controller) async { // On first time.


              // Redirect when success = https://www.spider3d.co.il/תודה/ - https://www.spider3d.co.il/%D7%AA%D7%95%D7%93%D7%94/
              var url = await controller.currentUrl() ?? '';
              print('url $url');

              setState(() {
                isLoading = true;
              });
              _controller = controller;;

              await controller
                       .evaluateJavascript('console.log("Print TEST by JS")');

              print('onWebViewCreated');
              await controller.getTitle();



              /*        await _controller.evaluateJavascript(
                  'var mainNodeList = document.getElementsByName("cardNum");'
                  'var mainArray = Array.from(mainNodeList);'
                  'mainNodeList.forEach(item => item.value = "C");'
                  'mainNodeList.forEach(item => console.log(item));'
                  'console.log("document.body");'
                  'console.log(document.body);'
                  'console.log("----------");'
                  'console.log(mainArray);');*/
            },
            onPageFinished: (url) async {
              succeedRedirect(url);

              setState(() => isLoading = false);
              print('Current url $url');


              if (url.contains('icredit')) {
                await _controller.evaluateJavascript(
                    'console.log("Scrolling page to bottom..");'
                        'window.scrollTo(0,document.body.scrollHeight);'
                    //
                        "iframe_doc = document.getElementById('frame').contentDocument;"
                    // iframe_doc.getElementsByTagName('input').cvv2.value = '1'
                        "inputs = iframe_doc.getElementsByTagName('input');"
                        "inputs.cardNum.value = '${addressModel!
                        .cardNumber}';" // '4580000000000000';"
                        "inputs.id.value = '${addressModel
                        .cardHolderId}';" // 325245355
                    // "inputs.cvv2.value = '${addressModel.cardCvv}';" // 319
                        "selects = iframe_doc.getElementsByTagName('select');"
                        "selects.ddlMonth.value = '${int.parse(
                        addressModel.cardExpiryDate!.substring(
                            0, 2))}';" // So 03 -> 3
                        "selects.ddlYear.value  = '20${addressModel
                        .cardExpiryDate?.substring(3, 5)}';" // 2021
                  // "selects.ddlPayments.value = '2';" // תשלומים
                );
              }

              if (url.contains('icredit') && click_checkoutButton) {
                await _controller.evaluateJavascript(
                    "iframe_doc = document.getElementById('frame').contentDocument;"
                        "payButton = document.getElementById('cardsubmitbtn');"
                        'payButton.click();'
                );
              }
            },
          ),
          // isLoading ? Center(child: kLoadingWidget(context)) : Container()
        ],
      ),
    );

    /*
    return WebviewScaffold(
      withJavascript: true,
      appCacheEnabled: true,
      geolocationEnabled: true,
      url: checkoutMap['url'],
      headers: checkoutMap['headers'],
      // it's possible to add the Agent to fix the payment in some cases
      // userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36',
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.onFinish!(null);
              Navigator.of(context).pop();

              if (widget.onClose != null) {
                widget.onClose!();
              }
            }),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(child: kLoadingWidget(context)),
    );

     */
  }

  bool success = false;
  void succeedRedirect(url) {
      // print('Checking if url is succeed url: $url');
      // print('firstSucceedRedirect $firstSucceedRedirect');
    // if(firstSucceedRedirect) {
    //   print('Started');
      if ((url.contains('%D7%AA%D7%95%D7%93%D7%94') ||
          url.contains('spider') ||
          // url.contains('icredit') && kDebugMode || // For Tests ONLY! (AutoRedirect)
          url.contains('תודה') ) && success == false) {
        success = true;
        // print('Payment done succefully! Redirect..');
        widget.onFinish!('Success');
        // Navigator.of(context).pop();
/*      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(
              builder: (_) => SuccessScreen()));*/
        return;
      // }
    }
  }
}
