import 'package:flutter/widgets.dart';
import 'package:notes/utilities/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Sharing",
    content: "You cannot share an empty note",
    optionsBuilder: () => {
      "OK": null,
    },
  );
}
