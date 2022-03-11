// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/material.dart';
import '../../menu/maintab_delegate.dart';
import 'package:provider/provider.dart';

import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show CartModel, Product, ProductVariation;
import '../../screens/index.dart' show CartScreen;

// These curves define the emphasized easing curve.
const Cubic _kAccelerateCurve = Cubic(0.548, 0.0, 0.757, 0.464);
const Cubic _kDecelerateCurve = Cubic(0.23, 0.94, 0.41, 1.0);
// The time at which the accelerate and decelerate curves switch off
const double _kPeakVelocityTime = 0.248210;
// Percent (as a decimal) of animation that should be completed at _peakVelocityTime
const double _kPeakVelocityProgress = 0.379146;
const double _kCartHeight = 56.0;
// Radius of the shape on the top left of the sheet.
const double _kCornerRadius = 24.0;
// Width for just the cart icon and no thumbnails.
const double _kWidthForCartIcon = 64.0;

class ExpandingBottomSheet extends StatefulWidget {
  const ExpandingBottomSheet(
      {Key? key, required this.hideController, this.onInitController})
      : super(key: key);

  final AnimationController hideController;
  final Function? onInitController;

  @override
  _ExpandingBottomSheetState createState() => _ExpandingBottomSheetState();

  static _ExpandingBottomSheetState? of(BuildContext context,
      {bool isNullOk = false}) {
    final result =
        context.findAncestorStateOfType<_ExpandingBottomSheetState>();
    if (isNullOk || result != null) {
      return result;
    }
    throw FlutterError(
        'ExpandingBottomSheet.of() called with a context that does not contain a ExpandingBottomSheet.\n');
  }
}

// Emphasized Easing is a motion curve that has an organic, exciting feeling.
// It's very fast to begin with and then very slow to finish. Unlike standard
// curves, like [Curves.fastOutSlowIn], it can't be expressed in a cubic bezier
// curve formula. It's quintic, not cubic. But it _can_ be expressed as one
// curve followed by another, which we do here.
Animation<T> _getEmphasizedEasingAnimation<T>(
    {required T begin,
    required T peak,
    required T end,
    required bool isForward,
    required Animation parent}) {
  Curve firstCurve;
  Curve secondCurve;
  double firstWeight;
  double secondWeight;

  if (isForward) {
    firstCurve = _kAccelerateCurve;
    secondCurve = _kDecelerateCurve;
    firstWeight = _kPeakVelocityTime;
    secondWeight = 1.0 - _kPeakVelocityTime;
  } else {
    firstCurve = _kDecelerateCurve.flipped;
    secondCurve = _kAccelerateCurve.flipped;
    firstWeight = 1.0 - _kPeakVelocityTime;
    secondWeight = _kPeakVelocityTime;
  }

  return TweenSequence(
    <TweenSequenceItem<T>>[
      TweenSequenceItem<T>(
        weight: firstWeight,
        tween: Tween<T>(
          begin: begin,
          end: peak,
        ).chain(CurveTween(curve: firstCurve)),
      ),
      TweenSequenceItem<T>(
        weight: secondWeight,
        tween: Tween<T>(
          begin: peak,
          end: end,
        ).chain(CurveTween(curve: secondCurve)),
      ),
    ],
  ).animate(parent as Animation<double>);
}

// Calculates the value where two double Animations should be joined. Used by
// callers of _getEmphasisedEasing<double>().
double _getPeakPoint({required double begin, required double end}) {
  return begin + (end - begin) * _kPeakVelocityProgress;
}

