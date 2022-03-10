// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../common/tools/adaptive_tools.dart';
import '../../services/service_config.dart';
import 'backdrop_constants.dart';

const Cubic _kAccelerateCurve = Cubic(0.548, 0.0, 0.757, 0.464);
const Cubic _kDecelerateCurve = Cubic(0.23, 0.94, 0.41, 1.0);
const double _kPeakVelocityTime = 0.248210;
const double _kPeakVelocityProgress = 0.379146;

class _FrontLayer extends StatelessWidget {
  const _FrontLayer({Key? key, this.onTap, this.child, this.visible})
      : super(key: key);

  final VoidCallback? onTap;
  final Widget? child;
  final bool? visible;

  @override
  Widget build(BuildContext context) {
    var radius = visible! ? 12.0 : 16.0;

    return Material(
      elevation: 16.0,
      color: Theme.of(context).backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              height: visible! ? 10.0 : 40.0,
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
          Expanded(
            child: child!,
          ),
        ],
      ),
    );
  }
}

class _BackdropTitle extends AnimatedWidget {
  final Function? onPress;
  final Widget frontTitle;
  final Widget backTitle;
  final bool? visible;

  const _BackdropTitle({
    Key? key,
    required Listenable listenable,
    this.onPress,
    this.visible,
    required this.frontTitle,
    required this.backTitle,
  }) : super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = CurvedAnimation(
      parent: listenable as Animation<double>,
      curve: const Interval(0.0, 0.78),
    );

