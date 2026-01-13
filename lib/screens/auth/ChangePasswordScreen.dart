import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/main.dart';
import 'package:bizd_tech_service/screens/auth/login_screen_v2.dart';
import 'package:bizd_tech_service/screens/auth/setting.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/wrapper_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, this.fromLogout});
  final dynamic fromLogout;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPassword = TextEditingController(text: "");
  final _newPassword = TextEditingController(text: "");
  late bool _obscureText = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/bg.png'), // Path to your image
              fit: BoxFit.cover, // Adjust how the image fits into the container
            ),
          ),
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  // const SizedBox(
                  //   height: 40,
                  // ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 100,
                    child: const Opacity(
                      opacity:
                          0.8, // Set the opacity level (0.0 is fully transparent, 1.0 is fully opaque)
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Deliver Smarter",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 238, 239, 241),
                              fontSize: 30,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Simplify your workflow with real-time tracking.",
                            style: TextStyle(
                                fontSize: 14.5,
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                          SizedBox(
                            height: 60,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_circle_right,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Please reset your password",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  // const SizedBox(height: 50), // Space between Title and boxes
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 96, 100, 105)
                              .withOpacity(0.25),
                          blurRadius: 4,
                          spreadRadius: 2,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(children: [
                      Image.asset(
                        'images/logo.png',
                        width: 90,
                        height: 90,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _currentPassword,
                        decoration: const InputDecoration(
                          labelText: 'Current Password',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey, // Set border color to gray
                              width:
                                  1.0, // Optional: Adjust the border thickness
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey, // Gray border when enabled
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey, // Gray border when focused
                              width: 1.0,
                            ),
                          ),
                          hintText: 'New Password',
                          isDense: true, // Reduces the vertical space
                          contentPadding: EdgeInsets.symmetric(
                            vertical:
                                12.0, // Adjusts the height of the input field
                            horizontal:
                                12.0, // Adjusts horizontal padding inside the field
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        obscureText: _obscureText,
                        controller: _newPassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey, // Set border color to gray
                              width: 1.0, // Optional: Border thickness
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey, // Gray border when enabled
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey, // Gray border when focused
                              width: 1.0,
                            ),
                          ),
                          hintText: 'Enter New Password',
                          isDense: true, // Makes the TextField smaller
                          contentPadding: const EdgeInsets.symmetric(
                            vertical:
                                8.0, // Adjust the height of the input field
                            horizontal:
                                12.0, // Adjust horizontal padding inside the field
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      ElevatedButton(
                        // onPressed: () async {
                        //   // setState(() => _isLoading = true);
                        //   // final success = await Provider.of<AuthProvider>(
                        //   //         context,
                        //   //         listen: false)
                        //   //     .login(context, _userName.text, _password.text);

                        //   // if (success) {
                        //   //   Navigator.of(context).pushAndRemoveUntil(
                        //   //     MaterialPageRoute(
                        //   //         builder: (_) => const WrapperScreen()),
                        //   //     (route) => false,
                        //   //   );
                        //   // }
                        //   // setState(() => _isLoading = false);

                        // },
                        onPressed: () async {
                          try {
                            setState(() => _isLoading = true);
                            final success = await Provider.of<AuthProvider>(
                                    context,
                                    listen: false)
                                .changePassword(context, _currentPassword.text,
                                    _newPassword.text);
                            if (success) {
                              // Go to login screen and remove previous routes
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreenV2()),
                                (route) => false,
                              );
                            }
                            // if( await Provider.of<AuthProvider>(context, listen: false).isChangePassword){
                            //   goTo(context, const ChangePasswordScreen())
                            // }

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const WrapperScreen()),
                              (route) => false,
                            );
                            setState(() => _isLoading = false);
                          } catch (e) {
                            setState(() => _isLoading = false);
                            MaterialDialog.warning(
                              context,
                              title: 'Login Failed',
                              body:
                                  "Incorrect username/password or server error.",
                            );
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor:
                              const Color.fromARGB(255, 33, 107, 243),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'New Password',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      // Button(
                      //   variant: ButtonVariant.ghost,
                      //   loading: false,
                      //   child: const Text(
                      //     'Setting',
                      //     style: TextStyle(
                      //         color: Color.fromARGB(255, 8, 8, 8),
                      //         fontSize: 14),
                      //   ),
                      //   onPressed: () => goTo(context, const SettingScreen()),
                      // ),
                    ]),
                  ),
                  // const Expanded(
                  // flex: 1,
                  const SizedBox(height: 120),
                  const SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Copyright@ 2023 BizDimension Cambodia",
                          style: TextStyle(fontSize: 14.5, color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "All rights reserved",
                          style: TextStyle(fontSize: 14.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
