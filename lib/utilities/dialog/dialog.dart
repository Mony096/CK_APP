import 'package:bizd_tech_service/constant/style.dart';
import 'package:bizd_tech_service/form/loading_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MaterialDialog {
  static Future<void> success(
    BuildContext context, {
    String? title,
    String? body,
    Function()? onOk,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          key: const Key('_dialog'),
          // backgroundColor: Colors.white,
          // surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(
            title ?? 'Success',
            style: TextStyle(
                color: Colors.black,
                fontSize: size(context).width * 0.045,
                fontWeight: FontWeight.w500),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(body ?? '',
                    style: TextStyle(fontSize: size(context).width * 0.04)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Ok',
                style: TextStyle(fontSize: size(context).width * 0.045),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (onOk != null) {
                  onOk();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> warning(
    BuildContext context, {
    String? title,
    String? body,
    Function()? onConfirm,
    Function()? onCancel,
    String confirmLabel = 'Ok',
    String cancelLabel = 'Cancel',
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          key: const Key('_dialog'),
          // backgroundColor: Colors.white,
          // surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,

          title: Text(
            title ?? 'Success',
            style: TextStyle(
                color: Colors.black,
                fontSize: size(context).width * 0.04,
                fontWeight: FontWeight.w500),
          ),
          content: body == null
              ? null
              : SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text(body,
                          style:
                              TextStyle(fontSize: size(context).width * 0.04)),
                    ],
                  ),
                ),
          actions: <Widget>[
            TextButton(
              child: Text(
                confirmLabel,
                style: TextStyle(fontSize: size(context).width * 0.035),
              ),
              onPressed: () {
                if (onConfirm != null) {
                  onConfirm();
                }

                Navigator.of(context).pop();
              },
            ),
            // TextButton(
            //   child: Text(
            //     cancelLabel,
            //     style: TextStyle(fontSize: size(context).width * 0.035),
            //   ),
            //   onPressed: () {
            //     if (onCancel != null) {
            //       onCancel();
            //     }
            //     Navigator.of(context).pop();
            //   },
            // ),
          ],
        );
      },
    );
  }

  static Future<void> warningWithRemove(
    BuildContext context, {
    String? title,
    String? body,
    Function()? onConfirm,
    Function()? onCancel,
    String confirmLabel = 'Ok',
    String cancelLabel = 'Cancel',
    required IconData icon, // Add a required icon parameter
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0), // Rounded corners
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          titlePadding:
              const EdgeInsets.fromLTRB(0, 10, 0, 10), // Custom padding
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24.0), // Custom padding
          actionsPadding: const EdgeInsets.fromLTRB(
              20.0, 0.0, 10.0, 10.0), // Custom padding
          title: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 15,
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white, // White background
                      borderRadius: BorderRadius.circular(
                          25), // Fully rounded (half of width/height)
                      border: Border.all(
                        color: Colors.blue, // Solid blue border
                        width: 2, // Border width of 5 pixels
                      ),
                    ),
                    child: Icon(
                      icon, // The icon you pass in
                      size: 18,
                      color: Colors
                          .blue, // Or a color that matches your app's theme
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 210,
                    child: Text(
                      title ?? 'Alert',
                      // textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 64, 64, 70),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1, // Restrict to a single line
                      overflow:
                          TextOverflow.ellipsis, // Add "..." if text overflows
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Divider(height: 1, thickness: 1),
              ),
              const SizedBox(height: 5),
            ],
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Are you want to remove or edit ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(221, 77, 78, 82),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // A horizontal line to separate the content from the buttons
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    if (onCancel != null) onCancel();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    cancelLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      if (onConfirm != null) {
                        onConfirm();
                      }
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      // Adjust the padding to make the button smaller
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(7, 0, 5, 0),
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Future<void> warningNavigator(
    BuildContext context, {
    String? title,
    String? body,
    Function()? onConfirm,
    Function()? onCancel,
    String confirmLabel = 'Ok',
    String cancelLabel = 'Cancel',
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          key: const Key('_dialog'),
          // backgroundColor: Colors.white,
          // surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,

          title: Text(
            title ?? 'Success',
            style: TextStyle(
                color: Colors.black,
                fontSize: size(context).width * 0.04,
                fontWeight: FontWeight.w500),
          ),
          content: body == null
              ? null
              : SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text(body,
                          style:
                              TextStyle(fontSize: size(context).width * 0.04)),
                    ],
                  ),
                ),
          actions: <Widget>[
            TextButton(
              child: Text(
                confirmLabel,
                style: TextStyle(fontSize: size(context).width * 0.035),
              ),
              onPressed: () {
                if (onConfirm != null) {
                  Navigator.of(context).pop();
                  onConfirm();
                }
              },
            ),
            TextButton(
              child: Text(
                cancelLabel,
                style: TextStyle(fontSize: size(context).width * 0.035),
              ),
              onPressed: () {
                if (onCancel != null) {
                  Navigator.of(context).pop();
                  onCancel();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static close(BuildContext context) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  static Future<void> loading(BuildContext context,
      {bool? barrierDismissible}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          barrierDismissible ?? false, // 👈 make sure this is false
      useRootNavigator: true, // optional, but makes dialog stay on top
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 3,
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          insetPadding: const EdgeInsets.symmetric(horizontal: 150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 55,
                child: SpinKitFadingCircle(
                  color: Colors.blue,
                  size: 45.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static snackBar(BuildContext context, message) {
    final snackBar = SnackBar(
      // width: MediaQuery.of(context).size.width,'
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(
            30,
          ),
        ),
        child: Text(message),
      ),
      padding: const EdgeInsets.all(12),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
