import 'package:flutter/widgets.dart';
import 'package:notes/utilities/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Delete",
    content: "Are you sure you want to Delete this item",
    optionsBuilder: () => {
      "Cancel": false,
      "Yes": true,
    },
  ).then((value) => value ?? false);
}
