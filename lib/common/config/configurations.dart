part of '../config.dart';

class Configurations {
  static late dynamic _remoteConfig;
  static String _environment = DefaultConfig.environment;
  static String _baseUrl = DefaultConfig.baseUrl;
  static String _appName = DefaultConfig.app_name;
  static bool _enableCrashAnalytics = DefaultConfig.enableCrashAnalytics;
  static String _defaultLanguage = DefaultConfig.defaultLanguage;
  static Map _serverConfig = DefaultConfig.serverConfig;
  static String _appConfig = DefaultConfig.appConfig;
  static bool _defaultDarkTheme = DefaultConfig.defaultDarkTheme;
  static String _countryCodeDefault = DefaultConfig.countryCodeDefault;
  static String _dialCodeDefault = DefaultConfig.dialCodeDefault;
  static String _nameDefault = DefaultConfig.nameDefault;
  static Map _advanceConfig = DefaultConfig.advanceConfig;
  static Map _storeIdentifier = DefaultConfig.storeIdentifier;
  static List _defaultSettings = DefaultConfig.defaultSettings;
  static Map _loginSetting = DefaultConfig.loginSetting;
  static Map _defaultDrawer = DefaultConfig.defaultDrawer;
  static Map _oneSignalKey = DefaultConfig.oneSignalKey;
  static List _onBoardingData = DefaultConfig.onBoardingData;
  static Map _productDetail = DefaultConfig.productDetail;
  static Map _productVariantLayout = DefaultConfig.productVariantLayout;
  static Map _adConfig = DefaultConfig.adConfig;
  static Map _firebaseDynamicLinkConfig =
      DefaultConfig.firebaseDynamicLinkConfig;
  static List<Map> _languagesInfo = DefaultConfig.languagesInfo;
  static List<String> _unsupportedLanguages =
      DefaultConfig.unsupportedLanguages;
  static Map _paymentConfig = DefaultConfig.paymentConfig;
  static Map _payments = DefaultConfig.payments;
  static Map _stripeConfig = DefaultConfig.stripeConfig;
  static Map _paypalConfig = DefaultConfig.paypalConfig;
  static Map _razorpayConfig = DefaultConfig.razorpayConfig;
  static Map _tapConfig = DefaultConfig.tapConfig;
  static Map _mercadoPagoConfig = DefaultConfig.mercadoPagoConfig;
  static Map _afterShip = DefaultConfig.afterShip;
  static Map _productAddons = DefaultConfig.productAddons;
  static Map _cartDetail = DefaultConfig.cartDetail;
  static Map _productVariantLanguage = DefaultConfig.productVariantLanguage;
  static Map _saleOffProduct = DefaultConfig.saleOffProduct;
  static List _excludedCategory = DefaultConfig.excludedCategory;
  static bool _notStrictVisibleVariant = DefaultConfig.notStrictVisibleVariant;
  static Map _configChat = DefaultConfig.configChat;
  static List<Map> _smartChat = DefaultConfig.smartChat;
  static String _adminEmail = DefaultConfig.adminEmail;
  static String _adminName = DefaultConfig.adminName;
  static Map _vendorConfig = DefaultConfig.vendorConfig;
  static List _defaultCountryShipping = DefaultConfig.defaultCountryShipping;
  static Map? _loadingIcon = DefaultConfig.loadingIcon;
  static Map _productCard = DefaultConfig.productCard;
  static Map _loginSMSConstants = DefaultConfig.loginSMSConstants;
  static Map _darkConfig = DefaultConfig.darkConfig;
  static Map _lightConfig = DefaultConfig.lightConfig;

  static String get environments => _environment;

  static String get baseUrl => _baseUrl;

  static String get appName => _appName;

  static bool get enableCrashAnalytics => _enableCrashAnalytics;

  static String get defaultLanguage => _defaultLanguage;

  static Map get serverConfig => _serverConfig;

  static String get appConfig => _appConfig;

  static bool get defaultDarkTheme => _defaultDarkTheme;

  static String get countryCodeDefault => _countryCodeDefault;

  static String get dialCodeDefault => _dialCodeDefault;

  static String get nameDefault => _nameDefault;

  static Map get advanceConfig => _advanceConfig;

  static Map get storeIdentifier => _storeIdentifier;

