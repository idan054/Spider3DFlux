import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/index.dart' show AppModel, Product;
import '../../../services/index.dart';
import '../../../widgets/product/product_card_view.dart';
import '../helper/helper.dart';
import 'vertical_simple_list.dart';

class VerticalViewLayout extends StatefulWidget {
  final config;

  VerticalViewLayout({this.config, Key? key}) : super(key: key);

  @override
  _PinterestLayoutState createState() => _PinterestLayoutState();
}

class _PinterestLayoutState extends State<VerticalViewLayout> {
  final Services _service = Services();
  List<Product> _products = [];
  bool canLoad = true;
  int _page = 0;

  void _loadProduct() async {
    var config = widget.config;
    _page = _page + 1;
    config['page'] = _page;
    if (!canLoad) return;
    var newProducts = await _service.api.fetchProductsLayout(
        config: config,
        lang: Provider.of<AppModel>(context, listen: false).langCode);
    if (newProducts == null || newProducts.isEmpty) {
      setState(() {
        canLoad = false;
      });
    }
    if (newProducts != null && newProducts.isNotEmpty) {
      setState(() {
        _products = [..._products, ...newProducts];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  Widget build(BuildContext context) {
    var widthContent = 0;
    final isTablet = Helper.isTablet(MediaQuery.of(context));

    if (widget.config['layout'] == 'card') {
      widthContent = 1; //one column
    } else if (widget.config['layout'] == 'columns') {
      widthContent = isTablet ? 4 : 3; //three columns
    } else {
      //layout is list
      widthContent = isTablet ? 3 : 2; //two columns
    }
    // ignore: division_optimization
    // var rows = (_products.length / widthContent).toInt(); // my comment
    var rows = 2;
    if (rows * widthContent < _products.length) rows++;

    var loadingPadding = 75.0;
    // var item_limit = _products.length < 6 ? _products.length : 6; // my max is 6
    var item_limit = _products.length; // my max is 6
    return Column(
      children: [
        ListView.builder(
            // cacheExtent: 1500500,
            cacheExtent: 1500,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: item_limit,
            itemBuilder: (context, index) {
              if (widget.config['layout'] == 'list') {
                return SimpleListView(
                  item: _products[index],
                  type: SimpleListType.BackgroundColor,
                );
              }
              return Row(
                children: List.generate(widthContent, (child) {
                  return Expanded(
                    // child: index * widthContent + child < _products.length
                    child: index * widthContent + child < item_limit
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              return ProductCard(
                                item: _products[index * widthContent + child],
                                showHeart: true,
                                // showCart: widget.config['layout'] != 'columns', // Original
                                showCart: true,
                                width: constraints.maxWidth,
                              );
                            },
                          )
                        : Container(),
                  );
                }),
              );
            }),

/*        VisibilityDetector(
          key: const Key('loading_vertical'),
          onVisibilityChanged: (VisibilityInfo info) => _loadProduct(),
          child: // Vertival limit to 6 by Var item_limit
*/ /*          canLoad
              ? Padding(
                  padding: EdgeInsets.only(bottom: loadingPadding),
                  child: const Builder(
                    builder: kLoadingWidget,
                  ),
                )
              : */ /*
              Center(
            child: Padding(
              padding: EdgeInsets.only(
                  top: loadingPadding / 5,
                  left: loadingPadding,
                  bottom: loadingPadding,
                  right: loadingPadding),
              child: Divider(
                thickness: 2,
                // height: 20,
                color: Theme.of(context).primaryColor.withOpacity(0.70),
              ),
            ),
          ),
        )*/
        Center(
          child: Padding(
            padding: EdgeInsets.only(
                top: loadingPadding / 5,
                left: loadingPadding,
                bottom: loadingPadding,
                right: loadingPadding),
            child: Divider(
              thickness: 1.5,
              // height: 20,
              color: Theme.of(context).primaryColor.withOpacity(0.60),
            ),
          ),
        ),
      ],
    );
  }
}
