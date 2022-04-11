import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/app_model.dart';
import '../../models/category_model.dart';
import '../../models/filter_attribute_model.dart';
import '../../models/filter_tags_model.dart';
import '../../models/search_model.dart';
import '../../models/user_model.dart';
import 'widgets/filters/filter_search.dart';
import 'widgets/recent/recent_search_custom.dart';
import 'widgets/search_box.dart';
import 'widgets/search_results_custom.dart';

class SearchScreen extends StatefulWidget {
  final isModal;
  final bool? showChat;

  SearchScreen({Key? key, this.isModal, this.showChat}) : super(key: key);

  @override
  _StateSearchScreen createState() => _StateSearchScreen();
}

class _StateSearchScreen extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin<SearchScreen> {
  @override
  bool get wantKeepAlive => true;

  final _searchFieldNode = FocusNode();
  final _searchFieldController = TextEditingController();

  bool isVisibleSearch = false;
  bool _showResult = false;
  List<String>? _suggestSearch;

  SearchModel get _searchModel =>
      Provider.of<SearchModel>(context, listen: false);

  String get _searchKeyword => _searchFieldController.text;

  List<String> get suggestSearch =>
      _suggestSearch
          ?.where((s) => s.toLowerCase().contains(_searchKeyword.toLowerCase()))
          .toList() ??
      <String>[];

  void _onFocusChange() {
    if (_searchKeyword.isEmpty && !_searchFieldNode.hasFocus) {
      _showResult = false;
    } else {
      _showResult = !_searchFieldNode.hasFocus;
    }

    // Delayed keyboard hide and show
    Future.delayed(const Duration(milliseconds: 120), () {
      setState(() {
        isVisibleSearch = _searchFieldNode.hasFocus;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    printLog('[SearchScreen] initState');
    _searchFieldNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    printLog('[SearchScreen] dispose');
    _searchFieldNode.dispose();
    _searchFieldController.dispose();
    super.dispose();
  }

  void _onSearchTextChange(String value) {
    print('_onSearchTextChange()');
    if (value.isEmpty) {
      _showResult = false;
      setState(() {});
      return;
    }
    if (_searchFieldNode.hasFocus) {
      if (suggestSearch.isEmpty) {
        final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
        setState(() {
          _showResult = true;
          _searchModel.loadProduct(name: value, userId: _userId);
        });
      } else {
        setState(() {
          _showResult = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    printLog('[SearchScreen] build');
    super.build(context);
    _suggestSearch =
        Provider.of<AppModel>(context).appConfig!.searchSuggestion ?? [''];
    final screenSize = MediaQuery.of(context).size;
    // double widthSearchBox =
    //     screenSize.width / (2 / (screenSize.height / screenSize.width));
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: _renderAppbar(screenSize),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _renderHeader(),
            SearchBox(
              // width: widthSearchBox,
              controller: _searchFieldController,
              focusNode: _searchFieldNode,
              onChanged: _onSearchTextChange,
              onSubmitted: _onSubmit,
              onCancel: () {
                setState(() {
                  isVisibleSearch = false;
                });
              },
            ),
            // My hidden filter
            Visibility(
              visible: false,
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, top: 8),
                  child: Container(
                    height: 32,
                    child: FilterSearch(
                      onChange: (searchFilter) {
                        _searchModel.searchByFilter(
                          searchFilter,
                          _searchKeyword,
                          userId: _userId,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                reverseDuration: const Duration(milliseconds: 300),
                child: _showResult
                    ? buildResult()
                    : Align(
                        alignment: Alignment.topCenter,
                        child: Consumer<FilterTagModel>(
                          builder: (context, tagModel, child) {
                            return Consumer<CategoryModel>(
                              builder: (context, categoryModel, child) {
                                return Consumer<FilterAttributeModel>(
                                  builder: (context, attributeModel, child) {
                                    if (tagModel.isLoading ||
                                        categoryModel.isLoading ||
                                        attributeModel.isLoading) {
                                      return kLoadingWidget(context);
                                    }
                                    var child = _buildRecentSearch();

                                    if (_searchFieldNode.hasFocus &&
                                        suggestSearch.isNotEmpty) {
                                      child = _buildSuggestions();
                                    }

                                    return child;
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget? _renderAppbar(Size screenSize) {
    if (widget.isModal != null) {
      return AppBar(
        brightness: Theme.of(context).brightness,
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 22,
          ),
        ),
        title: Container(
          width: screenSize.width,
          child: Container(
            width:
                screenSize.width / (2 / (screenSize.height / screenSize.width)),
            child: Text(
              S.of(context).search,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    return null;
  }

  Widget _renderHeader() {
    final screenSize = MediaQuery.of(context).size;
    Widget _headerContent = const SizedBox(height: 10.0);
    if (widget.isModal == null) {
      _headerContent = AnimatedContainer(
        height: isVisibleSearch ? 0.1 : 58,
        padding: const EdgeInsets.only(
          left: 12,
          top: 5,
          bottom: 5,
        ),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              S.of(context).search,
              style: Theme.of(context).textTheme.headline4!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
      child: _headerContent,
    );
  }

  Widget _buildRecentSearch() {
    return RecentSearchesCustom(onTap: _onSubmit);
  }

  Widget _buildSuggestions() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).primaryColorLight,
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        itemCount: suggestSearch.length,
        itemBuilder: (_, index) {
          final keyword = suggestSearch[index];
          return GestureDetector(
            onTap: () => _onSubmit(keyword),
            child: ListTile(
              title: Text(keyword),
            ),
          );
        },
      ),
    );
  }

  Widget buildResult() {
    return SearchResultsCustom(
      name: _searchKeyword,
    );
  }

  void _onSubmit(String name) {
    _searchFieldController.text = name;
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
    setState(() {
      _showResult = true;
      _searchModel.loadProduct(name: name, userId: _userId);
    });
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
