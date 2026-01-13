import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../theme/app_tokens.dart';

/// Platform-adaptive text field that uses Material on Android and Cupertino on iOS
/// 
/// Usage:
/// ```dart
/// AdaptiveTextField(
///   controller: _emailController,
///   label: 'Email',
///   placeholder: 'Enter your email',
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
class AdaptiveTextField extends StatelessWidget {
  const AdaptiveTextField({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.focusNode,
    this.isRequired = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final int? minLines;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (Platform.isIOS)
          _buildCupertinoTextField(context)
        else
          _buildMaterialTextField(context),
      ],
    );
  }

  Widget _buildMaterialTextField(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autofocus,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? AppColors.surface : AppColors.surfaceVariant,
      ),
    );
  }

  Widget _buildCupertinoTextField(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autofocus,
      focusNode: focusNode,
      placeholder: placeholder,
      prefix: prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: prefixIcon,
            )
          : null,
      suffix: suffixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: suffixIcon,
            )
          : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: enabled ? AppColors.surface : AppColors.surfaceVariant,
        borderRadius: AppRadius.radiusSm,
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}

/// Platform-adaptive button
class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.isDestructive = false,
    this.style = AdaptiveButtonStyle.filled,
    this.fullWidth = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool isDestructive;
  final AdaptiveButtonStyle style;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    Widget button;
    
    if (isLoading) {
      button = _buildLoadingButton(context);
    } else if (Platform.isIOS) {
      button = _buildCupertinoButton(context);
    } else {
      button = _buildMaterialButton(context);
    }
    
    // Handle full width
    if (fullWidth) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: button,
      );
    }
    return button;
  }

  Widget _buildLoadingButton(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.minPositive, 50),
      ),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Platform.isIOS
            ? const CupertinoActivityIndicator(color: Colors.white)
            : const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
      ),
    );
  }

  Widget _buildMaterialButton(BuildContext context) {
    switch (style) {
      case AdaptiveButtonStyle.filled:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.minPositive, 50),
            backgroundColor: isDestructive ? AppColors.error : null,
          ),
          child: child,
        );
      case AdaptiveButtonStyle.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.minPositive, 50),
          ),
          child: child,
        );
      case AdaptiveButtonStyle.text:
        return TextButton(
          onPressed: onPressed,
          child: child,
        );
    }
  }

  Widget _buildCupertinoButton(BuildContext context) {
    switch (style) {
      case AdaptiveButtonStyle.filled:
        return CupertinoButton.filled(
          onPressed: onPressed,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: child,
        );
      case AdaptiveButtonStyle.outlined:
        return CupertinoButton(
          onPressed: onPressed,
          color: Colors.transparent,
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDestructive ? CupertinoColors.destructiveRed : AppColors.primary,
              ),
              borderRadius: AppRadius.radiusSm,
            ),
            child: child,
          ),
        );
      case AdaptiveButtonStyle.text:
        return CupertinoButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          child: child,
        );
    }
  }
}

enum AdaptiveButtonStyle { filled, outlined, text }

/// Platform-adaptive dialog
class AdaptiveDialog {
  /// Show a confirmation dialog
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    // Add haptic feedback
    HapticFeedback.mediumImpact();

    if (Platform.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        ),
      );
    }

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? ElevatedButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show an alert dialog
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    HapticFeedback.mediumImpact();

    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: Text(buttonText),
            ),
          ],
        ),
      );
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show a loading dialog
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Platform.isIOS
                    ? const CupertinoActivityIndicator(radius: 16)
                    : const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(message),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