class _ExpandingBottomSheetState extends State<ExpandingBottomSheet>
    with TickerProviderStateMixin {
  final GlobalKey _expandingBottomSheetKey =
      GlobalKey(debugLabel: 'Expanding bottom sheet');

  // The width of the Material, calculated by _widthFor() & based on the number
  // of products in the cart. 64.0 is the width when there are 0 products
  // (_kWidthForZeroProducts)
  double _width = _kWidthForCartIcon;

  // Controller for the opening and closing of the ExpandingBottomSheet
  late AnimationController _controller;

  // Animations for the opening and closing of the ExpandingBottomSheet
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;
  late Animation<double> _thumbnailOpacityAnimation;

//  Animation<double> _cartOpacityAnimation;
  late Animation<double> _shapeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (widget.onInitController != null) {
        widget.onInitController!(_controller);
      }
    });
  }

  @override
  void dispose() {
    close();
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _getWidthAnimation(double screenWidth) {
    if (_controller.status == AnimationStatus.forward) {
      // Opening animation
      return Tween<double>(begin: _width, end: screenWidth).animate(
        CurvedAnimation(
          parent: _controller.view,
          curve: const Interval(0.0, 0.3, curve: Curves.fastOutSlowIn),
        ),
      );
    } else {
      // Closing animation
      return _getEmphasizedEasingAnimation(
        begin: _width,
        peak: _getPeakPoint(begin: _width, end: screenWidth),
        end: screenWidth,
        isForward: false,
        parent: CurvedAnimation(
            parent: _controller.view, curve: const Interval(0.0, 0.87)),
      );
    }
  }

  Animation<double> _getHeightAnimation(double screenHeight) {
    if (_controller.status == AnimationStatus.forward) {
      // Opening animation

      return _getEmphasizedEasingAnimation(
        begin: _kCartHeight,
        peak: _kCartHeight +
            (screenHeight - _kCartHeight) * _kPeakVelocityProgress,
        end: screenHeight,
        isForward: true,
        parent: _controller.view,
      );
    } else {
      // Closing animation
      return Tween<double>(
        begin: _kCartHeight,
        end: screenHeight,
      ).animate(
        CurvedAnimation(
          parent: _controller.view,
          curve: const Interval(0.434, 1.0, curve: Curves.linear), // not used
          // only the reverseCurve will be used
          reverseCurve:
              Interval(0.434, 1.0, curve: Curves.fastOutSlowIn.flipped),
        ),
      );
    }
  }

  // Animation of the cut corner. It's cut when closed and not cut when open.
  Animation<double> _getShapeAnimation() {
    if (_controller.status == AnimationStatus.forward) {
      return Tween<double>(begin: _kCornerRadius, end: 0.0).animate(
        CurvedAnimation(
          parent: _controller.view,
          curve: const Interval(0.0, 0.3, curve: Curves.fastOutSlowIn),
        ),
      );
    } else {
      return _getEmphasizedEasingAnimation(
        begin: _kCornerRadius,
        peak: _getPeakPoint(begin: _kCornerRadius, end: 0.0),
        end: 0.0,
        isForward: false,
        parent: _controller.view,
      );
    }
  }

  Animation<double> _getThumbnailOpacityAnimation() {
    return Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller.view,
        curve: _controller.status == AnimationStatus.forward
            ? const Interval(0.0, 0.3)
            : const Interval(0.532, 0.766),
      ),
    );
  }

