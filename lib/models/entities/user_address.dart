class Shipping {
  String? firstName;
  String? lastName;
  String? company;
  String? address1;
  String? address2;
  String? city;
  String? postCode;
  String? country;
  String? state;

  Map<String, dynamic> toJson(){
    return {
      "first_name" : firstName,
      "last_name" : lastName,
      "company" : company,
      "address_1" : address1,
      "address_2" : address2,
      "city" : city,
      "postcode" : postCode,
      "country" : country,
      "state" : state
    };
  }

  Shipping.fromJson(Map<String, dynamic> json) {
    try {
      firstName = json['first_name'];
      lastName = json['last_name'];
      company = json['company'];
      address1 = json['address_1'];
      address2 = json['address_2'];
      city = json['city'];
      postCode = json['postcode'];
      country = json['country'];
      state = json['state'];
    } catch (_) {}
  }
}

class Billing {
  String? firstName;
  String? lastName;
  String? company;
  String? address1;
  String? address2;
  String? city;
  String? postCode;
  String? country;
  String? status;
  String? email;
  String? phone;

  // My
  String? cardNumber;
  String? cardHolderName;
  String? cardHolderId;
  String? expiryDate;
  String? cvv;

  Billing.fromJson(Map<String, dynamic> json) {
    try {
      firstName = json['first_name'];
      lastName = json['last_name'];
      company = json['company'];
      address1 = json['address_1'];
      address2 = json['address_2'];
      city = json['city'];
      postCode = json['postcode'];
      country = json['country'];
      status = json['state'];
      email = json['email'];
      phone = json['phone'];

      // My
      cardNumber = json['cardNumber'];
      cardHolderName = json['cardHolderName'];
      cardHolderId = json['cardHolderId'];
      expiryDate = json['expiryDate'];
      cvv = json['cvv'];
    } catch (_) {}
  }
}
