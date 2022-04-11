// ignore_for_file: omit_local_variable_types

import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart' show StoryWidget;
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import 'banner/banner_animate_items.dart';
import 'banner/banner_group_items.dart';
import 'banner/banner_slider.dart';
import 'blog/blog_grid.dart';
import 'category/category_icon.dart';
import 'category/category_image.dart';
import 'category/category_text.dart';
import 'config/index.dart';
import 'header/header_search.dart';
import 'header/header_text.dart';
import 'logo/logo.dart';
import 'product/product_list.dart';
import 'product/product_list_large_card.dart';
import 'product/product_list_simple.dart';
import 'video/index.dart';

var myRecentView_config;

class DynamicLayout extends StatelessWidget {
  final config;

  const DynamicLayout(this.config);

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context, listen: true);

    // print('config file? $config');

    switch (config['layout']) {
      // region others
      case 'logo':
        final themeConfig = appModel.themeConfig;
        return Logo(
          config: LogoConfig.fromJson(config),
          logo: themeConfig.logo,
          key: config['key'] != null ? Key(config['key']) : UniqueKey(),
          onSearch: () => Navigator.of(context).pushNamed(RouteList.homeSearch),
          onTapDrawerMenu: () => NavigateTools.onTapOpenDrawerMenu(context),
        );

      case 'header_text':
        return HeaderText(
          config: HeaderConfig.fromJson(config),
          onSearch: () => Navigator.of(context).pushNamed(RouteList.homeSearch),
          key: config['key'] != null ? Key(config['key']) : UniqueKey(),
        );

      case 'header_search':
        if (kIsWeb) return Container();
        return HeaderSearch(
          config: HeaderConfig.fromJson(config),
          onSearch: () {
            Navigator.of(App.fluxStoreNavigatorKey.currentContext!)
                .pushNamed(RouteList.homeSearch);
          },
          key: config['key'] != null ? Key(config['key']) : UniqueKey(),
        );
      case 'featuredVendors':
        return Services().widget.renderFeatureVendor(config);
      case 'category':
        if (config['type'] == 'image') {
          return CategoryImages(
            config: CategoryConfig.fromJson(config),
            key: config['key'] != null ? Key(config['key']) : UniqueKey(),
          );
        }
        return Consumer<CategoryModel>(builder: (context, model, child) {
          var _config = CategoryConfig.fromJson(config);
          var _listCategoryName =
              model.categoryList.map((key, value) => MapEntry(key, value.name));
          var _onShowProductList = (CategoryItemConfig item) {
            ProductModel.showList(
              config: item.jsonData,
              context: context,
              products: item.data != null ? item.data as List<Product> : [],
            );
          };

          if (config['type'] == 'text') {
            return CategoryTexts(
              config: _config,
              listCategoryName: _listCategoryName,
              onShowProductList: _onShowProductList,
              key: config['key'] != null ? Key(config['key']) : UniqueKey(),
            );
          }

          return CategoryIcons(
            config: _config,
            listCategoryName: _listCategoryName,
            onShowProductList: _onShowProductList,
            key: config['key'] != null ? Key(config['key']) : UniqueKey(),
          );
        });
      case 'bannerAnimated':
        if (kIsWeb) return Container();
        return BannerAnimated(
          config: BannerConfig.fromJson(config),
          key: config['key'] != null ? Key(config['key']) : UniqueKey(),
        );
    // endregion others
      case 'bannerImage':
        if (config['isSlider'] == true) {
          var _myConfig =  BannerConfig.fromJson(config);
          // print('_myConfig.toJson()'); // theres 3 (Sets)
          // print(_myConfig.toJson()); // theres 3 (Sets)
          // because i Add 3 'bannerImage' to config_he.json

          // _myConfig.items = [_myConfig.items.first, _myConfig.items.first];
          return BannerSlider(
              config: _myConfig, // original
              // config: config,
              onTap: (itemConfig) {
                NavigateTools.onTapNavigateOptions(
                  context: context,
                  config: itemConfig,
                );
              },
              key: config['key'] != null ? Key(config['key']) : UniqueKey());
        }

        return BannerGroupItems(
          config: BannerConfig.fromJson(config),
          onTap: (itemConfig) {
            NavigateTools.onTapNavigateOptions(
              context: context,
              config: itemConfig,
            );
          },
          key: config['key'] != null ? Key(config['key']) : UniqueKey(),
        );

      case 'blog':
        return BlogGrid(
          config: config,
          key: config['key'] != null ? Key(config['key']) : UniqueKey(),
        );

      case 'video':
        return VideoLayout(
          config: config,
          key: config['key'] != null ? Key(config['key']) : UniqueKey(),
        );

      case 'story':
        return StoryWidget(
          config: config,
          onTapStoryText: (cfg) {
            NavigateTools.onTapNavigateOptions(context: context, config: cfg);
          },
        );
      case 'fourColumn':
      case 'threeColumn':
      case 'twoColumn':
      case 'staggered':
      case 'saleOff':
      case 'card':
      case 'listTile':

        // print("config XXX Key: ");
        // print(config['key']);
        // print("config XXX: ");
        // print(config);
        // print("config XXX Type: ");
        // print(config.runtimeType);

        return ProductList(
          config: ProductConfig.fromJson(config),
          key: config['key'] != null ? Key(config['key']) : UniqueKey(),
        );

      case 'recentView':
        // To set recentView on product page. (my)
        myRecentView_config =
            config; // Sample result: {name: Recent View, layout: recentView}
        if (config['onMainPage']) {
          return ProductList(
            config: ProductConfig.fromJson(config),
            key: config['key'] != null ? Key(config['key']) : UniqueKey(),
          );
        }
        return Container(); // (if 'onMainPage' is actually false)

      /// new product layout stylev
      case 'largeCardHorizontalListItems':
      case 'largeCard':
        return ProductListLargeCard(
          config: ProductConfig.fromJson(config),
          key: config['key'] != null ? Key(config['key']) : UniqueKey(),
        );

      case 'simpleVerticalListItems':
      case 'simpleList':
        return SimpleVerticalProductList(
          config: ProductConfig.fromJson(config),
          key: config['key'] != null ? Key(config['key']) : UniqueKey(),
        );

      default:
        return const SizedBox();
    }
  }
}
