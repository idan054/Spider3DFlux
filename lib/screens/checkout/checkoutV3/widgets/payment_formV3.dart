import 'package:collection/collection.dart' show IterableExtension;
import 'package:country_pickers/country.dart' as picker_country;
import 'package:country_pickers/country_pickers.dart' as picker;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fstore/models/cart/cart_base.dart';
import 'package:fstore/models/entities/address.dart';
import 'package:fstore/screens/checkout/widgets/my_creditcard_address.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:credit_card_validator/credit_card_validator.dart';



class PaymentFormV3 extends StatelessWidget {
  const PaymentFormV3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final _formKey = GlobalKey<FormState>();
    final _ccValidator = CreditCardValidator();

    var _cardHolderNameController = TextEditingController();
    var _cardExpiryDateController = TextEditingController();
    var _cardNumberController = TextEditingController();
    var _cardCvvController = TextEditingController();
    var _cardHolderIdController = TextEditingController();


    // final _cardHolderNameNode = FocusNode(); // no needed
    final _cardExpiryDateNode = FocusNode();
    final _cardNumberNode = FocusNode();
    final _cardCvvNode = FocusNode();
    final _cardHolderIdNode = FocusNode();

    /// _handleDoneButton()
    Future _handleDoneButton(BuildContext context, CartModel model) async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        Address? creditCard = Address(
          cardHolderName: _cardHolderNameController.text,
          cardExpiryDate: _cardExpiryDateController.text,
          cardNumber: _cardNumberController.text,
          cardCvv: _cardCvvController.text,
          cardHolderId: _cardHolderIdController.text,

          // To do not reset the current data
          firstName: model.address?.firstName,
          lastName: '',
          state: '',
          country: '',
          city: model.address?.city,
          street: model.address?.street,
          phoneNumber: model.address?.phoneNumber,
          email: model.address?.email,
        );

       Provider.of<CartModel>(context, listen: false).setAddress(creditCard);

        var myAddress =
        await Provider.of<CartModel>(context, listen: false).getAddress();
          print('The CC Details:');
          print(myAddress!.cardHolderName);
          print(myAddress.cardHolderId);
          print(myAddress.cardNumber);
          print(myAddress.cardExpiryDate);
          print(myAddress.cardCvv);

