import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart'
    show Address, CartModel, Country, CreditCard, CreditCardModel, UserModel;
import '../checkout_screen.dart';
import 'my_credit_card.dart';

class MyCreditCardForm extends StatefulWidget {
  final bool isFullPage;
  final Function onNext;

  MyCreditCardForm({required this.onNext, this.isFullPage = true});

  @override
  _MyCreditCardFormState createState() => _MyCreditCardFormState();
}

class _MyCreditCardFormState extends State<MyCreditCardForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _creditDateController = TextEditingController();
  final CreditCardValidator _ccValidator = CreditCardValidator();

  final _expireMmYy = FocusNode();
  final _cardNumberNode = FocusNode();
  final _cvvNode = FocusNode();
  final _buyerIdNode = FocusNode();

  Address? creditCard;
  List<Country>? countries = [];
  List<dynamic> states = [];
  var cardType; // My

  @override
  void initState() {
    super.initState();
    // print("Start CreditCardAddress init");
    Future.delayed(
      Duration.zero,
      () async {
        final addressValue =
            await Provider.of<CartModel>(context, listen: false).getAddress();
        // final creditCardValue = Provider.of<CreditCardModel>(context, listen: false)             .getCreditCard();
        // ignore: unnecessary_null_comparison
        if (addressValue != null) {
          setState(() {
            creditCard = addressValue;
            // print('creditCard');
            // print(creditCard.toString());
            // print(creditCard);
            // print(creditCard!.cvv);
            // print(creditCard!.cvv.toString());

            // _cityController.text = creditCard?.city ?? '';
            // _streetController.text = creditCard?.street ?? '';
          });
        }
        // My comment
/*        else {
          var user = Provider.of<UserModel>(context, listen: false).user;
          setState(() {
            creditCard = Address(country: kPaymentConfig['DefaultCountryISOCode']);
            if (kPaymentConfig['DefaultStateISOCode'] != null) {
              creditCard!.state = kPaymentConfig['DefaultStateISOCode'];
            }

            if (user != null) {
              creditCard!.firstName = user.firstName;
              creditCard!.lastName = user.lastName;
              creditCard!.email = user.email;
            }
          });
        }
        countries = await Services().widget.loadCountries(context);
        var country = countries!.firstWhereOrNull((element) =>
            element.id == creditCard!.country || element.code == creditCard!.country);
        if (country == null) {
          if (countries!.isNotEmpty) {
            country = countries![0];
            creditCard!.country = countries![0].code;
          } else {
            country = Country.fromConfig(creditCard!.country, null, null, []);
          }
        } else {
          creditCard!.country = country.code;
          creditCard!.countryId = country.id;
        }
        if (mounted) {
          setState(() {});
        }
        states = await Services().widget.loadStates(country);
        if (mounted) {
          setState(() {});
        }*/
      },
    );
  }

  Future<void> updateState(Address? address) async {
    setState(() {
      _cityController.text = address?.city ?? '';
      _streetController.text = address?.street ?? '';

      // this.creditCard?.country = address?.country ?? '';
    });
  }

  bool checkToSave() {
    final storage = LocalStorage('address');
    var _list = <Address>[];
    try {
      var data = storage.getItem('data');
      if (data != null) {
        (data as List).forEach((item) {
          final add = Address.fromLocalJson(item);
          _list.add(add);
        });
      }
      for (var local in _list) {
        if (local.city != _cityController.text) continue;
        if (local.street != _streetController.text) continue;

/*        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(S.of(context).yourAddressExistYourLocal),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    S.of(context).ok,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                )
              ],
            );
          },
        );*/

        // print('checkToSave Bool is false');
        // return false;
        print('checkToSave Bool false is overwrite to true //My');
        return true;
      }
    } catch (err) {
      printLog(err);
    }
    print('checkToSave Bool is true');
    return true;
  }

  Future<void> saveDataToLocal() async {
    final storage = LocalStorage('address');
    var _list = <Address?>[];
    _list.add(creditCard);
    try {
      final ready = await storage.ready;
      if (ready) {
        var data = storage.getItem('data');
        if (data != null) {
          (data as List).forEach((item) {
            final add = Address.fromLocalJson(item);
            _list.add(add);
          });
        }
        await storage.setItem(
            'data',
            _list.map((item) {
              // return item!.toJsonEncodable();
              return item!.toJson();
            }).toList());

/*        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(S.of(context).youHaveBeenSaveAddressYourLocal),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      S.of(context).ok,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  )
                ],
              );
            });*/
      }
    } catch (err) {
      printLog(err);
    }
  }

  String? validateEmail(String value) {
    var valid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    if (valid) {
      return null;
    }
    return 'הזן דוא״ל תקין';
  }

  String? expire_mmyy;
  String? expire_year;

  @override
  Widget build(BuildContext context) {
    var countryName = S.of(context).country;

    // if (creditCard == null) {
    //   return Container(height: 100, child: kLoadingWidget(context));
    // }
    return widget.isFullPage
        ? Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              // backgroundColor: Theme.of(context).backgroundColor,
              backgroundColor: Color(0xfff1f1f1),
              title: Text(
                S.of(context).shippingAddress,
                // 'llll',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              leading: Center(
                child: IconButton(
                  onPressed: () async {
                    if (!checkToSave()) return;
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Provider.of<CartModel>(context, listen: false)
                          .setAddress(creditCard);
                      await saveDataToLocal();

                      // Navigator.pop(context);

                      // await Navigator.of(context).push(MaterialPageRoute(builder: (_) => Checkout()));
                      await widget.onNext;
                    }

                    var myAddress =
                        await Provider.of<CartModel>(context, listen: false)
                            .getAddress();
                    print("myAddress:");
                    print(myAddress!.cardHolderName);
                    print(myAddress.cardExpiryDate);
                    print(myAddress.cardNumber);
                    print(myAddress.cardCvv);
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Theme.of(context).accentColor,
                  iconSize: 20,
                ),
              ),
            ),
            body: Center(
              child: Container(
                  decoration: BoxDecoration(
                    color: kGrey200.withOpacity(0.10),
                    border: Border.all(
                      color: kGrey200.withOpacity(0.99),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(15.0),
                  child: formWidget()),
            ))
        : formWidget();
  }

  Widget formWidget() {
    return
      SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child:
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            // color: Color(0xfff1f1f1),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                Flexible(
                                  flex: 10,
                                  child: TextFormField(
                                    // initialValue:  address!.firstName,
                                    autofocus: true,
                                    autofillHints: [
                                      AutofillHints.creditCardName,
                                      // AutofillHints.creditCardFamilyName,
                                      // AutofillHints.creditCardGivenName,
                                      // AutofillHints.creditCardMiddleName,
                                    ],
                                    decoration:
                                        greyTxtDeco(labelText: 'שם בעל כרטיס'),
                                    // const InputDecoration(
                                    // //     labelText: S.of(context).firstName
                                    // labelText: 'שם לחשבונית'),
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    validator: (val) {
                                      return val!.isEmpty
                                          // ? S.of(context).firstNameIsRequired
                                          ? 'תקן שדה זה'
                                          : null;
                                    },
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context)
                                            .requestFocus(_expireMmYy),
                                    onSaved: (String? value) {
                                      creditCard!.cardHolderName = value;
                                    },
                                  ),
                                ),
                                const Spacer(
                                  flex: 1,
                                ),
                                Flexible(
                                  flex: 10,
                                  child: TextFormField(
                                      // style: const TextStyle(
                                      //   letterSpacing: 1.5,
                                      // ),
                                      controller: _creditDateController,
                                      textAlign: TextAlign.center,
                                      // initialValue:  address!.phoneNumber,
                                      autofillHints: [
                                        AutofillHints.creditCardExpirationDate
                                      ],
                                      // keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        print(
                                            _creditDateController.text.length);
                                        if (value.length == 2) {
                                          _creditDateController.text += '/';
                                          expire_mmyy = value;
                                          _creditDateController.selection =
                                              TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset:
                                                          _creditDateController
                                                              .text.length));
                                        }
                                      },
                                      focusNode: _expireMmYy,
                                      // textAlign: TextAlign.center,
                                      // style: TextStyle(fontSize: 22),
                                      decoration: greyTxtDeco(
                                        // labelText: S.of(context).phoneNumber
                                        labelText: 'תוקף MM / YY',
                                        // labelText: 'תוקף MM / YY',
                                        // labelText: 'MM  YY',
                                      ),
                                      textInputAction: TextInputAction.next,
                                      validator: (val) {
                                        // var isValid = _ccValidator
                                        //     .validateExpDate(val!)
                                        //     .isValid;

                                        // print(val!.length == 4 ? 'V' : 'X');

                                        // valid_month
                                        try {
                                          int.parse(val
                                                  .toString()
                                                  .substring(0, 2)) <=
                                              12;

                                          // 22 < 27  < 50

/*                                          int.parse(val
                                              .toString()
                                              .substring(3, 5)) > 22;

                                          int.parse(val
                                              .toString()
                                              .substring(3, 5)) < 50;*/

                                        } catch (e, s) {
                                          // print(s);
                                          return 'מבנה: 12/27';
                                        }

                                        // var yy = int.parse(
                                        //     val.toString().substring(2, 4));

                                        // print('mm $mm');
                                        // print(mm <= 12);
                                        // print('yy $yy');
                                        // print(yy < 31);

                                        // print('$val - ${val?.length}');
                                        // val = val?.replaceAll('/', '');
                                        // print('$val - ${val?.length}');
                                        return val!.contains('/') &&
                                                val.length == 5
                                            ? null
                                            : 'מבנה: 12/27';
                                      },
                                      onFieldSubmitted: (_) =>
                                          FocusScope.of(context)
                                              .requestFocus(_cardNumberNode),
                                      onSaved: (String? value) {
                                        // print('$val - ${val?.length}');
                                        value = value?.replaceAll('/', '');
                                        // print('$val - ${val?.length}');
                                        creditCard!.cardExpiryDate = value;
                                      }),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  flex: 14,
                                  child: TextFormField(
                                    focusNode: _cardNumberNode,
                                    // initialValue:  address!.firstName,
                                    autofillHints: [
                                      AutofillHints.creditCardNumber
                                    ],
                                    decoration:
                                        greyTxtDeco(labelText: 'מס׳ כרטיס'),
                                    // const InputDecoration(
                                    // //     labelText: S.of(context).firstName
                                    // labelText: 'שם לחשבונית'),
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,

                                    onChanged: (value) {
                                      cardType = _ccValidator
                                          .validateCCNum(value)
                                          .ccType;
                                      print('cardType is $cardType');
                                    },

                                    validator: (val) {
                                      var isValid = _ccValidator
                                          .validateCCNum(val!)
                                          .isValid;

                                      // return val!.isEmpty
                                      //     ? S.of(context).firstNameIsRequired
                                      //     : null;

                                      // print('isValid is $isValid');
                                      return isValid
                                          ? null
                                          : 'הזן מס׳ כרטיס תקין';
                                    },
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context)
                                            .requestFocus(_cvvNode),
                                    onSaved: (String? value) {
                                      creditCard!.cardNumber = value;
                                    },
                                  ),
                                ),
                                const Spacer(
                                  flex: 1,
                                ),
                                Flexible(
                                  flex: 7,
                                  child: TextFormField(
                                    autofillHints: [
                                      AutofillHints.creditCardSecurityCode
                                    ],
                                    focusNode: _cvvNode,
                                    validator: (val) {
                                      cardType = _ccValidator
                                          .validateCCNum(val!)
                                          .ccType;
                                      print('cardTypeX is $cardType');

                                      var isCvvValid = _ccValidator
                                          .validateCVV(val, cardType)
                                          .isValid;

                                      // return val!.isEmpty
                                      //     ? S.of(context).firstNameIsRequired
                                      //     : null;

                                      // print('isValid is $isValid');
                                      return isCvvValid ? null : 'תקן שדה זה';
                                    },
                                    decoration:
                                        greyTxtDeco(labelText: '3 ספרות'),
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context)
                                            .requestFocus(_buyerIdNode),
                                    onSaved: (String? value) {
                                      creditCard!.cardCvv = value;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            /*          TextFormField(
                              controller: _zipController,
                              autofillHints: [AutofillHints.postalCode],
                              focusNode: _zipNode,
                              validator: (val) {
                                return val!.isEmpty ? S.of(context).zipCodeIsRequired : null;
                              },
                              keyboardType:
                                  (kPaymentConfig['EnableAlphanumericZipCode'] ?? false)
                                      ? TextInputType.text
                                      : TextInputType.number,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(labelText: S.of(context).zipCode),
                              onSaved: (String? value) {
                                address!.zipCode = value;
                              }),*/
                            // const SizedBox(height: 20),

                            Row(
                              children: [
                                Flexible(
                                  flex: 10,
                                  child: TextFormField(
                                    focusNode: _buyerIdNode,
                                    validator: (val) {
                                      return val!.isEmpty || val.length < 7
                                          // ? S.of(context).firstNameIsRequired
                                          ? 'תקן שדה זה'
                                          : null;
                                    },
                                    // initialValue:  address!.firstName,
                                    decoration: greyTxtDeco(
                                        labelText: 'מס׳ תעודת זהות'),
                                    // const InputDecoration(
                                    // //     labelText: S.of(context).firstName
                                    // labelText: 'שם לחשבונית'),
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,

                                    /*                               validator: (val) {
                                      var isValid = _ccValidator
                                          .validateCCNum(val!)
                                          .isValid;

                                      // print('isValid is $isValid');
                                      return isValid ? null : 'הזן ת.ז תקין';
                                    },*/

                                    onFieldSubmitted: (_) async {
                                      await _handleDoneButton();
                                    },
                                    onSaved: (String? value) {
                                      creditCard!.cardHolderId = value;
                                    },
                                  ),
                                ),
                                const Spacer(
                                  flex: 1,
                                ),
                                Flexible(
                                  flex: 4,
                                  child: Container(
                                    alignment: Alignment.topRight,
                                    width: 90,
                                    height: 40,
                                    child: ButtonTheme(
                                      // height: 20,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          onPrimary: Colors.white,
                                          primary:
                                              Theme.of(context).primaryColor,
                                        ),
                                        onPressed: () async {
                                          await _handleDoneButton();
                                        },
                                        child: const Text('המשך',
                                            style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            /*        show_creditCard_details
                                ? const Text('פרטי האשראי עודכנו, אנא המשך')
                                : Container()*/
                            //
                          ]),
                    ),
                  ),
                  // Services().widget.renderShippingMethods(context, onBack: () {}, onNext: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _handleDoneButton() async {
    if (!checkToSave()) return;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Provider.of<CartModel>(context, listen: false).setAddress(creditCard);
      await saveDataToLocal();

      var myAddress =
      await Provider.of<CartModel>(context, listen: false).getAddress();
      print("The CC Details:");
      print(myAddress!.cardHolderName);
      print(myAddress.cardHolderId);
      print(myAddress.cardNumber);
      print(myAddress.cardExpiryDate);
      print(myAddress.cardCvv);

      setState(() {
        show_creditCard_details = true;
      });

      await Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => Checkout()));
    }
  }
}