  static List get defaultSettings => _defaultSettings;

  static Map get loginSetting => _loginSetting;

  static Map get defaultDrawer => _defaultDrawer;

  static Map get oneSignalKey => _oneSignalKey;

  static List get onBoardingData => _onBoardingData;

  static Map get productDetail => _productDetail;

  static Map get productVariantLayout => _productVariantLayout;

  static Map get adConfig => _adConfig;

  static Map get firebaseDynamicLinkConfig => _firebaseDynamicLinkConfig;

  static List<Map> get languagesInfo => _languagesInfo;

  static List<String> get unsupportedLanguages => _unsupportedLanguages;

  static Map get paymentConfig => _paymentConfig;

  static Map get payments => _payments;

  static Map get stripeConfig => _stripeConfig;

  static Map get paypalConfig => _paypalConfig;

  static Map get razorpayConfig => _razorpayConfig;

  static Map get tapConfig => _tapConfig;

  static Map get mercadoPagoConfig => _mercadoPagoConfig;

  static Map get afterShip => _afterShip;

  static Map get productAddons => _productAddons;

  static Map get cartDetail => _cartDetail;

  static Map get productVariantLanguage => _productVariantLanguage;

  static Map get saleOffProduct => _saleOffProduct;

  static List get excludedCategory => _excludedCategory;

  static bool get notStrictVisibleVariant => _notStrictVisibleVariant;

  static Map get configChat => _configChat;

  static List<Map> get smartChat => _smartChat;

  static String get adminEmail => _adminEmail;

  static String get adminName => _adminName;

  static Map get vendorConfig => _vendorConfig;

  static List get defaultCountryShipping => _defaultCountryShipping;

  static Map? get loadingIcon => _loadingIcon;

  static Map get productCard => _productCard;

  static Map get loginSMSConstants => _loginSMSConstants;

  static Map get darkConfig => _darkConfig;

  static Map get lightConfig => _lightConfig;