//  Animation<double> _getCartOpacityAnimation() {
//    return CurvedAnimation(
//      parent: _controller.view,
//      curve: _controller.status == AnimationStatus.forward
//          ? Interval(0.3, 0.6)
//          : Interval(0.766, 1.0),
//    );
//  }

  // Returns the correct width of the ExpandingBottomSheet based on the number of
  // products in the cart.
  double _widthFor(int numProducts) {
    switch (numProducts) {
      case 0:
        return _kWidthForCartIcon;
      case 1:
        return 136.0;
      case 2:
        return 192.0;
      case 3:
        return 248.0;
      default:
        return 278.0;
    }
  }

  // Returns true if the cart is open or opening and false otherwise.
  bool get _isOpen {
    final status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  // Opens the ExpandingBottomSheet if it's closed, otherwise does nothing.
  void open() {
    if (!_isOpen) {
      _controller.forward();
      MainTabControlDelegate.getInstance().changeTab('cart');
    }
  }

  // Closes the ExpandingBottomSheet if it's open or opening, otherwise does nothing.
  void close() {
    if (_isOpen) {
      _controller.reverse();
    }
  }

  // Changes the padding between the start edge of the Material and the cart icon
  // based on the number of products in the cart (padding increases when > 0
  // products.)
  EdgeInsetsDirectional _cartPaddingFor(int numProducts) {
    if (numProducts == 0) {
      return const EdgeInsetsDirectional.only(start: 10.0, end: 8.0);
    } else {
      return const EdgeInsetsDirectional.only(start: 16.0, end: 8.0);
    }
  }

  bool get _cartIsVisible => _thumbnailOpacityAnimation.value == 0.0;

  Widget _buildThumbnails(int numProducts) {
    var totalCart = Provider.of<CartModel>(context).totalCartQuantity;

    return ExcludeSemantics(
      child: Opacity(
        opacity: _thumbnailOpacityAnimation.value,
        child: Column(children: <Widget>[
          Row(children: <Widget>[
            AnimatedPadding(
              padding: _cartPaddingFor(numProducts), //
              duration: const Duration(milliseconds: 225),
              // child: const Icon(Icons.add_shopping_cart, size: 20),
              child: const Icon(
                // Icons.shopping_cart_outlined,
                Icons.add_shopping_cart,
                size: 24,
                // color: Theme.of(context).tabBarTheme.labelColor!.withOpacity(0.60),
              ),
            ),
            if (totalCart > 0)
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(2)),
                padding: const EdgeInsets.only(
                  left: 4,
                  right: 4,
                  bottom: 3,
                  top: 5,
                ),
                child: Text(
                  totalCart.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            Container(
              // color: Colors.blue,
              // Accounts for the overflow number
              width: numProducts < 1
                  ? _width - 50.0
                  : numProducts > 3
                      ? _width - 110.0
                      : _width - 75.0,
              height: _kCartHeight,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ProductThumbnailRow(),
            ),

            // more extra product
//            ExtraProductsNumber()
          ]),
        ]),
      ),
    );
  }

  Widget _buildCartScreen() {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: CartScreen(isModal: true),
    );
  }

  Widget _buildCart(BuildContext context, Widget? child) {
    // numProducts is the number of different products in the cart (does not
    // include multiples of the same product).

    final numProducts =
        Provider.of<CartModel>(context).productsInCart.keys.length;
    final totalCartQuantity = Provider.of<CartModel>(context).totalCartQuantity;

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    _width = _widthFor(numProducts);
    _widthAnimation = _getWidthAnimation(screenWidth);
    _heightAnimation = _getHeightAnimation(screenHeight);
    _shapeAnimation = _getShapeAnimation();
    _thumbnailOpacityAnimation = _getThumbnailOpacityAnimation();
//    _cartOpacityAnimation = _getCartOpacityAnimation();

    return Semantics(
      button: true,
      value: S.of(context).shoppingCartItems(totalCartQuantity.toString()),
      child: Container(
        width: _widthAnimation.value,
        height: _heightAnimation.value,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25.0),
          ),
        ),
        child: Material(
          animationDuration: const Duration(milliseconds: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(_shapeAnimation.value),
            ),
          ),
          elevation: 0.0,
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          child: _cartIsVisible
              ? _buildCartScreen()
              : _buildThumbnails(numProducts),
        ),
      ),
    );
  }

  // Builder for the hide and reveal animation when the backdrop opens and closes
  Widget _buildSlideAnimation(BuildContext context, Widget? child) {
    _slideAnimation = _getEmphasizedEasingAnimation(
      begin: const Offset(1.0, 0.0),
      peak: const Offset(_kPeakVelocityProgress, 0.0),
      end: const Offset(0.0, 0.0),
      isForward: widget.hideController.status == AnimationStatus.forward,
      parent: widget.hideController,
    );

    return SlideTransition(
      position: _slideAnimation,
      child: child,
    );
  }

  // Closes the cart if the cart is open, otherwise exits the app (this should
  // only be relevant for Android).
