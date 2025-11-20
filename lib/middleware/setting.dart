import 'package:bizd_tech_service/constant/style.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostConfig = TextEditingController(text: "https://svr10.biz-dimension.com");
  final _portConfig = TextEditingController(text: "9093");
  // final _companyDB = TextEditingController(text: "SBOLK");

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final host = await LocalStorageManger.getString('host');
    final port = await LocalStorageManger.getString('port');
    // final companyDB = await LocalStorageManger.getString('companyDB');

    setState(() {
      if (host.isNotEmpty) {
        _hostConfig.text = host;
      }
      if (port.isNotEmpty) {
        _portConfig.text = port;
      }
      // if (companyDB.isNotEmpty) {
      //   _companyDB.text = companyDB;
      // }
    });
  }

  Future<void> saveSetting() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));
      await LocalStorageManger.setString('host', _hostConfig.text);
      await LocalStorageManger.setString('port', _portConfig.text);
      // await LocalStorageManger.setString('companyDB', _companyDB.text);

      if (mounted) {
        setState(() => loading = false);
        MaterialDialog.snackBar(context, "Settings saved successfully.");
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() => loading = false);
      MaterialDialog.snackBar(
          context, "Failed to save settings. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.6,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: const Text("Settings",
            style: TextStyle(color: Colors.black, fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(size(context).width * 0.055),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Address Configuration",
                        style: TextStyle(fontSize: 18, height: 1.7)),
                    const SizedBox(height: 30),
                    _buildTextField(_hostConfig, 'Web Server Address',
                        'Enter Web Server Address', TextInputType.url),
                    const SizedBox(height: 25),
                    _buildTextField(_portConfig, 'Port', 'Enter Port',
                        TextInputType.number),
                    const SizedBox(height: 25),
                    // _buildTextField(_companyDB, 'CompanyDB', 'Enter CompanyDB',
                    //     TextInputType.text),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: saveSetting,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor:
                            Color.fromARGB(255, 66, 83, 100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.0, // Smaller size
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white), // White color
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String hint, TextInputType inputType) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          hintText: hint,
          isDense: true),
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Text("Copyright © 2023 BizDimension Cambodia",
            style: TextStyle(fontSize: 14.5, color: Colors.grey)),
        SizedBox(height: 10),
        Text("All rights reserved",
            style: TextStyle(fontSize: 14.5, color: Colors.grey)),
        SizedBox(height: 30),
      ],
    );
  }
}
