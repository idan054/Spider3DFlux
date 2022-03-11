import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart'
    show AppModel, Category, CategoryModel, Product, UserModel;
import '../../../services/index.dart';

class MenuLayout extends StatefulWidget {
  final config;

  MenuLayout({this.config});

  @override
  _StateMenuLayout createState() => _StateMenuLayout();
}

class _StateMenuLayout extends State<MenuLayout> {
  int position = 0;
  bool loading = true;
  Map<String, dynamic> productMap = <String, dynamic>{};
  final ScrollController _controller = ScrollController();
  final StreamController productController = StreamController<List<Product>?>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> getAllListProducts({
    minPrice,
    maxPrice,
    orderBy,
    order,
    lang,
    page = 1,
    required category,
  }) async {
    var _service = Services();
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
    try {
      setState(() {
        loading = true;
      });
      List<dynamic>? productList = [];
      if (productMap[category.id.toString()] != null) {
        productList = productMap[category.id.toString()];
      } else {
        productList = await _service.api.fetchProductsByCategory(
          categoryId: category.id,
          minPrice: minPrice,
          maxPrice: maxPrice,
          orderBy: orderBy,
          order: order,
          lang: lang,
          page: page,
          userId: _userId,
        );
      }
      productMap.update(category.id.toString(), (value) => productList,
          ifAbsent: () => productList);
      productController.add(productList);
      setState(() {
        loading = false;
      });
    } catch (e) {
      productController.add([]);
      setState(() {
        loading = false;
      });
    }
  }

  List<Category>? getAllCategory() {
    final categories =
        Provider.of<CategoryModel>(context, listen: true).myIncluded_categories;
    if (categories == null) return null;
    var listCategories =
        categories.where((item) => item.parent == '0').toList();
    var _categories = <Category>[];

    for (var category in listCategories) {
      var children = categories.where((o) => o.parent == category.id).toList();
      if (children.isNotEmpty) {
        _categories = [..._categories, ...children];
      } else {
        _categories = [..._categories, category];
      }
    }
    if (loading == true && _categories.isNotEmpty) {
      getAllListProducts(
          category: _categories[position],
          lang: Provider.of<AppModel>(context, listen: false).langCode);
    }
    return _categories;
  }

  @override
  Widget build(BuildContext context) {
    var categories = getAllCategory();
    if (categories == null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: kLoadingWidget(context),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Container(
          height: 50,
          padding: const EdgeInsets.only(top: 15),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(categories.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    position = index;
                    // print(categories);
                  });
                  getAllListProducts(
                      // category: categories[index], // All categories
                      category: categories[index],
                      lang: Provider.of<AppModel>(context, listen: false)
                          .langCode);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          categories[index].name!.toUpperCase(),
                          style: TextStyle(
                              color: index == position
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).accentColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      index == position
                          ? Container(
                              height: 4,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).primaryColor),
                              width: 20,
                            )
                          : Container()
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        StreamBuilder(
          stream: productController.stream,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: LayoutBuilder(builder: (context, constraints) {
                if (loading) {
                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 4,
                    // key: Key(categories[position].id.toString()),
                    key: UniqueKey(), // My
                    shrinkWrap: true,
                    controller: _controller,
                    itemCount: 4,
                    itemBuilder: (context, value) {
                      return Services().widget.renderProductCardView(
                            item: Product.empty(value.toString()),
                            width: MediaQuery.of(context).size.width / 2,
                          );
                    },
                    staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
                  );
                }
                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    controller: _controller,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, value) {
                      return Services().widget.renderProductCardView(
                            item: snapshot.data[value],
                            showCart: true,
                            showHeart: true,
                            width: constraints.maxWidth / 2,
                          );
                    },
                    staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
                  );
                }
                return Container(
                  height: MediaQuery.of(context).size.width / 2,
                  child: Center(
                    child: Text(S.of(context).noProduct),
                  ),
                );
              }),
            );
          },
        )
      ],
    );
  }
}
