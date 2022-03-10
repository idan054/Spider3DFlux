
import 'package:flutter/material.dart';

import 'expansion_tile.dart';

class ExpansionInfo extends StatelessWidget {
  final String title;
  Widget iconWidget;
  final bool expand;
  final List<Widget> children;

  ExpansionInfo(
      {required this.title,
      required this.children,
      required this.iconWidget,
      this.expand = false});

  @override
  Widget build(BuildContext context) {
    return ConfigurableExpansionTile(
      initiallyExpanded: expand,
      bottomBorderOn: false,
      topBorderOn: false,
      headerExpanded: Flexible(
        child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    width: 5,
                  ),
                  iconWidget,
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    width: 200,
                    child: Text(
                      // title.toUpperCase(),
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: Theme.of(context).accentColor,
                    size: 20,
                  ),
                ])),
      ),
      header: Flexible(
        child: Container(
            margin: const EdgeInsets.only(bottom: 2),
            // width: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10),
            child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    width: 5,
                  ),
                  iconWidget,
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    width: 200,
                    child: Text(
                      // title.toUpperCase(),
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Theme.of(context).accentColor,
                    size: 20,
                  )
                ])),
      ),
      children: children,
    );
  }
}