    return DefaultTextStyle(
      style:
          Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: CurvedAnimation(
              parent: ReverseAnimation(animation),
              curve: const Interval(0.5, 1.0),
            ).value,
            child: FractionalTranslation(
              translation: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0.5, 0.0),
              ).evaluate(animation),
              child: backTitle,
            ),
          ),
          Opacity(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.5, 1.0),
            ).value,
            child: FractionalTranslation(
              translation: Tween<Offset>(
                begin: const Offset(-0.25, 0.0),
                end: Offset.zero,
              ).evaluate(animation),
              child: frontTitle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Builds a Backdrop.
///
/// A Backdrop widget has two layers, front and back. The front layer is shown
/// by default, and slides down to show the back layer, from which a user
/// can make a selection. The user can also configure the titles for when the
/// front or back layer is showing.
class Backdrop extends StatefulWidget {
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontTitle;
  final Widget backTitle;
  final Widget? appbarCategory;
  final AnimationController controller;
  final Function? onSort;
  final String selectSort;

  const Backdrop({
    required this.frontLayer,
    required this.backLayer,
    required this.frontTitle,
    required this.backTitle,
    required this.controller,
    this.appbarCategory,
    this.onSort,
    this.selectSort = 'date',
  });

  @override
  _BackdropState createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  late AnimationController _controller;
  late Animation<RelativeRect> _layerAnimation;
  String _selectSort = 'date';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _selectSort = widget.selectSort;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _frontLayerVisible {
    final status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  bool shouldShowCategory = true;

  void _toggleBackdropLayerVisibility() {
    // Call setState here to update layerAnimation if that's necessary
    setState(() {
      _frontLayerVisible ? _controller.reverse() : _controller.forward();
    });
    Future.delayed(Duration(milliseconds: _frontLayerVisible ? 0 : 75), () {
      setState(() {
        shouldShowCategory = _frontLayerVisible;
      });
    });
  }

  // _layerAnimation animates the front layer between open and close.
  // _getLayerAnimation adjusts the values in the TweenSequence so the
  // curve and timing are correct in both directions.
  Animation<RelativeRect> _getLayerAnimation(Size layerSize, double layerTop) {
    Curve firstCurve; // Curve for first TweenSequenceItem
    Curve secondCurve; // Curve for second TweenSequenceItem
    double firstWeight; // Weight of first TweenSequenceItem
    double secondWeight; // Weight of second TweenSequenceItem
    Animation animation; // Animation on which TweenSequence runs

    if (_frontLayerVisible) {
      firstCurve = _kAccelerateCurve;
      secondCurve = _kDecelerateCurve;
      firstWeight = _kPeakVelocityTime;
      secondWeight = 1.0 - _kPeakVelocityTime;
      animation = CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.0, 0.78),
      );
    } else {
      // These values are only used when the controller runs from t=1.0 to t=0.0
      firstCurve = _kDecelerateCurve.flipped;
      secondCurve = _kAccelerateCurve.flipped;
      firstWeight = 1.0 - _kPeakVelocityTime;
      secondWeight = _kPeakVelocityTime;
      animation = _controller.view;
    }

    return TweenSequence(
      <TweenSequenceItem<RelativeRect>>[
        TweenSequenceItem<RelativeRect>(
          tween: RelativeRectTween(
            begin: RelativeRect.fromLTRB(
              0.0,
              layerTop,
              0.0,
              layerTop - layerSize.height,
            ),
            end: RelativeRect.fromLTRB(
              0.0,
              layerTop * _kPeakVelocityProgress,
              0.0,
              (layerTop - layerSize.height) * _kPeakVelocityProgress,
            ),
          ).chain(CurveTween(curve: firstCurve)),
          weight: firstWeight,
        ),
        TweenSequenceItem<RelativeRect>(
          tween: RelativeRectTween(
            begin: RelativeRect.fromLTRB(
              0.0,
              layerTop * _kPeakVelocityProgress,
              0.0,
              (layerTop - layerSize.height) * _kPeakVelocityProgress,
            ),
            end: RelativeRect.fill,
          ).chain(CurveTween(curve: secondCurve)),
          weight: secondWeight,
        ),
      ],
    ).animate(animation as Animation<double>);
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const layerTitleHeight = 20.0;
    final layerSize = constraints.biggest;
    final layerTop = layerSize.height - layerTitleHeight;
    _layerAnimation = _getLayerAnimation(layerSize, layerTop);

    return Stack(
      key: _backdropKey,
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(bottom: 35.0),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              )),
          child: widget.backLayer,
        ),
        PositionedTransition(
          rect: _layerAnimation,
          child: _FrontLayer(
            onTap: _toggleBackdropLayerVisibility,
            visible: _frontLayerVisible,
            child: widget.frontLayer,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      bool showTitle, IconData icon, String label, String value,
      [bool isSelect = false]) {
    final menuItemStyle = TextStyle(
      fontSize: 13.0,
      color: isSelect
          ? Theme.of(context).primaryColor
          : Theme.of(context).accentColor,
      height: 24.0 / 15.0,
    );
    return PopupMenuItem<String>(
      value: value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          showTitle
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Text('מיין לפי',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Theme.of(context).accentColor,
                        height: 24.0 / 15.0,
                      )),
                )
              : Container(),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Icon(icon,
                    color: isSelect
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).accentColor,
                    size: 17),
              ),
              Text(label, style: menuItemStyle),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const _appBarCategoryHeight = 50.0;
    var appBar = AppBar(
      brightness: Brightness.light,
      backgroundColor: kColorSpiderRed,
      elevation: 0.0,
      titleSpacing: 0.0,
      bottom: Config().isListingType
          ? null
          : widget.appbarCategory != null
              ? PreferredSize(
                  preferredSize: Size(
                    MediaQuery.of(context).size.width,
                    shouldShowCategory ? _appBarCategoryHeight : 0,
                  ),
                  child: Container(
                    height: shouldShowCategory ? _appBarCategoryHeight : 0,
                    child: AnimatedOpacity(
                      opacity: _frontLayerVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: BottomAppBar(
                          elevation: 0.0, child: widget.appbarCategory),
                    ),
                  ),
                )
              : null,
      title: _BackdropTitle(
          listenable: _controller.view,
          onPress: _toggleBackdropLayerVisibility,
          frontTitle: widget.frontTitle,
          backTitle: widget.backTitle,
          visible: _frontLayerVisible),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
        color: Theme.of(context).accentColor,
        onPressed: _frontLayerVisible
            ? () {
                if (kIsWeb) {
                  eventBus.fire(const EventOpenCustomDrawer());
                  // LayoutWebCustom.changeStateMenu(true);
                }
                Navigator.pop(context);
              }
            : _toggleBackdropLayerVisibility,
      ),
      actions: <Widget>[
        if ((!Config().isListingType) ^ (Config().type == ConfigType.shopify))
          // PopupMenuButton<String>(
          //   icon: const Icon(FontAwesomeIcons.sort,
          //       color: Colors.white, size: 18),
          //   onSelected: (String item) {
          //     _selectSort = item;
          //     widget.onSort!(item);
          //   },
          //   itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
          //     _buildMenuItem(true, FontAwesomeIcons.star, S.of(context).date,
          //         'date', _selectSort == 'date'),
          //     _buildMenuItem(false, FontAwesomeIcons.percentage,
          //         S.of(context).onSale, 'on_sale', _selectSort == 'on_sale'),
          //   ],
          // ),
          IconButton(
              icon: AnimatedIcon(
                icon: AnimatedIcons.close_menu,
                progress: _controller,
              ),
              color: Colors.white,
              onPressed: _toggleBackdropLayerVisibility),
      ],
    );
    return Scaffold(
      appBar: !isDisplayDesktop(context) ? appBar : null,
      body: Row(
        children: <Widget>[
          isDisplayDesktop(context)
              ? Container(
                  width: BackdropConstants.drawerWidth,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(bottom: 32),
                  color: Theme.of(context).primaryColor,
                  child: widget.backLayer,
                )
              : const SizedBox(),
          Expanded(
            child: LayoutBuilder(
              builder: _buildStack,
            ),
          ),
        ],
      ),
    );
  }
}
