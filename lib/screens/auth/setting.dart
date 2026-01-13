import 'package:bizd_tech_service/core/core.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostConfig = TextEditingController(text: "https://svr10.biz-dimension.com");
  final _portConfig = TextEditingController(text: "9093");

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final host = await LocalStorageManger.getString('host');
    final port = await LocalStorageManger.getString('port');

    setState(() {
      if (host.isNotEmpty) _hostConfig.text = host;
      if (port.isNotEmpty) _portConfig.text = port;
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await LocalStorageManger.setString('host', _hostConfig.text);
      await LocalStorageManger.setString('port', _portConfig.text);

      if (mounted) {
        setState(() => _isLoading = false);
        // Using ScaffoldMessenger directly for more control or keeping existing helper
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Settings saved successfully', style: GoogleFonts.inter()),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        AdaptiveDialog.showAlert(
          context: context,
          title: 'Error',
          content: 'Failed to save settings. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "System Settings",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Connectivity",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Configure your server address and port",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF737373),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildTextField(
                        controller: _hostConfig,
                        label: 'Web Server Address',
                        hint: 'https://example.com',
                        inputType: TextInputType.url,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _portConfig,
                        label: 'Port',
                        hint: '9090',
                        inputType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _buildSaveButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType inputType,
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
            keyboardType: inputType,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: const Color(0xFFA3A3A3), fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
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
                'Save Settings',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

}
