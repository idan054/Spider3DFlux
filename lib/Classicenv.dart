// ignore_for_file: prefer_single_quotes, lines_longer_than_80_chars final
Map<String, dynamic> environment = {
  // "appConfig": "https://config-fluxstore-idan054.vercel.app",
  "appConfig": "lib/config/config_he.json",
  "serverConfig": {
    "url": "https://spider3d.co.il",
    "consumerSecret": "cs_79c75a8e1c40acfe530e6254f3cbb61a2e01f872",
    "type": "woo",
    "consumerKey": "ck_be61455d30704ff30718f80b417dd41c320b0cb0"
  },
  "defaultDarkTheme": false,
  "loginSMSConstants": {
    "countryCodeDefault": "IL",
    "dialCodeDefault": "+972",
    "nameDefault": "ישראל"
  },
  "storeIdentifier": {
    "disable": true,
    "android": "com.biton.spider3dflux",
    "ios": "1469772800"
  },
  "advanceConfig": {
    "DefaultLanguage": "he",
    "DetailedBlogLayout": "halfSizeImageType",
    "EnablePointReward": true,
    "hideOutOfStock": false,
    "EnableRating": true,
    "hideEmptyProductListRating": true,
    "EnableShipping": true,
    "EnableSkuSearch": true,
    "showStockStatus": true,
    "GridCount": 3,
    "isCaching": true,
    "kIsResizeImage": false,
    "DefaultCurrency": {
      "symbol": "₪",
      "decimalDigits": 2,
      "symbolBeforeTheNumber": true,
      "currency": "ILS",
      "currencyCode": "ils",
      "smallestUnitRate": 1
    },
    "Currencies": [
      {
        "symbol": "₪",
        "decimalDigits": 2,
        "symbolBeforeTheNumber": true,
        "currency": "ILS",
        "currencyCode": "ils",
        "smallestUnitRate": 1
      }
    ],
    "DefaultStoreViewCode": "",
    "EnableAttributesConfigurableProduct": ["color", "size"],
    "EnableAttributesLabelConfigurableProduct": ["color", "size"],
    "isMultiLanguages": false,
    "EnableApprovedReview": false,
    "EnableSyncCartFromWebsite": false,
    "EnableSyncCartToWebsite": false,
    "EnableShoppingCart": true,
    "EnableFirebase": true,
    "RatioProductImage": 0.8,
    "EnableCouponCode": true,
    "ShowCouponList": true,
    "ShowAllCoupons": true,
    "ShowExpiredCoupons": true,
    "AlwaysShowTabBar": false,
    "PrivacyPoliciesPageId": 25569,
    "QueryRadiusDistance": 10
  },
  "defaultDrawer": {
    "logo": "assets/images/logo.png",
    "background": null,
    "items": [
      {"type": "home", "show": true},
      {"type": "blog", "show": true},
      {"type": "categories", "show": true},
      {"type": "cart", "show": true},
      {"type": "profile", "show": true},
      {"type": "login", "show": true},
      {"type": "category", "show": true}
    ]
  },
  "defaultSettings": [
    "products",
    "chat",
    "wishlist",
    "notifications",
    "language",
    "currencies",
    "darkTheme",
    "order",
    "point",
    "rating",
    "privacy",
    "about"
  ],
  "loginSetting": {
    "IsRequiredLogin": true,
    "showAppleLogin": true,
    "showFacebook": true,
    "showSMSLogin": true,
    "showGoogleLogin": true,
    "showPhoneNumberWhenRegister": false,
    "requirePhoneNumberWhenRegister": false
  },
  "oneSignalKey": {
    "enable": false,
    "appID": "8b45b6db-7421-45e1-85aa-75e597f62714"
  },
  "onBoardingData": [
    {
      "title": "Welcome to FluxStore",
      "image": "assets/images/fogg-delivery-1.png",
      "desc": "Fluxstore is on the way to serve you. "
    },
    {
      "title": "Connect Surrounding World",
      "image": "assets/images/fogg-uploading-1.png",
      "desc":
          "See all things happening around you just by a click in your phone. Fast, convenient and clean."
    },
    {
      "title": "Let's Get Started",
      "image": "fogg-order-completed.png",
      "desc": "Waiting no more, let's see what we get!"
    }
  ],
  "adConfig": {
    "enable": false,
    "facebookTestingId": "",
    "googleTestingId": ["123", "457"],
    "ads": [
      {
        "type": "banner",
        "provider": "google",
        "iosId": "ca-app-pub-3940256099942544/2934735716",
        "androidId": "ca-app-pub-3940256099942544/6300978111",
        "showOnScreens": ["home", "search"],
        "hideOnScreens": []
      },
      {
        "type": "banner",
        "provider": "google",
        "iosId": "ca-app-pub-2101182411274198/5418791562",
        "androidId": "ca-app-pub-2101182411274198/4052745095",
        "hideOnScreens": []
      },
      {
        "type": "interstitial",
        "provider": "google",
        "iosId": "ca-app-pub-3940256099942544/4411468910",
        "androidId": "ca-app-pub-3940256099942544/4411468910",
        "hideOnScreens": []
      },
      {
        "type": "reward",
        "provider": "google",
        "iosId": "ca-app-pub-3940256099942544/1712485313",
        "androidId": "ca-app-pub-3940256099942544/4411468910",
        "hideOnScreens": []
      },
      {
        "type": "banner",
        "provider": "facebook",
        "iosId": "IMG_16_9_APP_INSTALL#430258564493822_876131259906548",
        "androidId": "IMG_16_9_APP_INSTALL#430258564493822_489007588618919",
        "hideOnScreens": []
      },
      {
        "type": "interstitial",
        "provider": "facebook",
        "iosId": "430258564493822_489092398610438",
        "androidId": "IMG_16_9_APP_INSTALL#430258564493822_489092398610438",
        "hideOnScreens": []
      }
    ]
  },
  "firebaseDynamicLinkConfig": {
    "isEnabled": true,
    "uriPrefix": "https://fluxstoreinspireui.page.link",
    "link": "https://mstore.io/",
    "androidPackageName": "com.biton.spider3dflux",
    "androidAppMinimumVersion": 1,
    "iOSBundleId": "com.biton.spider3dflux",
    "iOSAppMinimumVersion": "1.0.1",
    "iOSAppStoreId": "1469772800"
  },
  "languagesInfo": [
    {
      "name": "English",
      "icon": "assets/images/country/gb.png",
      "code": "en",
      "text": "English",
      "storeViewCode": ""
    },
    {
      "name": "Chinese",
      "icon": "assets/images/country/zh.png",
      "code": "zh",
      "text": "Chinese",
      "storeViewCode": ""
    },
    {
      "name": "Hindi",
      "icon": "assets/images/country/in.png",
      "code": "hi",
      "text": "Hindi",
      "storeViewCode": "hi"
    },
    {
      "name": "Spanish",
      "icon": "assets/images/country/es.png",
      "code": "es",
      "text": "Spanish",
      "storeViewCode": ""
    },
    {
      "name": "French",
      "icon": "assets/images/country/fr.png",
      "code": "fr",
      "text": "French",
      "storeViewCode": "fr"
    },
    {
      "name": "Arabic",
      "icon": "assets/images/country/ar.png",
      "code": "ar",
      "text": "Arabic",
      "storeViewCode": "ar"
    },
    {
      "name": "Russian",
      "icon": "assets/images/country/ru.png",
      "code": "ru",
      "text": "Русский",
      "storeViewCode": "ru"
    },
    {
      "name": "Indonesian",
      "icon": "assets/images/country/id.png",
      "code": "id",
      "text": "Indonesian",
      "storeViewCode": "id"
    },
    {
      "name": "Japanese",
      "icon": "assets/images/country/ja.png",
      "code": "ja",
      "text": "Japanese",
      "storeViewCode": ""
    },
    {
      "name": "Korean",
      "icon": "assets/images/country/kr.png",
      "code": "kr",
      "text": "Korean",
      "storeViewCode": "kr"
    },
    {
      "name": "Vietnamese",
      "icon": "assets/images/country/vn.png",
      "code": "vi",
      "text": "Vietnam",
      "storeViewCode": ""
    },
    {
      "name": "Romanian",
      "icon": "assets/images/country/ro.png",
      "code": "ro",
      "text": "Romanian",
      "storeViewCode": "ro"
    },
    {
      "name": "Turkish",
      "icon": "assets/images/country/tr.png",
      "code": "tr",
      "text": "Turkish",
      "storeViewCode": "tr"
    },
    {
      "name": "Italian",
      "icon": "assets/images/country/it.png",
      "code": "it",
      "text": "Italian",
      "storeViewCode": "it"
    },
    {
      "name": "German",
      "icon": "assets/images/country/de.png",
      "code": "de",
      "text": "German",
      "storeViewCode": "de"
    },
    {
      "name": "Portuguese",
      "icon": "assets/images/country/br.png",
      "code": "pt",
      "text": "Portuguese",
      "storeViewCode": "pt"
    },
    {
      "name": "Hungarian",
      "icon": "assets/images/country/hu.png",
      "code": "hu",
      "text": "Hungarian",
      "storeViewCode": "hu"
    },
    {
      "name": "Hebrew",
      "icon": "assets/images/country/he.png",
      "code": "he",
      "text": "Hebrew",
      "storeViewCode": "he"
    },
    {
      "name": "Thai",
      "icon": "assets/images/country/th.png",
      "code": "th",
      "text": "Thai",
      "storeViewCode": "th"
    },
    {
      "name": "Dutch",
      "icon": "assets/images/country/nl.png",
      "code": "nl",
      "text": "Dutch",
      "storeViewCode": "nl"
    },
    {
      "name": "Serbian",
      "icon": "assets/images/country/sr.png",
      "code": "sr",
      "text": "Serbian",
      "storeViewCode": "sr"
    },
    {
      "name": "Polish",
      "icon": "assets/images/country/pl.png",
      "code": "pl",
      "text": "Polish",
      "storeViewCode": "pl"
    },
    {
      "name": "Persian",
      "icon": "assets/images/country/fa.png",
      "code": "fa",
      "text": "Persian",
      "storeViewCode": ""
    },
    {
      "name": "Kurdish",
      "icon": "assets/images/country/ku.png",
      "code": "ku",
      "text": "Kurdish",
      "storeViewCode": "ku"
    }
  ],
  "unsupportedLanguages": ["ku"],
  "paymentConfig": {
    "DefaultCountryISOCode": "IL",
    "DefaultStateISOCode": "IL",
    "EnableShipping": true,
    "EnableAddress": true,
    "EnableCustomerNote": true,
    "EnableAddressLocationNote": false,
    "EnableAlphanumericZipCode": false,
    "EnableReview": true,
    "allowSearchingAddress": true,
    "GuestCheckout": false,
    "EnableOnePageCheckout": true,
    "NativeOnePageCheckout": true,
    "CheckoutPageSlug": {"il": "checkout", "en": "checkout"},
    "EnableCreditCard": true,
    "UpdateOrderStatus": true,
    "ShowOrderNotes": true,
    "EnableRefundCancel": false
  },
  "payments": {
    "paypal": "assets/icons/payment/paypal.png",
    "stripe": "assets/icons/payment/stripe.png",
    "razorpay": "assets/icons/payment/razorpay.png",
    "tap": "assets/icons/payment/tap.png"
  },
  "stripeConfig": {
    "serverEndpoint": "https://stripe-server.vercel.app",
    "publishableKey": "pk_test_MOl5vYzj1GiFnRsqpAIHxZJl",
    "enabled": true,
    "paymentMethodId": "stripe",
    "returnUrl": "fluxstore://inspireui.com",
    "enableManualCapture": false
  },
  "paypalConfig": {
    "clientId":
        "ASlpjFreiGp3gggRKo6YzXMyGM6-NwndBAQ707k6z3-WkSSMTPDfEFmNmky6dBX00lik8wKdToWiJj5w",
    "secret":
        "ECbFREri7NFj64FI_9WzS6A0Az2DqNLrVokBo0ZBu4enHZKMKOvX45v9Y1NBPKFr6QJv2KaSp5vk5A1G",
    "production": false,
    "paymentMethodId": "paypal",
    "enabled": true
  },
  "razorpayConfig": {
    "keyId": "rzp_test_SDo2WKBNQXDk5Y",
    "keySecret": "RrgfT3oxbJdaeHSzvuzaJRZf",
    "paymentMethodId": "razorpay",
    "enabled": true
  },
  "tapConfig": {
    "SecretKey": "sk_test_XKokBfNWv6FIYuTMg5sLPjhJ",
    "paymentMethodId": "tap",
    "enabled": true
  },
  "mercadoPagoConfig": {
    "accessToken":
        "TEST-5726912977510261-102413-65873095dc5b0a877969b7f6ffcceee4-613803978",
    "production": false,
    "paymentMethodId": "woo-mercado-pago-basic",
    "enabled": true
  },
  "defaultCountryShipping": [
    {
      "name": "Israel",
      "iosCode": "IL",
      "icon":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Flag_of_Israel.svg/1024px-Flag_of_Israel.svg.png"
    }
  ],
  "afterShip": {
    "api": "e2e9bae8-ee39-46a9-a084-781d0139274f",
    "tracking_url": "https://fluxstore.aftership.com"
  },
  "productDetail": {
    "height": 0.4074788912168983,
    "marginTop": 0.0,
    "safeArea": false,
    "showVideo": true,
    "showBrand": true,
    "showThumbnailAtLeast": 1,
    "layout": "halfSizeImageType",
    "borderRadius": 3.0,
    "enableReview": true,
    "attributeImagesSize": 50.0,
    "showSku": false,
    "showStockQuantity": true,
    "showProductCategories": true,
    "showProductTags": true,
    "hideInvalidAttributes": false
  },
  "productVariantLayout": {
    "color": "color",
    "size": "box",
    "height": "option",
    "color-image": "image"
  },
  "productAddons": {
    "allowImageType": true,
    "allowVideoType": true,
    "allowCustomType": true,
    "allowedCustomType": ["png", "pdf", "docx"],
    "allowMultiple": false,
    "fileUploadSizeLimit": 5.0
  },
  "cartDetail": {"minAllowTotalCartValue": 0, "maxAllowQuantity": 10},
  "productVariantLanguage": {
    "en": {
      "color": "Color",
      "size": "Size",
      "height": "Height",
      "color-image": "Color"
    },
    "ar": {
      "color": "اللون",
      "size": "بحجم",
      "height": "ارتفاع",
      "color-image": "اللون"
    },
    "vi": {
      "color": "Màu",
      "size": "Kích thước",
      "height": "Chiều Cao",
      "color-image": "Màu"
    }
  },
  "excludedCategory": 311, // Needs to be [311] to work ,
  "saleOffProduct": {"ShowCountDown": true, "Color": "#C7222B"},
  "notStrictVisibleVariant": true,
  "configChat": {
    "EnableSmartChat": true,
    "showOnScreens": ["profile"],
    "hideOnScreens": []
  },
  "smartChat": [
    {"app": "https://wa.me/972522509900", "iconData": "whatsapp"},
    {"app": "tel:0522509900", "iconData": "phone"},
    {"app": "http://m.me/spider3d.co.il", "iconData": "facebookMessenger"}
  ],
  "adminEmail": "info@spider3d.co.il",
  "adminName": "Eyal Spider3D",
  "vendorConfig": {
    "VendorRegister": true,
    "DisableVendorShipping": false,
    "ShowAllVendorMarkers": true,
    "DisableNativeStoreManagement": false,
    "dokan": "my-account?vendor_admin=true",
    "wcfm": "store-manager?vendor_admin=true"
  },
  "loadingIcon": {"size": 30.0, "type": "fadingCube"},
  "productCard": {
    "hidePrice": false,
    "hideStore": false,
    "hideTitle": false,
    "borderRadius": 3.0,
    "boxFit": "cover",
    "boxShadow": {
      "x": 0.9945842328787625,
      "y": 0.9737681350443407,
      "blurRadius": 3.027428745696925
    }
  }
};