class MyFadePush<T> extends PageRoute<T> {
  MyFadePush(this.child);

  @override
  // TODO: implement barrierColor
  Color get barrierColor => Colors.white;

  @override
  String get barrierLabel => 'barrierLabel';

  final Widget child;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);
}

InputDecoration greyTxtDeco(
    {hintText, /*icons, svgIcon,*/ helperText, labelText}) {
  return InputDecoration(
    counter: const Offstage(/*Counter Here*/),
    //וויג'ט שמסתיר ויזואלית את קיומו של הילד שלו
    filled: true,
    fillColor: Colors.black.withOpacity(0.05),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    //.only(left: 10, right: 10, top: 10, bottom: 10),
    // helperText: helperText,
    // helperMaxLines: 2,
    hintText: hintText,
    labelText: labelText,
    labelStyle: TextStyle(
      color: Colors.grey[500], //Hexcolor("#808c8e")
      // fontFamily: "Assistant",
      // fontWeight: FontWeight.w600,
    ),
    hintStyle: TextStyle(
      color: Colors.grey[500], //Hexcolor("#808c8e")
      // fontFamily: "Assistant",
      // fontWeight: FontWeight.w600,
    ),

    // prefixIcon: Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 13),
    //   child:  SvgPicture.asset(svgIcon, color: spiderRed, height: 24,),
    // // Icon(icons, color: spiderRed,)
    // ),

    errorStyle: const TextStyle(
        //fontSize:14, color: Colors.red,
        // fontFamily: "Assistant", fontWeight: FontWeight.w600,
        ),

    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: Colors.white, width: 0)),

    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: Colors.white, width: 0)),

    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: Colors.white, width: 0)),
  );
}
