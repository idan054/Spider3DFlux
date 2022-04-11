import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

class SearchBox extends StatefulWidget {
  final double? width;
  final bool showCancelButton;
  final bool showSearchIcon;
  final bool autoFocus;
  final String? initText;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Function()? onCancel;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;

  SearchBox({
    Key? key,
    this.focusNode,
    this.onCancel,
    this.width,
    this.onChanged,
    this.controller,
    this.initText,
    this.onSubmitted,
    this.autoFocus = false,
    this.showSearchIcon = true,
    this.showCancelButton = true,
  }) : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  TextEditingController? _textController;

  double get widthButtonCancel => _textController!.text.isEmpty ? 0 : 50;

  String _oldSearchText = '';
  Timer? _debounceQuery;

  Function(String value)? get onChanged => widget.onChanged;

  @override
  void initState() {
    super.initState();
    _textController =
        widget.controller ?? TextEditingController(text: widget.initText ?? '');
    _textController!.addListener(_onSearchTextChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textController!.dispose();
    }
    super.dispose();
  }

  void _onSearchTextChange() {
    if (_oldSearchText != _textController!.text) {
      if (_textController!.text.isEmpty) {
        _oldSearchText = _textController!.text;
        setState(() {});
        widget.onChanged?.call(_textController!.text);
        return;
      }

      if (_debounceQuery?.isActive ?? false) _debounceQuery!.cancel();
      _debounceQuery = Timer(const Duration(milliseconds: 800), () {
        _oldSearchText = _textController!.text;
        widget.onChanged?.call(_textController!.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: Row(children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (widget.showSearchIcon)
                  Icon(
                    CupertinoIcons.search,
                    size: 22,
                    color: Theme.of(context).accentColor,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).accentColor,
                      hintText: S.of(context).searchForItems,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                    ),
                    controller: _textController,
                    autofocus: widget.autoFocus,
                    focusNode: widget.focusNode,
                    onSubmitted: (value) =>
                        widget.onSubmitted?.call(value),
                  ),
                ),
                if (widget.showCancelButton)
                  AnimatedContainer(
                    width: widthButtonCancel,
                    duration: const Duration(milliseconds: 250),
                    child: GestureDetector(
                      onTap: () {
                        widget.onCancel?.call();
                        _textController!.clear();
                        var currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                      child: Center(
                        child: Text(
                          S.of(context).cancel,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