        Navigator.pop(context);
      }
    }

    return Consumer<CartModel>(
      builder: (context, model, child) {
        // print('UserModel Details:');
        // print('user loggedIn? ${model.user?.loggedIn}');
        // print('user name: ${model.user?.name}');
        // print('user email: ${model.user?.email}');

        if (kDebugMode) {
          print('CartModel Details:');
          print('cart loggedIn? ${model.user?.loggedIn}');
          print('cart user ${model.user}');
          print('cart address ${model.address}');
          print('cart address ${model.address?.cardExpiryDate}');
          print('cart address ${model.address?.cardCvv}');
          print('cart checkout ${model.checkout}');
        }

        /// Will not auto Complete for security reasons
        if (model.address?.cardExpiryDate != null) _cardExpiryDateController.text = '${model.address?.cardExpiryDate}';
        if (model.address?.cardNumber != null) {
        _cardNumberController.text =
            '${model.address?.cardNumber.toString().substring(12, 16)} **** **** ****';
      }
      if (model.address?.cardCvv != null) _cardCvvController.text = '${model.address?.cardCvv}';
        if (model.address?.cardHolderId != null) _cardHolderIdController.text = '${model.address?.cardHolderId}';

        if (model.address?.cardHolderName != null) {
           _cardHolderNameController.text = '${model.address?.cardHolderName}';
        } else if (model.address?.firstName != null){
          _cardHolderNameController.text = '${model.address?.firstName}';
        }

      return
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              // color: Color(0xfff1f1f1),
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
                                    decoration: greyTxtDeco(labelText: 'שם בעל כרטיס'),
                                    controller: _cardHolderNameController,
                                    autofocus: _cardHolderNameController.text.isEmpty ? true : false,
                                    autofillHints: [AutofillHints.creditCardName,],
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_cardExpiryDateNode),
                                    validator: (val) {return val!.isEmpty ? 'תקן שדה זה' : null;},
                                  ),
                                ),
                                const Spacer(
                                  flex: 1,
                                ),
                                Flexible(
                                  flex: 10,
                                  child: TextFormField(
                                      decoration: greyTxtDeco(labelText: 'תוקף MM / YY'),
                                      controller: _cardExpiryDateController,
                                      maxLength: 5,
                                      focusNode: _cardExpiryDateNode,
                                      textAlign: TextAlign.center,
                                      autofocus: _cardHolderNameController.text.isEmpty ? false : true,
                                      autofillHints: [AutofillHints.creditCardExpirationDate],
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_cardNumberNode),
                                      onChanged: (value) {
                                        print(_cardExpiryDateController.text.length);
                                        if (value.length == 2 && !value.contains('/')) {
                                          _cardExpiryDateController.text += '/';
                                          _cardExpiryDateController.selection =
                                              TextSelection.fromPosition(TextPosition(offset: _cardExpiryDateController.text.length));
                                        }
                                        if (value.length == 5) FocusScope.of(context).requestFocus(_cardNumberNode);
                                      },
                                      validator: (val) {
                                        try {
                                          int.parse(val.toString().substring(0, 2)) <= 12;
                                        } catch (e, s) {
                                          // print(s);
                                          return 'מבנה: 12/27';
                                        }
                                        return val!.contains('/') &&
                                                val.length == 5 ? null : 'מבנה: 12/27';
                                      },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  flex: 14,
                                  child: TextFormField(
                                    decoration: greyTxtDeco(labelText: 'מס׳ כרטיס אשראי'),
                                    controller: _cardNumberController,
                                    focusNode: _cardNumberNode,
                                    autofillHints: [AutofillHints.creditCardNumber],
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_cardCvvNode),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => value.length == 16 ? FocusScope.of(context).requestFocus(_cardCvvNode) : null,
                                    validator: (val) {
                                      var isValid = _ccValidator.validateCCNum(val!).isValid;

                                      // print('isValid is $isValid');
                                      return isValid
                                          ? null
                                          : 'הזן מס׳ כרטיס תקין';
                                    },
                                  ),
                                ),
                                const Spacer(
                                  flex: 1,
                                ),
                                Flexible(
                                  flex: 7,
                                  child: TextFormField(
                                    decoration: greyTxtDeco(labelText: '3 ספרות'),
                                    focusNode: _cardCvvNode,
                                    controller: _cardCvvController,
                                    keyboardType: TextInputType.number,
                                    autofillHints: [AutofillHints.creditCardSecurityCode],
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_cardHolderIdNode),
                                    onChanged: (value) => value.length == 3 ? FocusScope.of(context).requestFocus(_cardHolderIdNode) : null,
                                    validator: (val) {
                                      var cardType = _ccValidator.validateCCNum(val!).ccType;
                                      print('cardTypeX is $cardType');
                                      var isCvvValid = _ccValidator.validateCVV(val, cardType).isValid;
                                      return isCvvValid ? null : 'תקן שדה זה';
                                    },
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Flexible(
                                  flex: 10,
                                  child: TextFormField(
                                    decoration: greyTxtDeco(labelText: 'מס׳ תעודת זהות'),
                                    focusNode: _cardHolderIdNode,
                                    controller: _cardHolderIdController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) async {
                                      await _handleDoneButton(context, model);
                                    },
                                    validator: (val) {
                                      return val!.isEmpty || val.length < 7
                                          ? 'תקן שדה זה' : null;
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
                                          await _handleDoneButton(context, model);
                                        },
                                        child: const Text('עדכן',
                                            style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                    ),
                  ),
                  // Services().widget.renderShippingMethods(context, onBack: () {}, onNext: () {}),
                ],
              ),
            ),
          );
      }
    );
  }


}
