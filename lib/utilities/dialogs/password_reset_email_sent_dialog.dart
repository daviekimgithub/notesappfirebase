import 'package:flutter/widgets.dart';
import 'package:notes/utilities/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "password reset",
    content:
        "We sent you a password reset link. Please check you email for more infomrtion",
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
