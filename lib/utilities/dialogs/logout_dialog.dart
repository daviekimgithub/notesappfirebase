import 'package:flutter/widgets.dart';
import 'package:notes/utilities/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Log Out",
    content: "Are you sure you want to log out",
    optionsBuilder: () => {
      "Cancel": false,
      "Log Out": true,
    },
  ).then((value) => value ?? false);
}