  void setConfigurationValues(Map<String, dynamic> value) {
    _environment = value['environment'] ?? DefaultConfig.environment;
    _baseUrl = value['baseUrl'] ?? DefaultConfig.baseUrl;
    _appName = value['app_name'] ?? DefaultConfig.app_name;
    _enableCrashAnalytics =
        value['enableCrashAnalytics'] ?? DefaultConfig.enableCrashAnalytics;
    _defaultLanguage =
        value['defaultLanguage'] ?? DefaultConfig.defaultLanguage;
    _appConfig = value['appConfig'] ?? DefaultConfig.appConfig;
    _serverConfig = value['serverConfig'] ?? DefaultConfig.serverConfig;
    _defaultDarkTheme =
        value['defaultDarkTheme'] ?? DefaultConfig.defaultDarkTheme;
    _storeIdentifier =
        value['storeIdentifier'] ?? DefaultConfig.storeIdentifier;
    _advanceConfig = value['advanceConfig'] != null
        ? ConfigurationUtils.loadAdvanceConfig(value['advanceConfig'])
        : DefaultConfig.advanceConfig;
    _countryCodeDefault = DefaultConfig.countryCodeDefault;
    _dialCodeDefault = DefaultConfig.dialCodeDefault;
    _nameDefault = DefaultConfig.nameDefault;
    _defaultSettings =
        value['defaultSettings'] ?? DefaultConfig.defaultSettings;
    _loginSetting = value['loginSetting'] ?? DefaultConfig.loginSetting;
    _defaultDrawer = value['defaultDrawer'] ?? DefaultConfig.defaultDrawer;
    _oneSignalKey = value['oneSignalKey'] ?? DefaultConfig.oneSignalKey;
    _onBoardingData = value['onBoardingData'] ?? DefaultConfig.onBoardingData;
    _productDetail = value['productDetail'] ?? DefaultConfig.productDetail;
    _productVariantLayout =
        value['productVariantLayout'] ?? DefaultConfig.productVariantLayout;
    _adConfig = value['adConfig'] ?? DefaultConfig.adConfig;
    _firebaseDynamicLinkConfig = value['firebaseDynamicLinkConfig'] ??
        DefaultConfig.firebaseDynamicLinkConfig;
    _languagesInfo =
        List<Map>.from(value['languagesInfo'] ?? DefaultConfig.languagesInfo);
    _unsupportedLanguages = List<String>.from(
        value['unsupportedLanguages'] ?? DefaultConfig.unsupportedLanguages);
    _paymentConfig = value['paymentConfig'] ?? DefaultConfig.paymentConfig;
    _payments = value['payments'] ?? DefaultConfig.payments;
    _stripeConfig = value['stripeConfig'] ?? DefaultConfig.stripeConfig;
    _paypalConfig = value['paypalConfig'] ?? DefaultConfig.paypalConfig;
    _razorpayConfig = value['razorpayConfig'] ?? DefaultConfig.razorpayConfig;
    _tapConfig = value['tapConfig'] ?? DefaultConfig.tapConfig;
    _mercadoPagoConfig =
        value['mercadoPagoConfig'] ?? DefaultConfig.mercadoPagoConfig;
    _afterShip = value['afterShip'] ?? DefaultConfig.afterShip;
    _productAddons = value['productAddons'] ?? DefaultConfig.productAddons;
    _cartDetail = value['cartDetail'] ?? DefaultConfig.cartDetail;
    _productVariantLanguage =
        value['productVariantLanguage'] ?? DefaultConfig.productVariantLanguage;
    _saleOffProduct = value['saleOffProduct'] ?? DefaultConfig.saleOffProduct;
    _excludedCategory =
        value['excludedCategory'] ?? DefaultConfig.excludedCategory;
    _notStrictVisibleVariant = value['notStrictVisibleVariant'] ??
        DefaultConfig.notStrictVisibleVariant;
    _configChat = value['configChat'] ?? DefaultConfig.configChat;
    _smartChat = ConfigurationUtils.loadSmartChat(
        List<Map>.from(value['smartChat'] ?? DefaultConfig.smartChat));
    _adminEmail = value['adminEmail'] ?? DefaultConfig.adminEmail;
    _adminName = value['adminName'] ?? DefaultConfig.adminName;
    _vendorConfig = value['vendorConfig'] ?? DefaultConfig.vendorConfig;
    _defaultCountryShipping =
        value['defaultCountryShipping'] ?? DefaultConfig.defaultCountryShipping;

    _loadingIcon = value['loadingIcon'] ?? DefaultConfig.loadingIcon;
    _productCard = value['productCard'] ?? DefaultConfig.productCard;
    _loginSMSConstants =
        value['loginSMSConstants'] ?? DefaultConfig.loginSMSConstants;
    _darkConfig = value['darkConfig'] ?? DefaultConfig.darkConfig;
    _lightConfig = value['lightConfig'] ?? DefaultConfig.lightConfig;
  }

  void _loadConfig(String key) {
    switch (key) {
      case 'appConfig':
        _appConfig = _remoteConfig.getString(appConfig);
        print('_appConfig - $_appConfig');
        break;
      case 'serverConfig':
        _serverConfig = jsonDecode(_remoteConfig.getString('serverConfig')) ??
            _serverConfig;
        break;
      default:
    }
  }

  final _listConfigRemoteKey = [
    'appConfig',
    'serverConfig',
    'defaultDarkTheme',
    'storeIdentifier',
    'advanceConfig',
    'defaultDrawer',
    'defaultSettings',
    'loginSetting',
    'oneSignalKey',
    'onBoardingData',
    'adConfig',
    'firebaseDynamicLinkConfig',
    'languagesInfo',
    'unsupportedLanguages',
    'paymentConfig',
    'payments',
    'stripeConfig',
    'paypalConfig',
    'razorpayConfig',
    'tapConfig',
    'mercadoPagoConfig',
    'afterShip',
    'productDetail',
    'productVariantLayout',
    'productAddons',
    'cartDetail',
    'productVariantLanguage',
    'excludedCategory',
    'saleOffProduct',
    'notStrictVisibleVariant',
    'configChat',
    'smartChat',
    'adminEmail',
    'adminName',
    'vendorConfig',
    'loadingIcon'
  ];
}

extension ConfigurationsFireBaseRemoteConfig on Configurations {
  Future<void> loadRemoteConfig() async {
    Services().firebase.loadRemoteConfig(
        onUpdate: () => _listConfigRemoteKey.forEach(_loadConfig));
  }
}
