import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:quiver/strings.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../services/index.dart';
import '../../entities/address.dart';
import '../../entities/shipping_method.dart';
import '../../entities/user.dart';
import 'cart_mixin.dart';

// void main() => runApp(MyApp());

mixin AddressMixin on CartMixin, ChangeNotifier {
  Address? address;
  ShippingMethod? shippingMethod;

  Future<void> saveShippingAddress(Address? address) async {
    final storage = LocalStorage('fstore');
        try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey['shippingAddress']!, address);
      }
    } catch (_) {}
  }

  Future<Address?> getShippingAddress() async {
    if (Config().isVendorManagerType()) {
      return null;
    }
    final storage = LocalStorage('fstore');
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = storage.getItem(kLocalKey['shippingAddress']!);
        if (json != null) {
          return Address.fromLocalJson(json);
        } else {
          final userJson = storage.getItem(kLocalKey['userInfo']!);

          if (userJson != null) {
            var user = await Services().api.getUserInfo(userJson['cookie']);
            if (user != null) {
              user.isSocial = userJson['isSocial'] ?? false;
            } else {
              user = User.fromLocalJson(userJson);
            }

            if (user.billing == null) {
              final info = await Services().api.getCustomerInfo(user.id)!;
              if (info['billing'] != null) {
                return info['billing'];
              }
            }

            return Address(
              firstName:
                  user.billing != null && user.billing!.firstName!.isNotEmpty
                      ? user.billing!.firstName
                      : user.firstName,
              lastName:
                  user.billing != null && user.billing!.lastName!.isNotEmpty
                      ? user.billing!.lastName
                      : user.lastName,
              email: user.billing != null && user.billing!.email!.isNotEmpty
                  ? user.billing!.email
                  : user.email,
              street: user.billing != null && user.billing!.address1!.isNotEmpty
                  ? user.billing!.address1
                  : '',
              country: user.billing != null && isNotBlank(user.billing!.country)
                  ? user.billing!.country
                  : kPaymentConfig['DefaultCountryISOCode'],
              state: user.billing != null && user.billing!.status!.isNotEmpty
                  ? user.billing!.status
                  : kPaymentConfig['DefaultStateISOCode'],
              phoneNumber:
                  user.billing != null && user.billing!.phone!.isNotEmpty
                      ? user.billing!.phone
                      : '',
              city: user.billing != null && user.billing!.city!.isNotEmpty
                  ? user.billing!.city
                  : '',
              zipCode:
                  user.billing != null && user.billing!.postCode!.isNotEmpty
                      ? user.billing!.postCode
                      : '',

              // My
              cardNumber:
                  user.billing != null && user.billing!.cardNumber!.isNotEmpty
                      ? user.billing!.cardNumber
                      : user.cardNumber ?? '',
              cardCvv: user.billing != null && user.billing!.cvv!.isNotEmpty
                  ? user.billing!.cvv
                  : user.cvv ?? '',
              cardHolderName: user.billing != null &&
                      user.billing!.cardHolderName!.isNotEmpty
                  ? user.billing!.cardHolderName
                  : user.cardHolderName ?? '',
              cardHolderId:
                  user.billing != null && user.billing!.cardHolderId!.isNotEmpty
                      ? user.billing!.cardHolderId
                      : user.cardHolderName ?? '',
              cardExpiryDate:
                  user.billing != null && user.billing!.expiryDate!.isNotEmpty
                      ? user.billing!.expiryDate
                      : user.expiryDate ?? '',
            );
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void setAddress(data) {
    address = data;
    saveShippingAddress(data);
    notifyListeners();
  }

  Future<Address?> getAddress() async {
    address ??= await getShippingAddress();
    // notifyListeners();
    return address;
  }

  double? getShippingCost() {
    if (shippingMethod != null && shippingMethod!.cost! > 0) {
      return shippingMethod!.cost;
    }
    if (shippingMethod != null && isNotBlank(shippingMethod!.classCost)) {
      List items = shippingMethod!.classCost!.split('*');
      String? cost = items[0] != '[qty]' ? items[0] : items[1];
      var shippingCost = cost != null ? double.parse(cost) : 0.0;
      var count = 0;
      productsInCart.keys.forEach((key) {
        count += productsInCart[key]!;
      });
      return shippingCost * count;
    }
    return 0.0;
  }

  void setShippingMethod(data) {
    // print('X $shippingMethod');
    shippingMethod = data;
    notifyListeners();
    // print('X2 $shippingMethod');
  }
}
