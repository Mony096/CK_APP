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
            title ?? 'Scucess',
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

  static Future<void> createSuccess(
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

  static Future<void> warningStayScreenWhenOk(
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
                      backgroundColor: const Color.fromARGB(255, 66, 83, 100),
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

  static Future<void> warningBackScreen(
    BuildContext context, {
    String? title,
    String? body,
    Function()? onConfirm,
    Function()? onCancel,
    String confirmLabel = 'Yes',
    String cancelLabel = 'No',
    required IconData icon, // Add a required icon parameter
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                      'Warning',
                      // textAlign: TextAlign.center,
                      style:  TextStyle(
                        color: Color.fromARGB(255, 64, 64, 70),
                        fontSize: MediaQuery.of(context).size.width * 0.039,
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
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Are you sure you want to go back without completing?",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.036,
                    height:
                        1.6, // ✅ line height (1.0 = normal, >1.0 = more space)
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
                      backgroundColor: const Color.fromARGB(255, 66, 83, 100),
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

  static Future<void> createdSuccess(
    BuildContext context,
  ) async {
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
                        color: Colors.green, // Solid blue border
                        width: 2, // Border width of 5 pixels
                      ),
                    ),
                    child: const Icon(
                      Icons.done_all, // The icon you pass in
                      size: 18,
                      color: Colors
                          .green, // Or a color that matches your app's theme
                    ),
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 210,
                    child: Text(
                      'Success',
                      // textAlign: TextAlign.center,
                      style: TextStyle(
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
                  "Equipment Created Successfully",
                  textAlign: TextAlign.left,
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
                SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 66, 83, 100),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      // Adjust the padding to make the button smaller
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(7, 0, 5, 0),
                      child: Text(
                        "OK",
                        style: TextStyle(
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

  static Future<void> allSyncSuccess(
    BuildContext context,
  ) async {
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
                        color: Colors.green, // Solid blue border
                        width: 2, // Border width of 5 pixels
                      ),
                    ),
                    child: const Icon(
                      Icons.done_all, // The icon you pass in
                      size: 18,
                      color: Colors
                          .green, // Or a color that matches your app's theme
                    ),
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 210,
                    child: Text(
                      'Success',
                      // textAlign: TextAlign.center,
                      style: TextStyle(
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
                  "Successfully synced to SAP",
                  textAlign: TextAlign.left,
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
                SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 66, 83, 100),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      // Adjust the padding to make the button smaller
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(7, 0, 5, 0),
                      child: Text(
                        "OK",
                        style: TextStyle(
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

  static Future<void> viewDetailDialog(
    BuildContext context, {
    String? title,
    String? body,
    Function()? onCancel,
    String cancelLabel = 'Close',
    IconData icon = Icons.info_outline,
    Color iconColor = Colors.green,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(15, 15, 0, 0),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(3),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title ?? 'Detail View',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              body ?? "Check equipment information?",
              style: const TextStyle(
                fontSize: 15,
                color: Color.fromARGB(221, 110, 110, 115),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onCancel != null) onCancel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(cancelLabel),
            ),
          ],
        );
      },
    );
  }

  static Future<void> warningClearDataDialog(
    BuildContext context, {
    String? title,
    String? body,
    Function()? onCancel,
    String cancelLabel = 'Close',
    IconData icon = Icons.info_outline,
    Color iconColor = Colors.green,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(15, 15, 0, 0),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(3),
                child: Icon(icon, color: Colors.red, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title ?? 'Detail View',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              body ?? "Are you sure you want to clear all the data?",
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(221, 110, 110, 115),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // text/icon color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "No",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onCancel != null) onCancel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(cancelLabel),
            ),
          ],
        );
      },
    );
  }

  static Future<void> requiredFielDialog(
    BuildContext context, {
    String? title,
    String? body,
    Function()? onCancel,
    String cancelLabel = 'Close',
    IconData icon = Icons.info_outline,
    Color iconColor = Colors.red,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(15, 15, 0, 0),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(3),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title ?? 'Detail View',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              body ?? "Check equipment information?",
              style: const TextStyle(
                fontSize: 15,
                color: Color.fromARGB(221, 110, 110, 115),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onCancel != null) onCancel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 66, 83, 100),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(cancelLabel),
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 130),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 55,
                child: SpinKitFadingCircle(
                  color: Colors.green,
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
