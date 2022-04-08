import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/app_model.dart';
import '../../modules/dynamic_layout/config/logo_config.dart';
import '../../modules/dynamic_layout/dynamic_layout.dart';
import '../../modules/dynamic_layout/logo/logo.dart';
import '../../modules/dynamic_layout/vertical/vertical.dart';
import '../../screens/blog/models/list_blog_model.dart';
import 'preview_overlay.dart';

var myVertical_config;

class HomeLayout extends StatefulWidget {
  final configs;
  final bool isPinAppBar;
  final bool isShowAppbar;

  HomeLayout({
    this.configs,
    this.isPinAppBar = false,
    this.isShowAppbar = true,
    Key? key,
  }) : super(key: key);

  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late List widgetData;

  bool isPreviewingAppBar = false;

  @override
  void initState() {
    /// init config data
    widgetData =
        List<Map<String, dynamic>>.from(widget.configs['HorizonLayout']);
    if (widgetData.isNotEmpty && widget.isShowAppbar) {
      widgetData.removeAt(0);
    }

    /// init single vertical layout
    if (widget.configs['VerticalLayout'] != null &&
        widget.configs['VerticalLayout'].isNotEmpty) {
      Map verticalData =
          Map<String, dynamic>.from(widget.configs['VerticalLayout']);
      verticalData['type'] = 'vertical';
      widgetData.add(verticalData);
    }

    /// init multi vertical layout
    if (widget.configs['VerticalLayouts'] != null) {
      List verticalLayouts = widget.configs['VerticalLayouts'];
      for (var i = 0; i < verticalLayouts.length; i++) {
        Map verticalData = verticalLayouts[i];
        verticalData['type'] = 'vertical';
        widgetData.add(verticalData);
      }
    }


      // below is my
      print('A data');
      // appConfig = await
      // Provider.of<AppModel>(context, listen: false).loadAppConfig()
      //     .then((data) => print('B data ${data?.toJson()}'));
      print('C data');

    super.initState();
  }

  @override
  void didUpdateWidget(HomeLayout oldWidget) {
    if (oldWidget.configs != widget.configs) {
      /// init config data
      List data =
          List<Map<String, dynamic>>.from(widget.configs['HorizonLayout']);
      if (data.isNotEmpty && widget.isShowAppbar) {
        data.removeAt(0);
      }

      /// init vertical layout
      if (widget.configs['VerticalLayout'] != null) {
        Map verticalData =
            Map<String, dynamic>.from(widget.configs['VerticalLayout']);
        verticalData['type'] = 'vertical';
        data.add(verticalData);
      }
      setState(() {
        widgetData = data;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  SliverAppBar renderAppBar() {
    List<dynamic> horizonLayout = widget.configs['HorizonLayout'] ?? [];
    Map logoConfig = horizonLayout.firstWhere(
        (element) => element['layout'] == 'logo',
        orElse: () => Map<String, dynamic>.from({}));
    var config = LogoConfig.fromJson(logoConfig);

    /// customize theme
    // config
    //   ..opacity = 0.9
    //   ..iconBackground = HexColor('DDDDDD')
    //   ..iconColor = HexColor('330000')
    //   ..iconOpacity = 0.8
    //   ..iconRadius = 40
    //   ..iconSize = 24
    //   ..cartIcon = MenuIcon(name: 'cart')
    //   ..showSearch = false
    //   ..showLogo = true
    //   ..showCart = true
    //   ..showMenu = true;

    return SliverAppBar(
      brightness: Theme.of(context).brightness,
      pinned: widget.isPinAppBar,
      snap: true,
      floating: true,
      titleSpacing: 0,
      elevation: 5,
      forceElevated: true,
      backgroundColor: config.color ??
          Theme.of(context).backgroundColor.withOpacity(config.opacity),
      title: PreviewOverlay(
          index: 0,
          config: logoConfig as Map<String, dynamic>?,
          builder: (value) {
            final appModel = Provider.of<AppModel>(context, listen: true);
            return Logo(
              key: value['key'] != null ? Key(value['key']) : UniqueKey(),
              config: config,
              logo: appModel.themeConfig.logo,
              onSearch: () =>
                  Navigator.of(context).pushNamed(RouteList.homeSearch),
              onTapDrawerMenu: () => NavigateTools.onTapOpenDrawerMenu(context),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.configs == null) return Container();

    ErrorWidget.builder = (error) {
      if (kReleaseMode) {
        return Container();
      }
      return Container(
        constraints: const BoxConstraints(minHeight: 150),
        decoration: BoxDecoration(
            color: Colors.lightBlue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5)),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

        /// Hide error, if you're developer, enable it to fix error it has
        child: Center(
          child: Text('Error in ${error.exceptionAsString()}'),
        ),
      );
    };

    return CustomScrollView(
      // cacheExtent: 2000.0,
      cacheExtent: 1500.0,
      slivers: [
        if (widget.isShowAppbar) renderAppBar(),
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await Provider.of<ListBlogModel>(context, listen: false).getBlogs();
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              var config = widgetData[index];
              // print('widgetData[index] ${widgetData[index]}');

              /// if show app bar, the preview should plus +1
              var previewIndex = widget.isShowAppbar ? index + 1 : index;

              if (config['type'] != null && config['type'] == 'vertical') {
                return PreviewOverlay(
                  index: previewIndex,
                  config: config,
                  builder: (value) {
                    // value = config = {key: r09jo0owu6, layout: menu, name: קטגוריות מובילות, isVertical: true, type: vertical}
                    // print("config XXX: ");
                    // print(config);
                    myVertical_config = config;
                    return VerticalLayout(
                      config: value,
                      key: value['key'] != null ? Key(value['key']) : null,
                    );
                  },
                );
              }

              return PreviewOverlay(
                index: previewIndex,
                config: config,
                builder: (_config) {
                  // print('PreviewOverlay _config $_config');
                  return DynamicLayout(_config);
                },
              );
            },
            childCount: widgetData.length,
          ),
        ),
      ],
    );
  }
}
