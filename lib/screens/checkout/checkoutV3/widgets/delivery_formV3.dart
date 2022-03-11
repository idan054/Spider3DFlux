import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fstore/models/cart/cart_base.dart';
import 'package:fstore/models/entities/address.dart';
import 'package:fstore/models/entities/user.dart'; // user funcs
// import 'package:fstore/models/serializers/index.dart';
import 'package:fstore/screens/checkout/widgets/my_creditcard_address.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';



class DeliveryFormV3 extends StatelessWidget {
  const DeliveryFormV3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    var _nameController = TextEditingController();
    var _cityController = TextEditingController();
    var _streetController = TextEditingController();
    var _phoneController = TextEditingController();
    var _emailController = TextEditingController();

    // final _nameNode = FocusNode(); // no needed
    final _cityNode = FocusNode();
    final _streetNode = FocusNode();
    final _phoneNode = FocusNode();
    final _emailNode = FocusNode();

    // region _handleDoneButton()
    Future _handleDoneButton(BuildContext context, CartModel model) async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        Address? address = Address(
          firstName: _nameController.text
          lastName: '',
          state: '',
          country: '',
          city: _cityController.text,
          street: _streetController.text,
          phoneNumber: _phoneController.text,
          email: _emailController.text,

          // To do not reset the current data
          cardHolderName: model.address?.cardHolderName,
          cardExpiryDate: model.address?.cardExpiryDate,
          cardNumber: model.address?.cardNumber,
          cardCvv: model.address?.cardCvv,
          cardHolderId: model.address?.cardHolderId
        );
        User? user = User(
            username: _nameController.text,
            firstName: _nameController.text,
            email: _emailController.text);

        // await Provider.of<UserModel>(context, listen: false).saveUser(user); // To local
        // Provider.of<UserModel>(context, listen: false).updateUser(user); // To Woo??
        Provider.of<CartModel>(context, listen: false).setAddress(address); // To local

        // var myAddress =
        await Provider.of<CartModel>(context, listen: false).getAddress();
        // print('myAddress:');
        // print(myAddress!.firstName);
        // print(myAddress.city);

        Navigator.pop(context);
        // await Navigator.of(context)
        //     .pushReplacement(MaterialPageRoute(builder: (_) => Checkout()));
      }
    }
    // endregion _handleDoneButton()

    String? validateEmail(String value) {
      var valid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(value);
      if (valid) {
        return null;
       }
      return 'הזן דוא״ל תקין';
    }

    return Consumer<CartModel>(
      builder: (context, model, child) {

        // region set controllers
        if (kDebugMode) {
          print('UserModel Details:');
          // print('user loggedIn? ${model.user?.loggedIn}');
          print('user: ${model.user}');
          print('user name: ${model.user?.name}');
          print('user email: ${model.user?.email}');

          print('CartModel Details:');
          print('cart loggedIn? ${model.user?.loggedIn}');
          print('cart user ${model.user}');
          print('cart address ${model.address}');
          print('cart checkout ${model.checkout}');
        }

        if (model.address?.city != null) _cityController.text = '${model.address?.city}';
        if (model.address?.street != null) _streetController.text = '${model.address?.street}';
        if (model.address?.phoneNumber != null) _phoneController.text = '${model.address?.phoneNumber}';
        if (model.address?.firstName != null) _nameController.text = '${model.address?.firstName}';


        // When address firstName is null:
        // else if (model.user?.username != null){
        //   _nameController.text = '${model.user?.username}';
        // }

        if (model.address?.email != null) {
          _emailController.text = '${model.address?.email}';}
        // When address email is null:
        else if (model.user?.email != null ){
          _emailController.text = '${model.user?.email}';
        }

        // endregion set controllers

        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            // color: Color(0xfff1f1f1),
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Form(
                  key: _formKey, //   final _formKey = GlobalKey<FormState>();
                  child: AutofillGroup( // Do we really need those?
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            decoration: greyTxtDeco(labelText: 'שם לחשבונית'),
                            controller: _nameController,
                            autofillHints: [AutofillHints.givenName],
                            textInputAction: TextInputAction.next,
                            autofocus: model.user?.username != null ? false : true, // focus if empty
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_cityNode),
                            validator: (val) =>
                                val!.isEmpty ? S.of(context).firstNameIsRequired : null,
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 7,
                                child: TextFormField(
                                  decoration: greyTxtDeco(labelText: 'עיר'),
                                  controller: _cityController,
                                  autofillHints: [AutofillHints.addressCity],
                                  focusNode: _cityNode,
                                  textInputAction: TextInputAction.next,
                                  autofocus:
                                  model.user?.username != null
                                  && model.address?.city == null
                                      ? true : false, // focus if name already filled
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_streetNode),
                                  validator: (val) =>
                                     val!.isEmpty ? S.of(context).cityIsRequired : null,
                                ),
                              ),
                              const Spacer(
                                flex: 1,
                              ),
                              Flexible(
                                flex: 11,
                                child: TextFormField(
                                    decoration: greyTxtDeco(labelText: 'רחוב, מס׳ בית'),
                                    controller: _streetController,
                                    autofillHints: [
                                      AutofillHints.fullStreetAddress
                                    ],
                                    focusNode: _streetNode,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneNode),
                                    validator: (val) =>
                                       val!.isEmpty ? S.of(context).streetIsRequired : null,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 9,
                                child: TextFormField(
                                    decoration: greyTxtDeco(labelText: 'טלפון'),
                                    controller: _phoneController,
                                    autofillHints: [AutofillHints.telephoneNumber],
                                    focusNode: _phoneNode,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailNode),
                                    onChanged: (value) => value.length == 10 && _emailController.text.isEmpty
                                        ? FocusScope.of(context).requestFocus(_emailNode) : null,
                                    validator: (val) {
                                        // print('val.length');
                                        // print(val!.length);
                                        return val!.length != 10 ? 'הזן טלפון תקין' : null;
                                        },
                                    ),
                              ),
                              const Spacer(
                                flex: 1,
                              ),
                              Flexible(
                                flex: 9,
                                child: TextFormField(
                                    decoration: greyTxtDeco(labelText: 'אימייל'),
                                    controller: _emailController,
                                    autofillHints: [AutofillHints.email],
                                    focusNode: _emailNode,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    validator: (val) {
                                      if (val!.isEmpty) return S.of(context).emailIsRequired;
                                      return validateEmail(val);
                                    },
                                    onFieldSubmitted: (_) async {
                                      await _handleDoneButton(context, model);
                                    },),
                              ),
                            ],
                          ),
                          Center(
                            child: ButtonTheme(
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  onPrimary: Colors.white,
                                  primary: Theme
                                      .of(context)
                                      .primaryColor,
                                ),
                                onPressed: () async {
                                  await _handleDoneButton(context, model);
                                },
                                child: const Text('עדכן',
                                    style: TextStyle(fontSize: 14)),
                              ),
                            ),
                          )
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
