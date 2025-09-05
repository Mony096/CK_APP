import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
import 'package:bizd_tech_service/wrapper_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.fromLogout});
  final dynamic fromLogout;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userName = TextEditingController(text: "");
  final _password = TextEditingController(text: "");
  late bool _obscureText = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final username = await LocalStorageManger.getString('username');
    final password = await LocalStorageManger.getString('password');

    if (username.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _userName.text = username;
        _password.text = password;
        _rememberMe = true;
      });
    }
  }

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
                  //   height: 20,
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
                            "Service Mobile",
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
                            "Manage your services, streamlined.",
                            style: TextStyle(
                                fontSize: 14.5,
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                          SizedBox(
                            height: 50,
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
                                "Please Login to continue",
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
                      SvgPicture.asset(
                        color: const Color.fromARGB(255, 39, 204, 39),
                        'images/svg/tol_vis_2.svg',
                        width: 65,
                        height: 65,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _userName,
                        decoration: const InputDecoration(
                          labelText: 'User Name',
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
                          hintText: 'Enter User Name',
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
                        controller: _password,
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                          hintText: 'Enter Password',
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
                        height: 5,
                      ),
                      Row(
                        children: [
                          Transform.translate(
                            offset: const Offset(
                                -14, 0), // simulate margin-left: -10px
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              fillColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) {
                                if (states.contains(MaterialState.selected)) {
                                  return const Color.fromARGB(
                                      255, 66, 83, 100); // blue when checked
                                }
                                return Colors
                                    .transparent; // no fill when unchecked
                              }),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 148, 146, 146),
                                  width: 1.2), // grey border when unchecked
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(
                                -20, 0), // simulate margin-left: -10px
                            child: const Text(
                              "Remember Me",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 122, 123, 125)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 25,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            setState(() => _isLoading = true);

                            final isLogined = await Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).login(context, _userName.text, _password.text);

                            if (isLogined) {
                              if (_rememberMe) {
                                await LocalStorageManger.setString(
                                    'username', _userName.text);
                                await LocalStorageManger.setString(
                                    'password', _password.text);
                              } else {
                                await LocalStorageManger.removeString(
                                    'username');
                                await LocalStorageManger.removeString(
                                    'password');
                              }

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const WrapperScreen()),
                                (route) => false,
                              );
                            }

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
                              const Color.fromARGB(255, 66, 83, 100),
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
                                'LOGIN',
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
                  const SizedBox(height: 80),
                  const SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Copyright @2025 BizDimension Cambodia",
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
