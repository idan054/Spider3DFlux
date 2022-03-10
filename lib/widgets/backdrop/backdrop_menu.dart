import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../common/tools/adaptive_tools.dart';
import '../../generated/l10n.dart';
import '../../models/entities/listing_location.dart';
import '../../models/index.dart'
// XX
    show
        AppModel,
        Category,
        CategoryModel,
        FilterAttribute,
        FilterAttributeModel,
        ProductModel,
        TagModel;
import '../../models/listing/listing_location_model.dart';
import '../../services/service_config.dart';
import '../common/tree_view.dart';
import 'category_item.dart';
import 'filter_option_item.dart';
import 'location_item.dart';

class BackdropMenu extends StatefulWidget {
  final Function? onFilter;
  final String? categoryId;
  final String? tagId;
  final String? listingLocationId;

  const BackdropMenu({
    Key? key,
    this.onFilter,
    this.categoryId,
    this.tagId,
    this.listingLocationId,
  }) : super(key: key);

  @override
  _BackdropMenuState createState() => _BackdropMenuState();
}

class _BackdropMenuState extends State<BackdropMenu> {
  double minPrice = 0.0;
  double maxPrice = kMaxPriceFilter / 2;

  // double maxPrice = myMaxPriceFilter / 2;
  String? categoryId = '-1';
  String? tagId = '-1';
  String? currentSlug;
  String? listingLocationId;
  int currentSelectedAttr = -1;
  bool isPrintersCategory = false;

