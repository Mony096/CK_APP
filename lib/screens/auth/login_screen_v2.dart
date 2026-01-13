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

/// Redesigned Login Screen using the new design system
/// Features:
/// - Platform-adaptive components (Material/Cupertino)
/// - Proper accessibility support
/// - Haptic feedback
/// - Form validation
/// - Smooth animations
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
  
  // For long-press settings access
  Timer? _holdTimer;
  double _holdProgress = 0.0;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
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
    const maxTicks = 30; // 3 seconds

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
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    // Haptic feedback
    HapticFeedback.mediumImpact();

    setState(() => _isLoading = true);

    try {
      final isLoggedIn = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).login(context, _userNameController.text, _passwordController.text);

      if (isLoggedIn && mounted) {
        // Save or clear credentials based on remember me
        if (_rememberMe) {
          await LocalStorageManger.setString('username', _userNameController.text);
          await LocalStorageManger.setString('password', _passwordController.text);
        } else {
          await LocalStorageManger.removeString('username');
          await LocalStorageManger.removeString('password');
        }

        // Navigate to home
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: isSmallScreen ? AppSpacing.lg : AppSpacing.xxxl,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context),
                    
                    SizedBox(height: isSmallScreen ? AppSpacing.xl : AppSpacing.xxxl),
                    
                    // Login Card
                    _buildLoginCard(context),
                    
                    SizedBox(height: isSmallScreen ? AppSpacing.xl : AppSpacing.xxxl),
                    
                    // Footer
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Mobile',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Manage your services, streamlined.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Icon(
                Icons.arrow_circle_right,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Please Login to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.large,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Logo
            SvgPicture.asset(
              'images/svg/tol_vis_2.svg',
              width: 60,
              height: 60,
              colorFilter: const ColorFilter.mode(
                AppColors.success,
                BlendMode.srcIn,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Username Field
            _buildTextField(
              controller: _userNameController,
              focusNode: _userNameFocus,
              label: 'Username',
              placeholder: 'Enter your username',
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Password Field
            _buildTextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              label: 'Password',
              placeholder: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Remember Me
            _buildRememberMe(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Login Button
            AdaptiveButton(
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
              child: const Text(
                'LOGIN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Settings Link
            TextButton(
              onPressed: () => goTo(context, const SettingScreen()),
              child: Text(
                'Settings',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String placeholder,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    Widget? suffixIcon,
  }) {
    if (Platform.isIOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: placeholder,
              prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary),
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      );
    }
    
    // Material design
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Text(
            'Remember me',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Copyright @2025 BizDimension Cambodia',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onLongPressStart: (_) => _startHold(),
            onLongPressEnd: (_) => _endHold(),
            child: Column(
              children: [
                Text(
                  'All rights reserved',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                if (_holdProgress > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: _holdProgress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
