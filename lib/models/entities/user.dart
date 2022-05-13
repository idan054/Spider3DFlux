import 'package:flutter/cupertino.dart';

import '../../common/constants.dart';
import '../serializers/user.dart';
import 'user_address.dart';

class User {
  String? id;
  bool? loggedIn;
  String? name;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  String? nicename;
  String? userUrl;
  String? picture;
  String? cookie;
  Shipping? shipping;
  Billing? billing;
  String? jwtToken;
  bool isVender = false;
  bool? isSocial = false;

  // My
  String? cardNumber;
  String? cardHolderName;
  String? cardHolderId;
  String? expiryDate;
  String? cvv;
  
  // my Allow mannual edit
  User({
    this.id,
    this.loggedIn,
    this.name,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.nicename,
    this.userUrl,
    this.picture,
    this.cookie,
    this.shipping,
    this.billing,
    this.jwtToken,
    this.isVender = false,
    this.isSocial = false,

    // My
    this.cardNumber,
    this.cardHolderName,
    this.cardHolderId,
    this.expiryDate,
    this.cvv,
  });

  String get fullName => [firstName ?? '', lastName ?? ''].join(' ');

  ///FluxListing
  String? role;

  // from WooCommerce Json
  User.fromWooJson(Map<String, dynamic> json) {
    try {
      var user = json['user'];
      isSocial = true;
      loggedIn = true;
      id = json['wp_user_id'].toString();
      name = user['displayname'];
      cookie = json['cookie'];
      username = user['username'];
      nicename = user['nicename'];
      firstName = user['firstname'];
      lastName = user['lastname'];
      email = user['email'] ?? id;
      isSocial = true;
      userUrl = user['avatar'];
      var roles = user['role'] as List;
      var role = roles.firstWhere(
          (item) => ((item == 'seller') ||
              (item == 'wcfm_vendor') ||
              (item == 'administrator')),
          orElse: () => null);
      if (role != null) {
        isVender = true;
      } else {
        isVender = false;
      }

      if (user['dokan_enable_selling'] != null &&
          user['dokan_enable_selling'].toString().isNotEmpty) {
        isVender = user['dokan_enable_selling'] == 'yes';
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  User.fromJson(Map<String, dynamic> json) {
    try {
      isSocial = json['isSocial'] ?? false;
      loggedIn = json['loggedIn'];
      id = json['id'].toString();
      cookie = json['cookie'];
      username = json['username'];
      nicename = json['nicename'];
      firstName = json['firstName'];
      lastName = json['lastName'];
      name = json['displayname'] ??
          json['displayName'] ??
          '${firstName ?? ''}${(lastName?.isEmpty ?? true) ? '' : ' $lastName'}';
      ;
      email = json['email'] ?? id;
      userUrl = json['avatar'];
    } catch (e) {
      printLog(e.toString());
    }
  }

  // from Magento Json
  User.fromMagentoJson(Map<String, dynamic> json, token) {
    try {
      loggedIn = true;
      id = json['id'].toString();
      name = json['firstname'] + ' ' + json['lastname'];
      username = '';
      cookie = token;
      firstName = json['firstname'];
      lastName = json['lastname'];
      email = json['email'];
      picture = '';
    } catch (e) {
      printLog(e.toString());
    }
  }

  // from Opencart Json
  User.fromOpencartJson(Map<String, dynamic> json, token) {
    try {
      loggedIn = true;
      id = (json['customer_id'] != null ? int.parse(json['customer_id']) : 0)
          .toString();
      name = json['firstname'] + ' ' + json['lastname'];
      username = '';
      cookie = token;
      firstName = json['firstname'];
      lastName = json['lastname'];
      email = json['email'];
      picture = '';
    } catch (e) {
      printLog(e.toString());
    }
  }

  // from Shopify json
  User.fromShopifyJson(Map<String, dynamic> json, token) {
    try {
      printLog('fromShopifyJson user $json');

      loggedIn = true;
      id = json['id'].toString();
      username = '';
      cookie = token;
      firstName = json['firstName'];
      lastName = json['lastName'];
      name = json['displayName'] ?? json['displayname'] ?? _getDisplayName;
      email = json['email'];
      picture = '';
    } catch (e) {
      printLog(e.toString());
    }
  }

  User.fromPrestaJson(Map<String, dynamic> json) {
    try {
      printLog('fromPresta user $json');

      loggedIn = true;
      id = json['id'].toString();
      name = json['firstname'] + ' ' + json['lastname'];
      username = json['email'];
      cookie = json['secure_key'];
      firstName = json['firstname'];
      lastName = json['lastname'];
      email = json['email'];
    } catch (e) {
      printLog(e.toString());
    }
  }

  User.fromStrapi(Map<String, dynamic> parsedJson) {
    debugPrint('User.fromStrapi $parsedJson');
    loggedIn = true;

    var model = SerializerUser.fromJson(parsedJson);
    id = model.user!.id.toString();
    jwtToken = model.jwt;
    email = model.user!.email;
    username = model.user!.username;
    nicename = model.user!.displayName;
  }

  User.fromListingJson(Map<String, dynamic> json) {
    try {
      id = json['id'].toString();
      name = json['displayname'] ?? '';
      username = json['username'] ?? '';
      firstName = json['firstname'] ?? '';
      lastName = json['lastname'] ?? '';
      cookie = json['cookie'] ?? '';
      email = json['email'] ?? '';
      role = json['role'][0] ?? '';
      picture = json['avatar'] ?? '';
      shipping = Shipping.fromJson(json['shipping']);
      billing = Billing.fromJson(json['billing']);
      loggedIn = true;
    } catch (e) {
      printLog(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loggedIn': loggedIn,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'picture': picture,
      'cookie': cookie,
      'nicename': nicename,
      'url': userUrl,
      'isSocial': isSocial,
      'isVender': isVender,
      'shipping' : shipping != null ? shipping?.toJson() : null,
    };
  }

  User.fromLocalJson(Map<String, dynamic> json) {
    try {
      loggedIn = json['loggedIn'];
      id = json['id'].toString();
      name = json['name'];
      cookie = json['cookie'];
      username = json['username'];
      firstName = json['firstName'];
      lastName = json['lastName'];
      email = json['email'];
      picture = json['picture'];
      nicename = json['nicename'];
      userUrl = json['url'];
      isSocial = json['isSocial'];
      isVender = json['isVender'];
      if (json['shipping'] != null) {
        shipping = Shipping.fromJson(json['shipping']);
      }
      // if (json['billing'] != null) {
      //   billing = Billing.fromJson(json['billing']);
      // }
    } catch (e) {
      printLog(e.toString());
    }
  }

  // from Create User
  User.fromAuthUser(Map<String, dynamic> json, String? _cookie) {
    try {
      cookie = _cookie;
      id = json['id'].toString();
      name = json['displayname'];
      username = json['username'];
      firstName = json['firstname'];
      lastName = json['lastname'];
      email = json['email'];
      picture = json['avatar'];
      nicename = json['nicename'];
      userUrl = json['url'];
      loggedIn = true;
      var roles = json['role'] as List;
      isVender = false;
      if (roles.isNotEmpty) {
        if (roles.contains('seller') ||
            roles.contains('wcfm_vendor') ||
            roles.contains('administrator')) {
          isVender = true;
        }
      } else {
        isVender = (json['capabilities']['wcfm_vendor'] as bool?) ?? false;
      }
      if (json['dokan_enable_selling'] != null &&
          json['dokan_enable_selling'].trim().isNotEmpty) {
        isVender = json['dokan_enable_selling'] == 'yes';
      }
      if (json['shipping'] != null) {
        shipping = Shipping.fromJson(json['shipping']);
      }
      if (json['billing'] != null) {
        billing = Billing.fromJson(json['billing']);
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  String get _getDisplayName =>
      '${firstName ?? ''}${(lastName?.isEmpty ?? true) ? '' : ' $lastName'}';

  @override
  String toString() => 'User { username: $id $name $email}';
  
}

class UserPoints {
  int? points;
  List<UserEvent> events = [];

  UserPoints.fromJson(Map<String, dynamic> json) {
    points = json['points_balance'];

    if (json['events'] != null) {
      for (var event in json['events']) {
        events.add(UserEvent.fromJson(event));
      }
    }
  }
}

class UserEvent {
  String? id;
  String? userId;
  String? orderId;
  String? date;
  String? description;
  String? points;

  UserEvent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderId = json['order_id'];
    date = json['date_display_human'];
    description = json['description'];
    points = json['points'];
  }
}