  @override
  void initState() {
    categoryId = widget.categoryId;
    setState(() {
      // kMaxPriceFilter = 1000.0;
      if (categoryId == '2341') {
        isPrintersCategory = true;
        kMaxPriceFilter = 10000.0;
        maxPrice = kMaxPriceFilter / 2;
      }
      print('kMaxPriceFilter $kMaxPriceFilter');
      print('maxPrice $maxPrice');
      print('categoryId $categoryId');
      print('categoryId ${categoryId.runtimeType}');
    });
    // print('myMaxPriceFilter $myMaxPriceFilter');
    // print('maxPrice $maxPrice');
    tagId = widget.tagId;
    listingLocationId = widget.listingLocationId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final category = Provider.of<CategoryModel>(context);
    final tag = Provider.of<TagModel>(context);
    final selectLayout = Provider.of<AppModel>(context).productListLayout;
    final currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final filterAttr = Provider.of<FilterAttributeModel>(context);
    var maxPrice_str = PriceTools.getCurrencyFormatted(maxPrice, currencyRate,
        currency: currency)!;
    var minPrice_str = PriceTools.getCurrencyFormatted(minPrice, currencyRate,
        currency: currency)!;

    late List<ListingLocation> locations;
    if (Config().isListingType) {
      locations =
          Provider.of<ListingLocationModel>(context, listen: false).locations;
      listingLocationId = Provider.of<ProductModel>(context).listingLocationId;
    }
    categoryId = Provider.of<ProductModel>(context).categoryId;

    Function _onFilter =
        (categoryId, tagId, {listingLocationId}) => widget.onFilter!(
              minPrice: minPrice,
              maxPrice: maxPrice,
              categoryId: categoryId,
              tagId: tagId,
              attribute: currentSlug,
              currentSelectedTerms: filterAttr.lstCurrentSelectedTerms,
              listingLocationId: listingLocationId ?? this.listingLocationId,
            );

    return ListenableProvider.value(
      value: category,
      child: Consumer<CategoryModel>(
        builder: (context, catModel, _) {
          if (catModel.isLoading) {
            printLog('Loading');
            return Center(child: Container(child: kLoadingWidget(context)));
          }

          if (catModel.categories != null) {
            // print('catModel.categories');
            // for (var x in catModel.categories!) {
            //   print(x);
            //   print(x.parent);
            // }

            // My Rec Category menu change categories place (Root or Sub category)
            catModel.categories!.forEach((element) {
              switch (element.name) {
                case 'מותג Spider3D USA': // .id = 4782
                  print("'Spider USA': Root -> 'חומרי גלם להדפסה'");
                  element.parent = '2352';
                  break;

                case 'חלקי חילוף מקוריים לארטילרי': // .id 5161
                  print(
                      "'חלקי חילוף מקוריים לארטילרי': Root -> 'שדרוגים וחלפים למדפסות'");
                  element.parent = '2342';
                  break;
              }
            });

            var rootCategories = catModel.categories!
                .where((item) => item.parent == '0')
                .toList();

            // My Filter order
            void replaceInList(List list, a, b) {
              // Define values places
              var list_len = list.length;
              var a_index = list.indexOf(a);
              var b_index = list.indexOf(b);

              // Add (1) Value if not in list
              if (a_index == -1) list.add(a); // AKA null
              if (b_index == -1) list.add(b);

              // Redefine values places
              a_index = list.indexOf(a);
              b_index = list.indexOf(b);

              // Switch between their places
              list.insert(a_index, b); // means .addAt
              list.removeAt(a_index + 1);

              list.insert(b_index, a); // means .addAt
              list.removeAt(b_index + 1);

              // Remove rest unnecessary value if left
              if (list_len != list.length) list.removeAt(list.length - 1);
            }

            // print('value.lstProductAttribute!');
            // print(filterAttr.lstProductAttribute!.length);
            var myOrderFilters = filterAttr.lstProductAttribute;

            // My Replace places of values in the list (A,B,C -> B,A,C), At Least 1 value should be in list!

            var forIndex = 0;
            // if (1 == 1) return categories;
            for (var item in filterAttr.lstProductAttribute!) {
              switch (item.name) {
                case 'סוג פילמנט':
                  replaceInList(myOrderFilters!, myOrderFilters[forIndex],
                      myOrderFilters[0]);
                  forIndex++;
                  break;
                case 'צבע':
                  item.name = 'צבע פילמנט';
                  replaceInList(myOrderFilters!, myOrderFilters[forIndex],
                      myOrderFilters[2]);
                  forIndex++;
                  break;
                case 'מותג':
                  replaceInList(myOrderFilters!, myOrderFilters[forIndex],
                      myOrderFilters[1]);
                  forIndex++;
                  break;
                case 'מצב':
                  item.name = 'מצב פילמנט';
                  replaceInList(myOrderFilters!, myOrderFilters[forIndex],
                      myOrderFilters[3]);
                  forIndex++;
                  break;
                case 'שטח הדפסה':
                  replaceInList(myOrderFilters!, myOrderFilters[forIndex],
                      myOrderFilters[4]);
                  forIndex++;
                  break;
                case 'מבנה גוף מדפסת':
                  replaceInList(myOrderFilters!, myOrderFilters[forIndex],
                      myOrderFilters[5]);
                  forIndex++;
                  break;
                case 'שיטת כיול':
                  replaceInList(myOrderFilters!, myOrderFilters[forIndex],
                      myOrderFilters[6]);
                  forIndex++;
                  break;
                default:
                  // print('$forIndex');
                  forIndex++;
                // print(forIndex);
              }
            }
            // myOrderFilters = myOrderFilters?.sublist(0,forIndex);
            // filterAttr.lstProductAttribute = myOrderFilters;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  isDisplayDesktop(context)
                      ? SizedBox(
                          height: 100,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () {
                                  if (isDisplayDesktop(context)) {
                                    eventBus
                                        .fire(const EventOpenCustomDrawer());
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: const Icon(Icons.arrow_back_ios,
                                    size: 22, color: Colors.white70),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                S.of(context).products,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 10),

                  // Layout title & selection
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 15),
                  //   child: Text(
                  //     S.of(context).layout.toUpperCase(),
                  //     style: Theme.of(context).textTheme.subtitle1!.copyWith(
                  //           fontWeight: FontWeight.w700,
                  //           color: Colors.white,
                  //         ),
                  //   ),
                  // ),
                  // const SizedBox(height: 5.0),
                  // Wrap(
                  //   children: <Widget>[
                  //     const SizedBox(width: 8),
                  //     for (var item in kProductListLayout)
                  //       Tooltip(
                  //         message: item['layout']!,
                  //         child: GestureDetector(
                  //           onTap: () =>
                  //               Provider.of<AppModel>(context, listen: false)
                  //                   .updateProductListLayout(item['layout']),
                  //           child: Container(
                  //             width: 50,
                  //             height: 46,
                  //             margin: const EdgeInsets.symmetric(
                  //                 horizontal: 8, vertical: 4),
                  //             decoration: BoxDecoration(
                  //                 color: selectLayout == item['layout']
                  //                     ? Theme.of(context).backgroundColor
                  //                     : Colors.white.withOpacity(0.1),
                  //                 borderRadius: BorderRadius.circular(9.0)),
                  //             child: Padding(
                  //               padding: const EdgeInsets.all(10.0),
                  //               child: Image.asset(
                  //                 item['image']!,
                  //                 color: selectLayout == item['layout']
                  //                     ? Theme.of(context).accentColor
                  //                     : Colors.white.withOpacity(0.3),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //   ],
                  // ),

                  // Category title & bubble
                  Visibility(
                    visible: false,
                    child: Padding(
                      // Category Selection title
                      padding: const EdgeInsets.only(right: 15, top: 30),
                      child: Text(
                        // S.of(context).byCategory.toUpperCase(),
                        'כל הקטגוריות',
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: false,
                    child: Padding(
                      // Category Selection bubble
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                        decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(3.0)),
                        child: TreeView(
                          parentList: [
                            for (var item in rootCategories)
                              // if root item = spider usa pass ELSE do and add as level 2
                              Parent(
                                parent: CategoryItem(
                                  item,
                                  hasChild:
                                      hasChildren(catModel.categories, item.id),
                                  isSelected: item.id == categoryId,
                                  onTap: (category) {
                                    _onFilter(category, tagId);
                                    // print('categoryyy');
                                    // print(category);
                                  },
                                ),
                                childList: ChildList(
                                  children: [
                                    if (hasChildren(
                                        catModel.categories, item.id)!)
                                      CategoryItem(
                                        item,
                                        isParent: true,
                                        isSelected: item.id == categoryId,
                                        onTap: (category) {
                                          _onFilter(category, tagId);
                                          // print('categoryyy');
                                          // print(category);
                                        },
                                        level: 2,
                                      ),
                                    ..._getCategoryItems(catModel.categories!,
                                        item.id, _onFilter,
                                        level: 2)
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // location (?)
                  if (Config().isListingType)
                    Padding(
                      padding: const EdgeInsets.only(right: 15, top: 30),
                      child: Text(
                        S.of(context).location.toUpperCase(),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  if (Config().isListingType)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                        decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(3.0)),
                        child: Column(
                          children: List.generate(
                            locations.length,
                            (index) => LocationItem(
                              locations[index],
                              isSelected:
                                  locations[index].id == listingLocationId,
                              onTap: () {
                                _onFilter(categoryId, tagId,
                                    listingLocationId: locations[index].id);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!Config().isListingType &&
                      Config().type != ConfigType.shopify) ...[
                    const SizedBox(height: 30),

                    // Attributes title & bubbles
                    ListenableProvider.value(
                      value: filterAttr,
                      child: Consumer<FilterAttributeModel>(
                        builder: (context, value, child) {
                          var newLstProductAttributes =
                              List.of(filterAttr.lstProductAttribute!);
                          var lstProductAttribute =
                              List.of(filterAttr.lstProductAttribute!);

                          var mustBeAddedCount = 0;
                          var forIndex = 0;
                          for (var item in lstProductAttribute) {
                            // print('// ${item.name} = ${item.id}');
                            // I/flutter (16098): // A1 סוג חומר הדפסה = 118
                            // I/flutter (16098): // שיטת הדפסה = 172
                            // I/flutter (16098): // צבעים = 7
                            // I/flutter (16098): // תצורה = 166
                            // I/flutter (16098): // קוטר חומר = 168
                            // I/flutter (16098): // מותג- = 148
                            // I/flutter (16098): // שיטת כיול = 125
                            //   switch (item.name?.trim()) {
                            switch (item.id) {
                              case 118: // 'A1 סוג חומר הדפסה':
                                newLstProductAttributes[0] =
                                    lstProductAttribute[forIndex];
                                mustBeAddedCount++;
                                break;
                              case 7: // צבעים = 7
                                newLstProductAttributes[2] =
                                    lstProductAttribute[forIndex];
                                mustBeAddedCount++;
                                break;
                              case 168: // 'קוטר חומר':
                                newLstProductAttributes[4] =
                                    lstProductAttribute[forIndex];
                                mustBeAddedCount++;
                                break;
                              case 148: // 'מותג-':
                                newLstProductAttributes[5] =
                                    lstProductAttribute[forIndex];
                                mustBeAddedCount++;
                                break;
                              case 172: // 'שיטת הדפסה':
                                newLstProductAttributes[1] =
                                    lstProductAttribute[forIndex];
                                mustBeAddedCount++;
                                break;
                              case 166: // תצורה = 166
                                newLstProductAttributes[3] =
                                    lstProductAttribute[forIndex];
                                mustBeAddedCount++;
                                break;
                              case 125: // 'שיטת כיול':
                                newLstProductAttributes[6] =
                                    lstProductAttribute[forIndex];
                                mustBeAddedCount++;
                                break;
                              default:
                                break;
                            }
                            forIndex++;
                          }
                          newLstProductAttributes.removeRange(
                              mustBeAddedCount, newLstProductAttributes.length);

                          value.lstProductAttribute =
                              List.of(newLstProductAttributes);

                          if (value.lstProductAttribute != null) {
                            var list = List<Widget>.generate(
                              value.lstProductAttribute!.length,
                              (index) {
                                // Main attr bubble
                                return FilterOptionItem(
                                  enabled: !value.isLoading,
                                  onTap: () {
                                    currentSelectedAttr = index;

                                    // myPreviousSlug = currentSlug;
                                    currentSlug =
                                        value.lstProductAttribute![index].slug;
                                    value.getAttr(
                                        id: value
                                            .lstProductAttribute![index].id);
                                    // print(value.lstProductAttribute![index].name); // List of Main attr
                                  },
                                  title:
                                      value.lstProductAttribute![index].name!,
                                  isValid: currentSelectedAttr != -1,
                                  selected: currentSelectedAttr == index,
                                );
                              },
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(right: 15, top: 0),
                                  child: Text(
                                    // S.of(context).attributes.toUpperCase(),
                                    'בחר שיטת סינון:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 10.0,
                                  ),
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                  ),
                                  child: GridView.count(
                                    scrollDirection: Axis.horizontal,
                                    // shrinkWrap: true,
                                    crossAxisCount: 2,
                                    // semanticChildCount: 2,
                                    // crossAxisSpacing: 10,
                                    children: list,
                                  ),
                                ),
                                value.isLoading
                                    ? Center(
                                        child: Container(
                                            margin: const EdgeInsets.only(
                                              top: 20.0,
                                            ),
                                            width: 35.0,
                                            height: 35.0,
                                            child: kLoadingWidget(context,
                                                color: Colors.white
                                                    .withOpacity(0.60))
                                            // const CircularProgressIndicator(strokeWidth: 2.0),
                                            ),
                                      )
                                    : Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: currentSelectedAttr == -1
                                            ? Container()
                                            : Wrap(
                                                children: List.generate(
                                                  value.lstCurrentAttr.length,
                                                  (index) {
                                                    return Container(
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5),
                                                      child: Theme(
                                                        data: ThemeData(
                                                            canvasColor: Colors
                                                                .transparent),
                                                        // Sub attr bubbles
                                                        child: FilterChip(
                                                          backgroundColor: Theme
                                                                  .of(context)
                                                              .backgroundColor
                                                              .withOpacity(
                                                                  0.15),
                                                          // selectedColor: Theme.of(context).backgroundColor.withOpacity(0.75),
                                                          checkmarkColor: Colors
                                                              .white
                                                              .withOpacity(0.7),
                                                          label: Text(
                                                              value
                                                                  .lstCurrentAttr[
                                                                      index]
                                                                  .name!,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.7),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )),
                                                          selected: value
                                                                  .lstCurrentSelectedTerms[
                                                              index],
                                                          onSelected: (val) {
                                                            // print(value.lstCurrentAttr[index].name);
                                                            // print(value.lstCurrentAttr);
                                                            // print(value.lstCurrentAttr.length);

                                                            // print(value.lstCurrentSelectedTerms.length);
                                                            // for (var attr in value.lstCurrentAttr){}

                                                            // Original
                                                            value
                                                                .updateAttributeSelectedItem(
                                                                    index, val);
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                      ),
                              ],
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                  ],

                  // Tag title & bubbles (Not Visible)
                  Visibility(
                    visible: false,
                    child: ListenableProvider.value(
                      value: tag,
                      child: Consumer<TagModel>(
                        builder: (context, TagModel tagModel, _) {
                          if (tagModel.tagList?.isEmpty ?? true) {
                            return const SizedBox();
                          }

                          // my tag filter
                          // var myNewTagsList = [];
                          // var myTagsList = tagModel.tagList;
                          // print('--------');
                          // // print('myTagsList $myTagsList');
                          // print('${myTagsList!.length}');
                          // print('${catModel.categories.}');
                          // print('--------');
                          // for (var tag in myTagsList) {
                          //   // print(tag.name);
                          //   // switch(tag.name){
                          //   // case 'a':
                          // }
                          // }
                          // myNewTagsList.add(myTagsList);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: tagModel.isLoading
                                ? [
                                    Center(
                                      child: Container(
                                        child: kLoadingWidget(context),
                                      ),
                                    )
                                  ]
                                : [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15,
                                        top: 30,
                                      ),
                                      child: Text(
                                        S.of(context).byTag.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                      ),
                                      constraints: const BoxConstraints(
                                        maxHeight: 200,
                                      ),
                                      child: GridView.count(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        crossAxisCount: 2,
                                        children: List.generate(
                                          tagModel.tagList?.length ?? 0,
                                          (index) {
                                            final selected = tagId ==
                                                tagModel.tagList![index].id
                                                    .toString();
                                            return FilterOptionItem(
                                              enabled: !tagModel.isLoading,
                                              selected: selected,
                                              isValid: tagId != '-1',
                                              title: tagModel
                                                  .tagList![index].name!
                                                  .toUpperCase(),
                                              onTap: () {
                                                setState(() {
                                                  if (selected) {
                                                    tagId = null;
                                                  } else {
                                                    tagId = tagModel
                                                        .tagList![index].id
                                                        .toString();
                                                  }
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                          );
                        },
                      ),
                    ),
                  ),

                  // Price title & Filter
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Text(
                      S.of(context).byPrice.toUpperCase(),
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        minPrice_str.length > 8
                            ? minPrice_str.substring(0, 8)
                            : minPrice_str.replaceAll('.0', ''),
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const Text(
                        ' - ',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        maxPrice_str.length > 8
                            ? maxPrice_str.substring(0, 8)
                            : maxPrice_str.replaceAll('.0', ''),
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              color: Colors.white,
                            ),
                      )
                    ],
                  ),
                  SliderTheme(
                    data: const SliderThemeData(
                      activeTrackColor: Color(kSliderActiveColor),
                      inactiveTrackColor: Color(kSliderInactiveColor),
                      activeTickMarkColor: Colors.white70,
                      inactiveTickMarkColor: Colors.white,
                      overlayColor: Colors.white12,
                      thumbColor: Color(kSliderActiveColor),
                      showValueIndicator: ShowValueIndicator.always,
                    ),
                    child: RangeSlider(
                      min: 0.0,
                      max: kMaxPriceFilter,
                      // max: myMaxPriceFilter,
                      // inactiveColor: Colors.grey,
                      // activeColor: Colors.blue,
                      divisions: kFilterDivision,
                      values: RangeValues(minPrice, maxPrice),
                      onChanged: (RangeValues values) {
                        setState(() {
                          minPrice = values.start;
                          maxPrice = values.end;
                        });
                      },
                    ),
                  ),

                  // Apply Button
                  if (!Config().isListingType)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 30,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ButtonTheme(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  primary: Theme.of(context)
                                      .backgroundColor
                                      .withOpacity(0.7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3.0),
                                  ),
                                ),
                                onPressed: () {
                                  // print(currentSlug); // AKA pa_brand
                                  // print(myPreviousSlug);
                                  // print(filterAttr.lstCurrentAttr);
                                  // print(filterAttr.lstCurrentAttr.length);

                                  _onFilter(categoryId, tagId); // Original
                                },
                                child: Text(
                                  S.of(context).apply,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  const SizedBox(height: 70),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  bool? hasChildren(categories, id) {
    return categories.where((o) => o.parent == id).toList().length > 0;
  }

  List<Category>? getSubCategories(categories, id) {
    return categories.where((o) => o.parent == id).toList();
  }

  List<Widget> _getCategoryItems(
      List<Category> categories, String? id, Function _onFilter,
      {int level = 1}) {
    return [
      for (var category in getSubCategories(categories, id)!) ...[
        Parent(
          parent: CategoryItem(
            category,
            hasChild: hasChildren(categories, category.id),
            isSelected: category.id == categoryId,
            onTap: (category) => _onFilter(category, tagId),
            level: level,
          ),
          childList: ChildList(
            children: [
              if (hasChildren(categories, category.id)!)
                CategoryItem(
                  category,
                  isParent: true,
                  isSelected: category.id == categoryId,
                  onTap: (category) => _onFilter(category, tagId),
                  level: level + 1,
                ),
              ..._getCategoryItems(categories, category.id, _onFilter,
                  level: level + 1)
            ],
          ),
        )
      ],
    ];
  }
}
