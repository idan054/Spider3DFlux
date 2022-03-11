import 'package:collection/collection.dart' show IterableExtension;
import 'package:country_pickers/country.dart' as picker_country;
import 'package:country_pickers/country_pickers.dart' as picker;
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show Address, CartModel, Country, UserModel;
import '../../../services/index.dart';
import '../checkout_screen.dart';

class ShippingForm extends StatefulWidget {
  final bool isFullPage;
  final Function onNext; // should actually be future
  // final Future<Function> onNext;
  // final Future<void> onNext;

  ShippingForm({required this.onNext, this.isFullPage = true});

  @override
  _ShippingFormState createState() => _ShippingFormState();
}

class _ShippingFormState extends State<ShippingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();

  final _lastNameNode = FocusNode();
  final _phoneNode = FocusNode();
  final _emailNode = FocusNode();
  final _cityNode = FocusNode();
  final _streetNode = FocusNode();
  final _blockNode = FocusNode();
  final _zipNode = FocusNode();
  final _stateNode = FocusNode();
  final _countryNode = FocusNode();
  final _apartmentNode = FocusNode();

  Address? address;
  List<Country>? countries = [];
  List<dynamic> states = [];

  @override
  void dispose() {
    _cityController.dispose();
    _streetController.dispose();
    _blockController.dispose();
    _zipController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _apartmentController.dispose();

    _lastNameNode.dispose();
    _phoneNode.dispose();
    _emailNode.dispose();
    _cityNode.dispose();
    _streetNode.dispose();
    _blockNode.dispose();
    _zipNode.dispose();
    _stateNode.dispose();
    _countryNode.dispose();
    _apartmentNode.dispose();

    super.dispose();
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

  Future _handleDoneButton() async {
    if (!checkToSave()) return;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Provider.of<CartModel>(context, listen: false).setAddress(address);
      await saveDataToLocal();

      var myAddress =
      await Provider.of<CartModel>(context, listen: false).getAddress();
      print('myAddress:');
      print(myAddress!.firstName);
      print(myAddress.city);

      // Navigator.pop(context);

      await Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => Checkout()));
      // MyFadePush(Checkout()));
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () async {
        final addressValue =
            await Provider.of<CartModel>(context, listen: false).getAddress();
        // ignore: unnecessary_null_comparison
        if (addressValue != null) {
          setState(() {
            address = addressValue;
            _cityController.text = address?.city ?? '';
            _streetController.text = address?.street ?? '';
            _zipController.text = address?.zipCode ?? '';
            _stateController.text = address?.state ?? '';
            _blockController.text = address?.block ?? '';
            _apartmentController.text = address?.apartment ?? '';
          });
        } else {
          var user = Provider.of<UserModel>(context, listen: false).user;
          setState(() {
            address = Address(country: kPaymentConfig['DefaultCountryISOCode']);
            if (kPaymentConfig['DefaultStateISOCode'] != null) {
              address!.state = kPaymentConfig['DefaultStateISOCode'];
            }
            _countryController.text = address!.country!;
            _stateController.text = address!.state!;
            if (user != null) {
              address!.firstName = user.firstName;
              address!.lastName = user.lastName;
              address!.email = user.email;
            }
          });
        }
        countries = await Services().widget.loadCountries(context);
        var country = countries!.firstWhereOrNull((element) =>
            element.id == address!.country || element.code == address!.country);
        if (country == null) {
          if (countries!.isNotEmpty) {
            country = countries![0];
            address!.country = countries![0].code;
          } else {
            country = Country.fromConfig(address!.country, null, null, []);
          }
        } else {
          address!.country = country.code;
          address!.countryId = country.id;
        }
        _countryController.text = country.code!;
        if (mounted) {
          setState(() {});
        }
        states = await Services().widget.loadStates(country);
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<void> updateState(Address? address) async {
    setState(() {
      _cityController.text = address?.city ?? '';
      _streetController.text = address?.street ?? '';
      _zipController.text = address?.zipCode ?? '';
      _stateController.text = address?.state ?? '';
      _countryController.text = address?.country ?? '';
      this.address?.country = address?.country ?? '';
      _apartmentController.text = address?.apartment ?? '';
      _blockController.text = address?.block ?? '';
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
        if (local.zipCode != _zipController.text) continue;
        if (local.state != _stateController.text) continue;
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
    _list.add(address);
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
              return item!.toJsonEncodable();
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

  @override
  Widget build(BuildContext context) {
    var countryName = S.of(context).country;
    if (_countryController.text.isNotEmpty) {
      try {
        countryName = picker.CountryPickerUtils.getCountryByIsoCode(
                _countryController.text)
            .name;
      } catch (e) {
        countryName = S.of(context).country;
      }
    }

    if (address == null) {
      return Container(height: 100, child: kLoadingWidget(context));
    }
    return widget.isFullPage
        ?
    Scaffold(
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
                          .setAddress(address);
                      await saveDataToLocal();

                      // Navigator.pop(context);

                      // await Navigator.of(context).push(MaterialPageRoute(builder: (_) => Checkout()));
                      await widget.onNext;
                    }

                    var myAddress =
                        await Provider.of<CartModel>(context, listen: false)
                            .getAddress();
                    print("myAddress:");
                    print(myAddress!.firstName);
                    print(myAddress.city);
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ClipRRect(
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
                            TextFormField(
                              autofocus: true,
                              // initialValue:  address!.firstName,
                              autofillHints: [AutofillHints.givenName],
                              decoration: greyTxtDeco(labelText: 'שם לחשבונית'),
                              // const InputDecoration(
                              // //     labelText: S.of(context).firstName
                              // labelText: 'שם לחשבונית'),
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              validator: (val) {
                                return val!.isEmpty
                                    ? S.of(context).firstNameIsRequired
                                    : null;
                              },
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_cityNode),
                              onSaved: (String? value) {
                                address!.firstName = value;
                              },
                            ),

/*                        const SizedBox(height: 10.0),
                              if (kPaymentConfig['allowSearchingAddress'])
                                if (kGoogleAPIKey.isNotEmpty)
                                  Expanded(
                                    child: ButtonTheme(
                                      height: 50,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          onPrimary: Theme.of(context).accentColor,
                                          primary:
                                              Theme.of(context).primaryColorLight,
                                        ),
                                        onPressed: () async {
                                          var result =
                                              await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => PlacePicker(
                                                kIsWeb
                                                    ? kGoogleAPIKey['web']
                                                    : isIos
                                                        ? kGoogleAPIKey['ios']
                                                        : kGoogleAPIKey['android'],
                                              ),
                                            ),
                                          );
                                          if (result != null) {
                                            address!.country = result.country;
                                            address!.street = result.street;
                                            address!.state = result.state;
                                            address!.city = result.city;
                                            address!.zipCode = result.zip;
                                            address!.mapUrl =
                                                'https://maps.google.com/maps?q=${result.latLng.latitude},${result.latLng.longitude}&output=embed';
                                            setState(() {
                                              _cityController.text = result.city;
                                              _stateController.text = result.state;
                                              _streetController.text = result.street;
                                              _zipController.text = result.zip;
                                              _countryController.text =
                                                  result.country;
                                            });
                                            final c = Country(
                                                id: result.country,
                                                name: result.country);
                                            states =
                                                await Services().widget.loadStates(c);
                                            setState(() {});
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            const Icon(
                                              FontAwesomeIcons.searchLocation,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 10.0),
                                            Text(S
                                                .of(context)
                                                .searchingAddress
                                                .toUpperCase()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),*/
                            // const SizedBox(height: 10),
/*                        ButtonTheme(
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    onPrimary: Theme.of(context).accentColor,
                                    primary: Theme.of(context).primaryColorLight,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChooseAddressScreen(updateState),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Icon(
                                        FontAwesomeIcons.solidAddressBook,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        S.of(context).selectAddress.toUpperCase(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                S.of(context).country,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.grey),
                              ),
                              (countries!.length == 1)
                                  ? Text(
                                      picker.CountryPickerUtils.getCountryByIsoCode(
                                              countries![0].code!)
                                          .name,
                                      style: const TextStyle(fontSize: 18),
                                    )
                                  : GestureDetector(
                                      onTap: _openCountryPickerDialog,
                                      child: Column(children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(countryName,
                                                    style: const TextStyle(
                                                        fontSize: 17.0)),
                                              ),
                                              const Icon(Icons.arrow_drop_down)
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          height: 1,
                                          color: kGrey900,
                                        )
                                      ]),
                                    ),
                              renderStateInput(),*/
                            Row(
                              children: [
                                Flexible(
                                  flex: 7,
                                  child: TextFormField(
                                    // controller: _cityController,
                                    // initialValue:  address!.city,
                                    autofillHints: [AutofillHints.addressCity],
                                    focusNode: _cityNode,
                                    validator: (val) {
                                      return val!.isEmpty
                                          ? S.of(context).cityIsRequired
                                          : null;
                                    },
                                    decoration: greyTxtDeco(
                                        labelText: S.of(context).city),
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context)
                                            .requestFocus(_streetNode),
                                    onSaved: (String? value) {
                                      address!.city = value;
                                    },
                                  ),
                                ),
                                const Spacer(
                                  flex: 1,
                                ),
                                Flexible(
                                  flex: 11,
                                  child: TextFormField(
                                      // controller: _streetController,
                                      // initialValue:  address!.street,
                                      autofillHints: [
                                        AutofillHints.fullStreetAddress
                                      ],
                                      focusNode: _streetNode,
                                      validator: (val) {
                                        return val!.isEmpty
                                            ? S.of(context).streetIsRequired
                                            : null;
                                      },
                                      decoration: greyTxtDeco(
                                          // labelText: S.of(context).streetName
                                          labelText: 'רחוב, מס׳ בית'),
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) =>
                                          FocusScope.of(context)
                                              .requestFocus(_phoneNode),
                                      onSaved: (String? value) {
                                        address!.street = value;
                                      }),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  flex: 9,
                                  child: TextFormField(
                                      // initialValue:  address!.phoneNumber,
                                      autofillHints: [
                                        AutofillHints.telephoneNumber
                                      ],
                                      focusNode: _phoneNode,
                                      decoration: greyTxtDeco(
                                        // labelText: S.of(context).phoneNumber
                                        labelText: 'טלפון',
                                      ),
                                      textInputAction: TextInputAction.next,
                                      validator: (val) {
                                        print('val.length');
                                        print(val!.length);
                                        return val.length != 10
                                            ? 'הזן טלפון תקין'
                                            : null;
                                      },
                                      keyboardType: TextInputType.number,
                                      onFieldSubmitted: (_) =>
                                          FocusScope.of(context)
                                              .requestFocus(_emailNode),
                                      onSaved: (String? value) {
                                        address!.phoneNumber = value;
                                      }),
                                ),
                                const Spacer(
                                  flex: 1,
                                ),
                                Flexible(
                                  flex: 9,
                                  child: TextFormField(
                                      // initialValue:  address!.email,
                                      autofillHints: [AutofillHints.email],
                                      focusNode: _emailNode,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: greyTxtDeco(
                                          labelText: S.of(context).email),
                                      textInputAction: TextInputAction.done,
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return S.of(context).emailIsRequired;
                                        }
                                        return validateEmail(val);
                                      },
                                      onFieldSubmitted: (_) async {
                                        await _handleDoneButton();
                                      },
                                      onSaved: (String? value) {
                                        address!.email = value;
                                      }),
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
                            Center(
                              child: ButtonTheme(
                                height: 45,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    onPrimary: Colors.white,
                                    primary: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () async {
                                    await _handleDoneButton();
                                  },
                                  child: const Text('המשך',
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
          ),
        ),
      ),
    );
  }

  Widget renderStateInput() {
    if (states.isNotEmpty) {
      var items = <DropdownMenuItem>[];
      states.forEach((item) {
        items.add(
          DropdownMenuItem(
            value: item.id,
            child: Text(item.name),
          ),
        );
      });
      String? value;

      Object? firstState = states.firstWhereOrNull(
          (o) => o.id.toString() == address!.state.toString());

      if (firstState != null) {
        value = address!.state;
      }

      return DropdownButton(
        items: items,
        value: value,
        onChanged: (dynamic val) {
          setState(() {
            address!.state = val;
          });
        },
        isExpanded: true,
        itemHeight: 70,
        hint: Text(S.of(context).stateProvince),
      );
    } else {
      return TextFormField(
        controller: _stateController,
        autofillHints: [AutofillHints.addressState],
        validator: (val) {
          return val!.isEmpty ? S.of(context).streetIsRequired : null;
        },
        decoration: InputDecoration(labelText: S.of(context).stateProvince),
        onSaved: (String? value) {
          address!.state = value;
        },
      );
    }
  }

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (contextBuilder) => countries!.isEmpty
            ? Theme(
                data: Theme.of(context).copyWith(primaryColor: Colors.pink),
                child: Container(
                  height: 500,
                  child: picker.CountryPickerDialog(
                      titlePadding: const EdgeInsets.all(8.0),
                      contentPadding: const EdgeInsets.all(2.0),
                      searchCursorColor: Colors.pinkAccent,
                      searchInputDecoration:
                          const InputDecoration(hintText: 'Search...'),
                      isSearchable: true,
                      title: Text(S.of(context).country),
                      onValuePicked: (picker_country.Country country) async {
                        _countryController.text = country.isoCode;
                        address!.country = country.isoCode;
                        if (mounted) {
                          setState(() {});
                        }
                        final c =
                            Country(id: country.isoCode, name: country.name);
                        states = await Services().widget.loadStates(c);
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      itemBuilder: (country) {
                        return Row(
                          children: <Widget>[
                            picker.CountryPickerUtils.getDefaultFlagImage(
                                country),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Expanded(child: Text('${country.name}')),
                          ],
                        );
                      }),
                ),
              )
            : Dialog(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      countries!.length,
                      (index) {
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              _countryController.text = countries![index].code!;
                              address!.country = countries![index].id;
                              address!.countryId = countries![index].id;
                            });
                            Navigator.pop(contextBuilder);
                            states = await Services()
                                .widget
                                .loadStates(countries![index]);
                            setState(() {});
                          },
                          child: ListTile(
                            leading: countries![index].icon != null
                                ? Container(
                                    height: 40,
                                    width: 60,
                                    child: Image.network(
                                      countries![index].icon!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : (countries![index].code != null
                                    ? Image.asset(
                                        picker.CountryPickerUtils
                                            .getFlagImageAssetPath(
                                                countries![index].code!),
                                        height: 40,
                                        width: 60,
                                        fit: BoxFit.fill,
                                        package: 'country_pickers',
                                      )
                                    : Container(
                                        height: 40,
                                        width: 60,
                                        child: const Icon(Icons.streetview),
                                      )),
                            title: Text(countries![index].name!),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
      );
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
