import 'package:flutter/material.dart';
import 'package:fstore/screens/checkout/widgets/my_creditcard_address.dart';

final noteController = TextEditingController();

void showNotesDialogV3(BuildContext context) async {
  return showDialog<void>(
    barrierColor: Colors.black26,
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title:
        const Text( 'הוסף פירוט הערות',
          style: TextStyle(
            // color: Colors.white,
            // color: Theme.of(context).primaryColor,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        // actions: <Widget>[],
        titlePadding: const EdgeInsets.only(right: 15, top: 10, bottom: 5, left: 15),
        contentPadding: const EdgeInsets.all(0), // inside
        insetPadding: const EdgeInsets.all(10), // outside
        content: SingleChildScrollView(
            child:
            Column(
              children: [
                /// TextField
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    decoration: greyTxtDeco(labelText: 'ההערה שלך...'),
                    controller: noteController,
                    autofillHints: [AutofillHints.addressCity],
                    textInputAction: TextInputAction.newline,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    autofocus: true,
                  ),
                ),
                /// Button
                Container(
                  alignment: Alignment.center,
                  width: 90,
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ButtonTheme(
                    // height: 20,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        onPrimary: Colors.white,
                        primary:
                        Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Value save based the global noteController
                        // on handleCheckoutButtonV3.dart (line 208)
                      },
                      child: const Text('עדכן',
                          style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),

        ),
      );
    },
  );
}