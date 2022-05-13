import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

import '../../common/constants.dart';
import '../../common/tools/image_tools.dart';
import '../../models/entities/user.dart';
import '../../services/index.dart';

enum UserUpdateState { loading, loaded }

class UserUpdateModel extends ChangeNotifier {

  var state = UserUpdateState.loaded;
  final _service = Services();

  TextEditingController userEmail = TextEditingController();
  TextEditingController userPassword = TextEditingController();
  TextEditingController userDisplayName = TextEditingController();
  TextEditingController userFirstName = TextEditingController();
  TextEditingController userLastName = TextEditingController();
  TextEditingController userUrl = TextEditingController();
  TextEditingController userPhone = TextEditingController();
  TextEditingController currentPassword = TextEditingController();

  TextEditingController shippingCompany = TextEditingController();
  TextEditingController shippingAddress1 = TextEditingController();
  TextEditingController shippingAddress2 = TextEditingController();
  TextEditingController shippingCity = TextEditingController();
  TextEditingController shippingPostcode = TextEditingController();
  TextEditingController shippingCountry = TextEditingController();
  TextEditingController shippingState = TextEditingController();

  dynamic avatar;
  final User? _user;

  UserUpdateModel(this._user) {
    _initAllController();
  }

  void _initAllController() {
    userEmail.text = _user!.email!;
    userDisplayName.text = _user!.name!;
    userFirstName.text = _user!.firstName!;
    userLastName.text = _user!.lastName!;

    avatar = _user!.picture;

    shippingAddress1.text = _user!.shipping?.address1 ?? '';
    shippingAddress2.text = _user!.shipping?.address2 ?? '';
    shippingCity.text = _user!.shipping?.city ?? '';
    shippingPostcode.text = _user!.shipping?.postCode ?? '';
    shippingState.text = _user!.shipping?.state ?? '';
    shippingCountry.text = _user!.shipping?.country ?? '';
    shippingCompany.text = _user!.shipping?.company ?? '';
  }

  void _updateState(state) {
    this.state = state;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void selectImage() async {
    List<Asset>? resultList;

    try {
      resultList =
          await MultiImagePicker.pickImages(maxImages: 1, enableCamera: true);
    } on Exception catch (e) {
      printLog(e);
    }
    if (resultList != null && resultList.isNotEmpty) {
      avatar = null;
      avatar = resultList.first;
    }
    _updateState(UserUpdateState.loaded);
  }

  Future<Map<dynamic, dynamic>?> updateProfile() async {
    _updateState(UserUpdateState.loading);

    var data = {
      'display_name': userDisplayName.text.trim().isEmpty
          ? _user!.name
          : userDisplayName.text,
      'first_name': userFirstName.text.trim().isEmpty
          ? _user!.firstName
          : userFirstName.text,
      'last_name': userLastName.text.trim().isEmpty
          ? _user!.lastName
          : userLastName.text,
      'shipping_address_1': shippingAddress1.text.trim().isEmpty
          ? _user!.shipping?.address1 ?? ''
          : shippingAddress1.text,
      'shipping_address_2': shippingAddress2.text.trim().isEmpty
          ? _user!.shipping?.address2 ?? ''
          : shippingAddress2.text,
      'shipping_city': shippingCity.text.trim().isEmpty
          ? _user!.shipping?.city ?? ''
          : shippingCity.text,
      'shipping_company': shippingCompany.text.trim().isEmpty
          ? _user!.shipping?.company ?? ''
          : shippingCompany.text,
      'shipping_country': shippingCountry.text.trim().isEmpty
          ? _user!.shipping?.country ?? ''
          : shippingCountry.text,
      'shipping_state': shippingState.text.trim().isEmpty
          ? _user!.shipping?.state ?? ''
          : shippingState.text,
      'shipping_postcode': shippingPostcode.text.trim().isEmpty
          ? _user!.shipping?.postCode ?? ''
          : shippingPostcode.text,
    };

    if (avatar is Asset) {
      var preparedImage = await ImageTools.compressImage(avatar);
      data['avatar'] = preparedImage.replaceAll(',', '');
    }
    final json = await _service.api.updateUserInfo(data, _user!.cookie);

    _updateState(UserUpdateState.loaded);
    return json;
  }
}
