import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show AppModel, Product, SearchModel;
import '../../../services/index.dart';
import '../vertical/vertical_simple_list.dart';

class SearchResults extends StatefulWidget {
  final String name;
  final List<Product>? products;

  const SearchResults({required this.name, this.products});

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  final _refreshController = RefreshController();
  final _service = Services();

  List<Product>? _products;
  int _page = 1;
  bool _isEnd = false;

  Future<void> _loadProduct() async {
    var newProducts = await _service.api.searchProducts(
      name: widget.name,
      page: _page,
      lang: Provider.of<AppModel>(context, listen: false).langCode,
    )!;
    print('search_result.dart - newProducts $newProducts');

    if (newProducts.isEmpty) {
      _isEnd = true;
    } else {
      _products ??= [];
      _products!.addAll(newProducts);
      Provider.of<SearchModel>(context, listen: false)
          .refreshProduct(_products);
    }
    setState(() {});
  }

  Future<void> _onRefresh() async {
    _page = 1;
    _products = [];
    await _loadProduct();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    if (_isEnd == false) {
      _page++;
      await _loadProduct();
    }
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    _products = widget.products;
  }

  @override
  void didUpdateWidget(SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _products = widget.products;
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_products == null) {
      return kLoadingWidget(context);
    }

    if (_products!.isEmpty) {
      return Center(
        child: Text(S.of(context).noProduct),
      );
    }

    return SmartRefresher(
      header: MaterialClassicHeader(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      controller: _refreshController,
      enablePullUp: !_isEnd,
      enablePullDown: false,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      footer: kCustomFooter(context),
      child: ListView.builder(
        itemCount: _products?.length,
        itemBuilder: (context, index) {
          final product = _products![index];
          return SimpleListView(item: product);
        },
      ),
    );
  }
}