//  Future<bool> _onWillPop() async {
//    /*if (!_isOpen) {
//      await SystemNavigator.pop();
//      return true;
//    }*/
//    close();
//    return true;
//  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      key: _expandingBottomSheetKey,
      duration: const Duration(milliseconds: 225),
      curve: Curves.easeInOut,
      vsync: this,
      alignment: FractionalOffset.topLeft,
      child: AnimatedBuilder(
        animation: widget.hideController,
        builder: _buildSlideAnimation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: open,
          child: AnimatedBuilder(
            builder: _buildCart,
            animation: _controller,
          ),
        ),
      ),
    );
  }
}

class ProductThumbnailRow extends StatefulWidget {
  @override
  _ProductThumbnailRowState createState() => _ProductThumbnailRowState();
}

class _ProductThumbnailRowState extends State<ProductThumbnailRow> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // _list represents what's currently on screen. If _internalList updates,
  // it will need to be updated to match it.
  late _ListModel _list;

  // _internalList represents the list as it is updated by the AppStateModel.
  late List<String> _internalList;

  @override
  void initState() {
    super.initState();
    _list = _ListModel(
      listKey: _listKey,
      initialItems: [],
      // Provider.of<CartModel>(context).productsInCart.keys.toList(),
      removedItemBuilder: _buildRemovedThumbnail,
    );
    _internalList = List<String>.from(_list.list);
  }

  Product _productWithId(String key) {
    var productId = Product.cleanProductID(key);
//    if (key.contains("-")) {
//      productId = int.parse(key.split("-")[0]);
//    } else {
//      productId = int.parse(key);
//    }
//    productId = key;

    final product = Provider.of<CartModel>(context, listen: false)
        .getProductById(productId);
//    assert(product != null);
    return product!;
  }

  ProductVariation? _productVariationWithId(String key) {
    return Provider.of<CartModel>(context, listen: false)
        .getProductVariationById(key);
  }

  Widget _buildRemovedThumbnail(
      String item, BuildContext context, Animation<double> animation) {
    return ProductThumbnail(animation, animation, _productWithId(item),
        _productVariationWithId(item)!);
  }

  Widget _buildThumbnail(
      BuildContext context, int index, Animation<double> animation) {
    var thumbnailSize = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        curve: const Interval(0.33, 1.0, curve: Curves.easeIn),
        parent: animation,
      ),
    );

    Animation<double> opacity = CurvedAnimation(
      curve: const Interval(0.33, 1.0, curve: Curves.linear),
      parent: animation,
    );

    // print('+++++++');
    // print(_list[index]);
    // print(_productVariationWithId(_list[index]));
    // print(_productWithId(_list[index]));

    return ProductThumbnail(
      thumbnailSize,
      opacity,
      _productWithId(_list[index]),
      _productVariationWithId(_list[index]),
    );
  }

  // If the lists are the same length, assume nothing has changed.
  // If the internalList is shorter than the ListModel, an item has been removed.
  // If the internalList is longer, then an item has been added.
  void _updateLists() {
    // Update _internalList based on the model
    _internalList = Provider.of<CartModel>(context, listen: false)
        .productsInCart
        .keys
        .toList();
    var internalSet = Set<String>.from(_internalList);
    var listSet = Set<String>.from(_list.list);

    var difference = internalSet.difference(listSet);
    if (difference.isEmpty) {
      return;
    }

    difference.forEach((product) {
      if (_internalList.length < _list.length) {
        _list.remove(product);
      } else if (_internalList.length > _list.length) {
        _list.add(product);
      }
    });

    while (_internalList.length != _list.length) {
      var index = 0;
      // Check bounds and that the list elements are the same
      while (_internalList.isNotEmpty &&
          _list.length > 0 &&
          index < _internalList.length &&
          index < _list.length &&
          _internalList[index] == _list[index]) {
        index++;
      }
    }
  }

  Widget _buildAnimatedList() {
    return AnimatedList(
      key: _listKey,
      shrinkWrap: true,
      itemBuilder: _buildThumbnail,
      initialItemCount: _list.length,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(), // Cart shouldn't scroll
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateLists();
    return _buildAnimatedList();
  }
}

