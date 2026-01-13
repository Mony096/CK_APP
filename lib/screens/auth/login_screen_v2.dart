import 'dart:async';
import 'dart:io';

import 'package:bizd_tech_service/core/core.dart';
import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/screens/auth/setting.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
import 'package:bizd_tech_service/wrapper_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreenV2 extends StatefulWidget {
  const LoginScreenV2({super.key, this.fromLogout});
  final dynamic fromLogout;

  @override
  State<LoginScreenV2> createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends State<LoginScreenV2> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userNameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  
  Timer? _holdTimer;
  double _holdProgress = 0.0;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _userNameFocus.dispose();
    _passwordFocus.dispose();
    _holdTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final username = await LocalStorageManger.getString('username');
    final password = await LocalStorageManger.getString('password');

    if (username.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _userNameController.text = username;
        _passwordController.text = password;
        _rememberMe = true;
      });
    }
  }

  void _startHold() {
    HapticFeedback.lightImpact();
    setState(() => _holdProgress = 0.0);

    const interval = Duration(milliseconds: 100);
    int ticks = 0;
    const maxTicks = 20;

    _holdTimer = Timer.periodic(interval, (timer) {
      ticks++;
      setState(() => _holdProgress = ticks / maxTicks);

      if (ticks >= maxTicks) {
        timer.cancel();
        HapticFeedback.heavyImpact();
        goTo(context, const SettingScreen());
        setState(() => _holdProgress = 0.0);
      }
    });
  }

  void _endHold() {
    _holdTimer?.cancel();
    setState(() => _holdProgress = 0.0);
  }

  Future<void> _handleLogin() async {
    if (_userNameController.text.isEmpty || _passwordController.text.isEmpty) {
       HapticFeedback.vibrate();
       return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final isLoggedIn = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).login(context, _userNameController.text, _passwordController.text);

      if (isLoggedIn && mounted) {
        if (_rememberMe) {
          await LocalStorageManger.setString('username', _userNameController.text);
          await LocalStorageManger.setString('password', _passwordController.text);
        } else {
          await LocalStorageManger.removeString('username');
          await LocalStorageManger.removeString('password');
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WrapperScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        AdaptiveDialog.showAlert(
          context: context,
          title: 'Login Failed',
          content: 'Incorrect username/password or server error.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Brand Identity
                      _buildHeader(),
                      const SizedBox(height: 48),
                      // Login Inputs
                      _buildLoginForm(),
                    ],
                  ),
                ),
              ),
              // Footer link (like "Sign Up" in the inspiration)
              _buildBottomAction(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'images/logo.png',
          height: 80,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Log in to your Service Mobile account to manage your services.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF737373),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _userNameController,
            focusNode: _userNameFocus,
            label: 'Username',
            hintText: 'Enter your username',
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            label: 'Password',
            hintText: 'Enter your password',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleLogin(),
            suffix: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: const Color(0xFFA3A3A3),
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 20),
          _buildRememberMe(),
          const SizedBox(height: 24),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    bool obscureText = false,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFEF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            textInputAction: textInputAction,
            onFieldSubmitted: onSubmitted,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFFA3A3A3),
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              border: InputBorder.none,
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, 
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Log In',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSecondaryActions() {
    return _buildRememberMe();
  }

  Widget _buildRememberMe() {
    return GestureDetector(
      onTap: () => setState(() => _rememberMe = !_rememberMe),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _rememberMe ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: _rememberMe ? AppColors.primary : const Color(0xFFD4D4D4),
              ),
            ),
            child: _rememberMe
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            'Keep me logged in',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF737373),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _endHold(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '© 2025 BizDimension Cambodia',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '|',
                style: TextStyle(color: Colors.black.withOpacity(0.3)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => goTo(context, const SettingScreen()),
                child: Text(
                  'Settings',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (_holdProgress > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 150,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _holdProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
