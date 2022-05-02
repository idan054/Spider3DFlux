import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links2/uni_links.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/app_model.dart';
import '../../models/user_model.dart';
import '../../modules/dynamic_layout/index.dart';
import '../../modules/firebase/firebase_service.dart';
import '../../services/index.dart';
import '../../widgets/home/index.dart';
import '../../widgets/home/preview_reload.dart';
import '../../widgets/home/wrap_status_bar.dart';
import '../base_screen.dart';
import 'deeplink_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends BaseScreen<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;

  Uri? _latestUri;
  StreamSubscription? _sub;
  int? itemId;

  @override
  void dispose() {
    printLog('[Home] dispose');
    _sub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    printLog('[Home] initState');
    initPlatformState();
    super.initState();
  }

  Future<void> initPlatformState() async {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      await initPlatformStateForStringUniLinks();
    }
  }

  Future<void> initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream
    _sub = linkStream.listen((String? link) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
        try {
          if (link != null) _latestUri = Uri.parse(link);
          setState(() {
            itemId = int.parse(_latestUri!.path.split('/')[1]);
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDeepLink(
                itemId: itemId,
              ),
            ),
          );
        } on FormatException {
          printLog('[initPlatformStateForStringUniLinks] error');
        }
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
      });
    });

    linkStream.listen((String? link) {
      printLog('got link: $link');
    }, onError: (err) {
      printLog('got err: $err');
    });
  }



  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    Future.delayed(
        const Duration(seconds: 1),
        () => Tools.changeStatusBarColor(
            Provider.of<AppModel>(context, listen: false).themeMode));

    /// init dynamic link
    Services().firebase.initDynamicLinkService(context);

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    printLog('[Home] build');
    return Consumer<AppModel>(
      builder: (context, value, child) {
        if (value.appConfig == null) {
          return kLoadingWidget(context);
        }

        return PreviewReload(
          configs: value.appConfig!.jsonData,
          builder: (json) {
            var isStickyHeader = value.appConfig!.settings.stickyHeader;
            var appConfig = AppConfig.fromJson(json);

            return Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              body: Stack(
                children: <Widget>[
                  if (appConfig.background != null)
                    isStickyHeader
                        ? SafeArea(
                            child: HomeBackground(config: appConfig.background),
                          )
                        : HomeBackground(config: appConfig.background),
                  HomeLayout(
                    isPinAppBar: isStickyHeader,
                    isShowAppbar: json['HorizonLayout'][0]['layout'] == 'logo',
                    configs: json,
                    key: UniqueKey(),
                  ),
                  if (Config().isBuilder) const WrapStatusBar(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