class ExtraProductsNumber extends StatelessWidget {
  // Calculates the number to be displayed at the end of the row if there are
  // more than three products in the cart. This calculates overflow products,
  // including their duplicates (but not duplicates of products shown as
  // thumbnails).
  int _calculateOverflow(CartModel model) {
    var productMap = model.productsInCart;
    // List created to be able to access products by index instead of ID.
    // Order is guaranteed because productsInCart returns a LinkedHashMap.
    var products = productMap.keys.toList();
    var overflow = 0;
    var numProducts = products.length;
    if (numProducts > 3) {
      for (var i = 3; i < numProducts; i++) {
        overflow += productMap[products[i]]!;
      }
    }
    return overflow;
  }

  Widget _buildOverflow(CartModel model, BuildContext context) {
    if (model.productsInCart.length > 3) {
      var numOverflowProducts = _calculateOverflow(model);
      // Maximum of 99 so padding doesn't get messy.
      var displayedOverflowProducts =
          numOverflowProducts <= 99 ? numOverflowProducts : 99;
      return Text(
        '+$displayedOverflowProducts',
        style: Theme.of(context).primaryTextTheme.button,
      );
    } else {
      return Container(); // build() can never return null.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (builder, model, child) => _buildOverflow(model, context),
    );
  }
}

class ProductThumbnail extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> opacityAnimation;
  final Product product;
  final ProductVariation? productVariation;
  ProductThumbnail(this.animation, this.opacityAnimation, this.product,
      this.productVariation);

  @override
  Widget build(BuildContext context) {
    var imageFeature = product.imageFeature ?? '';
    if (productVariation != null) {
      imageFeature = productVariation!.imageFeature ?? imageFeature;
    }

    return FadeTransition(
      opacity: opacityAnimation,
      child: ScaleTransition(
        scale: animation,
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              // color: Colors.yellow,
              width: 40.0,
              height: 40.0,
              // margin: const EdgeInsets.only(right: 16.0),
              child: ImageTools.image(
                  url: imageFeature, size: kSize.medium, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

// _ListModel manipulates an internal list and an AnimatedList
class _ListModel {
  _ListModel(
      {required this.listKey,
      required this.removedItemBuilder,
      Iterable<String>? initialItems})
      : assert(removedItemBuilder != null),
        _items = List<String>.from(initialItems ?? <String>[]);

  final GlobalKey<AnimatedListState> listKey;
  final dynamic removedItemBuilder;
  final List<String> _items;

  AnimatedListState? get _animatedList => listKey.currentState;

  void add(String product) {
    _insert(0, product);
  }

  void _insert(int index, String item) {
    _items.insert(index, item);
    if (_animatedList != null) {
      _animatedList!
          .insertItem(index, duration: const Duration(milliseconds: 225));
    }
  }

  void remove(String product) {
    final index = _items.indexOf(product);
    if (index >= 0) {
      _removeAt(index);
    }
  }

  void _removeAt(int index) {
    final removedItem = _items.removeAt(index);
    _animatedList!.removeItem(index,
        (BuildContext context, Animation<double> animation) {
      return removedItemBuilder(removedItem, context, animation);
    });
  }

  int get length => _items.length;

  String operator [](int index) => _items[index];

  int indexOf(String item) => _items.indexOf(item);

  List<String> get list => _items;
}
