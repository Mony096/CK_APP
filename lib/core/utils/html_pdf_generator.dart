// File location: lib/core/utils/html_pdf_generator.dart
// This file generates PDFs by first creating HTML, then converting to PDF
// WHY: Flutter's PDF library has poor Khmer font support. HTML rendering provides better font rendering.
// RELEVANT FILES: pdf_report_generator.dart, service_detail_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:hive/hive.dart';

import 'package:flutter_native_html_to_pdf/pdf_page_size.dart';

class HtmlServiceReportGenerator {
  /// Generate service report PDF using HTML rendering (better Khmer font support)
  static Future<File> generateServiceReport(Map<String, dynamic> data) async {
    debugPrint(
        '🧾 PDF data DocEntry=${data['DocEntry'] ?? 'N/A'} DocNum=${data['DocNum'] ?? data['id'] ?? 'N/A'}');
    final String currentUserName =
        await LocalStorageManger.getString('FullName');

    // Extract ticket number
    final String ticketNum =
        data['DocNum']?.toString() ?? data['id']?.toString() ?? 'N/A';

    // Format date
    final String dateStr = data['U_CK_Date'] != null
        ? DateFormat('dd-MMM-yy')
            .format(DateTime.parse(data['U_CK_Date'].toString().split('T')[0]))
        : 'N/A';

    // Parse time entries for technician section
    final List<dynamic> timeEntries =
        data['CK_JOB_TIMECollection'] as List? ?? [];

    final equipmentData = _extractEquipmentData(data);
    final String serialNo = equipmentData['serialNo'] ?? '';
    final String model = equipmentData['model'] ?? '';
    final String equipmentId = equipmentData['equipmentId'] ?? '';
    final String equipmentLocation = equipmentData['equipmentLocation'] ?? '';
    final String equipmentType = equipmentData['equipmentType'] ?? '';
    final String equipmentBrand = equipmentData['equipmentBrand'] ?? '';
    final String equipmentCode = equipmentData['equipmentCode'] ?? '';

    String dateArrived = '';

    String timeArrived = '';
    String dateCompleted = '';
    String timeCompleted = '';
    String totalHours = data['U_CK_Effort']?.toString() ?? '';

    for (var entry in timeEntries) {
      if (entry is Map) {
        final desc = entry['U_CK_Description']?.toString() ?? '';
        if (desc == 'Travel Time') {
          dateArrived = dateStr;
          timeArrived = entry['U_CK_EndTime']?.toString() ??
              entry['U_CK_StartTime']?.toString() ??
              '';
        } else if (desc == 'Service Time') {
          dateCompleted = dateStr;
          timeCompleted = entry['U_CK_EndTime']?.toString() ?? '';
          if (entry['U_CK_Effort'] != null) {
            totalHours = entry['U_CK_Effort'].toString();
          }
        }
      }
    }
    if (timeArrived.isEmpty) {
      timeArrived = data['U_CK_Time']?.toString() ?? '';
    }
    if (timeCompleted.isEmpty) {
      timeCompleted = data['U_CK_EndTime']?.toString() ?? '';
    }
    totalHours = _calculateDuration(timeArrived, timeCompleted, totalHours);

    final String diagnosis = _buildDiagnosis(data);

    // Build comprehensive report data map
    final Map<String, dynamic> reportData = {
      ...data,
      'reportNo': ticketNum,
      'reportDate': dateStr,
      'wod': _firstNonEmpty([
        data['U_CK_WOD']?.toString(),
        data['U_CK_Project']?.toString(),
      ]),
      'contract': data['U_CK_Contract']?.toString() ?? 'Yes',
      'customer': data['CustomerName']?.toString() ??
          data['U_CK_Cardname']?.toString() ??
          '',
      'ckNo': equipmentCode.isNotEmpty ? equipmentCode : 'N/A',
      'brand': equipmentBrand.isNotEmpty
          ? equipmentBrand
          : (data['U_CK_Brand']?.toString() ?? ''),
      'equipmentType': equipmentType.isNotEmpty ? equipmentType : 'N/A',
      'equipmentId': equipmentId,
      'lastPM': data['U_CK_LastPM'] ?? data['U_CK_Date'],
      'location': _firstNonEmpty([
        data['U_CK_WorkLoc']?.toString(),
        data['U_CK_Location']?.toString(),
        equipmentLocation,
      ]),
      'serviceType': data['U_CK_JobClass']?.toString() ??
          data['U_CK_ServiceType']?.toString() ??
          '',
      'hourMeter': data['U_CK_HourMeter']?.toString() ?? 'N/A',
      'customerRequest': data['U_CK_CustomerRequest']?.toString() ??
          data['U_CK_JobType']?.toString() ??
          '',
      'diagnosis': diagnosis,
      'measurements': data['U_CK_Measurements']?.toString() ?? '',
      'recommendation': data['U_CK_Recommendation']?.toString() ?? '',
      'problemFixed': data['U_CK_ProblemFixed']?.toString() ?? 'Yes',
      'attachedReport': data['U_CK_AttachedReport']?.toString() ?? 'No',
      'nop': data['U_CK_NOP']?.toString() ?? '',
      'reasonIfNotFixed': data['U_CK_ReasonIfNotFixed']?.toString() ?? '',
      'technician': currentUserName.isNotEmpty
          ? currentUserName
          : (data['U_CK_Technician']?.toString() ?? ''),
      'dateArrived': dateArrived,
      'timeArrived': timeArrived,
      'dateCompleted': dateCompleted,
      'timeCompleted': timeCompleted,
      'totalHours': totalHours,
      'serialNo': serialNo,
      'model': model,
    };

    // Load logo as base64
    String? logoBase64;
    try {
      final logoData = await rootBundle.load('images/logo-pdf.png');
      logoBase64 = base64Encode(logoData.buffer.asUint8List());
    } catch (e) {
      debugPrint('⚠️ Could not load logo: $e');
    }

    // Generate HTML content
    final htmlContent = _generateHtml(reportData, logoBase64);

    // Convert HTML to PDF
    final outputDir = await getApplicationDocumentsDirectory();

    try {
      final plugin = FlutterNativeHtmlToPdf();
      final pdfFile = await plugin.convertHtmlToPdf(
        html: htmlContent,
        targetDirectory: outputDir.path,
        targetName: 'service_report_$ticketNum',
        pageSize: PdfPageSize.a4,
      );

      if (pdfFile != null) {
        debugPrint('✅ Successfully generated PDF from HTML: ${pdfFile.path}');
        return pdfFile;
      } else {
        throw Exception('PDF file was null after conversion');
      }
    } catch (e) {
      debugPrint('❌ Error converting HTML to PDF: $e');
      rethrow;
    }
  }

  /// Get HTML content for preview (without creating PDF)
  static Future<String> getHtmlPreview(Map<String, dynamic> data) async {
    final String currentUserName =
        await LocalStorageManger.getString('FullName');

    // Extract ticket number
    final String ticketNum =
        data['DocNum']?.toString() ?? data['id']?.toString() ?? 'N/A';

    // Format date
    final String dateStr = data['U_CK_Date'] != null
        ? DateFormat('dd-MMM-yy')
            .format(DateTime.parse(data['U_CK_Date'].toString().split('T')[0]))
        : 'N/A';

    // Parse time entries
    final List<dynamic> timeEntries =
        data['CK_JOB_TIMECollection'] as List? ?? [];

    final equipmentData = _extractEquipmentData(data);
    final String serialNo = equipmentData['serialNo'] ?? '';
    final String model = equipmentData['model'] ?? '';
    final String equipmentId = equipmentData['equipmentId'] ?? '';
    final String equipmentLocation = equipmentData['equipmentLocation'] ?? '';
    final String equipmentType = equipmentData['equipmentType'] ?? '';
    final String equipmentBrand = equipmentData['equipmentBrand'] ?? '';
    final String equipmentCode = equipmentData['equipmentCode'] ?? '';

    String dateArrived = '';

    String timeArrived = '';
    String dateCompleted = '';
    String timeCompleted = '';
    String totalHours = data['U_CK_Effort']?.toString() ?? '';

    for (var entry in timeEntries) {
      if (entry is Map) {
        final desc = entry['U_CK_Description']?.toString() ?? '';
        if (desc == 'Travel Time') {
          dateArrived = dateStr;
          timeArrived = entry['U_CK_EndTime']?.toString() ??
              entry['U_CK_StartTime']?.toString() ??
              '';
        } else if (desc == 'Service Time') {
          dateCompleted = dateStr;
          timeCompleted = entry['U_CK_EndTime']?.toString() ?? '';
          if (entry['U_CK_Effort'] != null) {
            totalHours = entry['U_CK_Effort'].toString();
          }
        }
      }
    }
    if (timeArrived.isEmpty) {
      timeArrived = data['U_CK_Time']?.toString() ?? '';
    }
    if (timeCompleted.isEmpty) {
      timeCompleted = data['U_CK_EndTime']?.toString() ?? '';
    }
    totalHours = _calculateDuration(timeArrived, timeCompleted, totalHours);

    final Map<String, dynamic> reportData = {
      ...data,
      'reportNo': ticketNum,
      'reportDate': dateStr,
      'wod': _firstNonEmpty([
        data['U_CK_WOD']?.toString(),
        data['U_CK_Project']?.toString(),
      ]),
      'contract': data['U_CK_Contract']?.toString() ?? 'Yes',
      'customer': data['CustomerName']?.toString() ??
          data['U_CK_Cardname']?.toString() ??
          '',
      'ckNo': equipmentCode.isNotEmpty ? equipmentCode : 'N/A',
      'brand': equipmentBrand.isNotEmpty
          ? equipmentBrand
          : (data['U_CK_Brand']?.toString() ?? ''),
      'equipmentType': equipmentType.isNotEmpty ? equipmentType : 'N/A',
      'equipmentId': equipmentId,
      'lastPM': data['U_CK_LastPM'] ?? data['U_CK_Date'],
      'location': _firstNonEmpty([
        data['U_CK_WorkLoc']?.toString(),
        data['U_CK_Location']?.toString(),
        equipmentLocation,
      ]),
      'serviceType': data['U_CK_JobClass']?.toString() ??
          data['U_CK_ServiceType']?.toString() ??
          '',
      'hourMeter': data['U_CK_HourMeter']?.toString() ?? 'N/A',
      'customerRequest': data['U_CK_CustomerRequest']?.toString() ??
          data['U_CK_JobType']?.toString() ??
          '',
      'diagnosis': _buildDiagnosis(data),
      'measurements': data['U_CK_Measurements']?.toString() ?? '',
      'recommendation': data['U_CK_Recommendation']?.toString() ?? '',
      'problemFixed': data['U_CK_ProblemFixed']?.toString() ?? 'Yes',
      'attachedReport': data['U_CK_AttachedReport']?.toString() ?? 'No',
      'nop': data['U_CK_NOP']?.toString() ?? '',
      'reasonIfNotFixed': data['U_CK_ReasonIfNotFixed']?.toString() ?? '',
      'technician': currentUserName.isNotEmpty
          ? currentUserName
          : (data['U_CK_Technician']?.toString() ?? ''),
      'dateArrived': dateArrived,
      'timeArrived': timeArrived,
      'dateCompleted': dateCompleted,
      'timeCompleted': timeCompleted,
      'totalHours': totalHours,
      'serialNo': serialNo,
      'model': model,
    };

    // Load logo
    String? logoBase64;
    try {
      final logoData = await rootBundle.load('images/logo-pdf.png');
      logoBase64 = base64Encode(logoData.buffer.asUint8List());
    } catch (e) {
      debugPrint('⚠️ Could not load logo: $e');
    }

    return _generateHtml(reportData, logoBase64);
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  static Map<String, String> _extractEquipmentData(Map<String, dynamic> data) {
    final equipmentList = data['CK_JOB_EQUIPMENTCollection'] as List? ?? [];
    final entries = <String>[];
    String serialNo = '';
    String model = '';
    String location = '';
    String equipType = '';
    String equipBrand = '';
    String equipCode = '';
    final List<String> equipTypes = [];
    final Set<String> equipTypeSeen = {};
    final List<String> equipBrands = [];
    final Set<String> equipBrandSeen = {};
    final List<String> equipCodes = [];
    final Set<String> equipCodeSeen = {};

    for (final item in equipmentList) {
      if (item is! Map) continue;
      final name = item['U_CK_EquipName']?.toString().trim() ?? '';
      final code = item['U_CK_EquipCode']?.toString().trim() ?? '';
      final type = item['U_CK_EqType']?.toString().trim() ??
          item['U_CK_EquipType']?.toString().trim() ??
          '';
      final serial = item['U_CK_SerialNum']?.toString().trim() ?? '';
      final equipLocation = item['U_CK_Location']?.toString().trim() ?? '';
      final brand = item['U_CK_Brand']?.toString().trim() ?? '';

      if (serialNo.isEmpty && serial.isNotEmpty) serialNo = serial;
      if (model.isEmpty && name.isNotEmpty) model = name;
      if (location.isEmpty && equipLocation.isNotEmpty) location = equipLocation;
      if (equipType.isEmpty && type.isNotEmpty) equipType = type;
      if (equipBrand.isEmpty && brand.isNotEmpty) equipBrand = brand;
      if (equipCode.isEmpty && code.isNotEmpty) equipCode = code;
      if (type.isNotEmpty && !equipTypeSeen.contains(type)) {
        equipTypes.add(type);
        equipTypeSeen.add(type);
      }
      if (brand.isNotEmpty && !equipBrandSeen.contains(brand)) {
        equipBrands.add(brand);
        equipBrandSeen.add(brand);
      }
      if (code.isNotEmpty && !equipCodeSeen.contains(code)) {
        equipCodes.add(code);
        equipCodeSeen.add(code);
      }

      final parts = <String>[];
      if (name.isNotEmpty) parts.add(name);
      if (code.isNotEmpty && code != name) parts.add(code);
      if (type.isNotEmpty && type != name && type != code) parts.add(type);
      String label = parts.join(' / ');
      if (serial.isNotEmpty) {
        label = label.isNotEmpty ? '$label ($serial)' : serial;
      }
      if (label.isNotEmpty) entries.add(label);
    }

    // Fallback to offline equipment details if present
    final String eqId = data['U_CK_EquipmentID']?.toString() ?? '';
    if ((serialNo.isEmpty || model.isEmpty) && eqId.isNotEmpty) {
      try {
        final box = Hive.box('equipment_box');
        final List<dynamic> allEquips = box.get('equipments', defaultValue: []);
        final equip = allEquips.firstWhere(
          (e) => e['Code'] == eqId,
          orElse: () => <String, dynamic>{},
        );
        if (equip.isNotEmpty) {
          serialNo = serialNo.isNotEmpty
              ? serialNo
              : (equip['U_ck_eqSerNum']?.toString() ?? '');
          model =
              model.isNotEmpty ? model : (equip['U_ck_eqModel']?.toString() ?? '');
        }
      } catch (e) {
        debugPrint('⚠️ Could not fetch equipment details from Hive: $e');
      }
    }

    String equipmentIdValue = entries.join('<br/>');
    if (equipmentIdValue.trim().isEmpty) {
      equipmentIdValue = eqId;
      if (equipmentIdValue.isNotEmpty && serialNo.isNotEmpty) {
        equipmentIdValue = '$equipmentIdValue ($serialNo)';
      }
    }

    return {
      'equipmentId': equipmentIdValue,
      'serialNo': serialNo,
      'model': model,
      'equipmentLocation': location,
      'equipmentType': equipTypes.isNotEmpty ? equipTypes.join(', ') : equipType,
      'equipmentBrand':
          equipBrands.isNotEmpty ? equipBrands.join(', ') : equipBrand,
      'equipmentCode': equipCodes.isNotEmpty ? equipCodes.join(', ') : equipCode,
    };
  }

  static String _buildDiagnosis(Map<String, dynamic> data) {
    String diagnosis = data['U_CK_Diagnosis']?.toString() ?? '';
    final issues = data['CK_JOB_ISSUECollection'] as List? ?? [];
    final issueLines = <String>[];
    for (final item in issues) {
      if (item is! Map) continue;
      final desc = item['U_CK_IssueDesc']?.toString() ??
          item['U_CK_Description']?.toString() ??
          '';
      final trimmed = desc.toString().trim();
      if (trimmed.isNotEmpty) issueLines.add(trimmed);
    }

    if (issueLines.isNotEmpty) {
      final issueText = issueLines.map((line) => '- $line').join('\n');
      diagnosis = diagnosis.isEmpty ? issueText : '$diagnosis\n$issueText';
    }

    return diagnosis;
  }

  static String _resolveImageDescription(
    dynamic image,
    Map<String, String> remarksByRef,
    List<String> remarksInOrder,
    int index,
  ) {
    if (image is! Map) {
      if (index < remarksInOrder.length) return remarksInOrder[index];
      return 'Image';
    }
    String? name = image['name']?.toString();
    name ??= image['fileName']?.toString();
    name ??= image['filename']?.toString();
    name ??= image['refImage']?.toString();
    name ??= image['U_CK_FileName']?.toString();
    name ??= image['U_CK_RefImage']?.toString();

    String description = '';
    if (name != null && name.trim().isNotEmpty) {
      String normalized = name.toLowerCase().trim();
      if (normalized.contains('/')) {
        normalized = normalized.split('/').last;
      }
      description = remarksByRef[normalized] ??
          remarksByRef[
              normalized.replaceAll(RegExp(r'\.(jpg|jpeg|png)$'), '')] ??
          '';
    }

    if (description.isEmpty && index < remarksInOrder.length) {
      description = remarksInOrder[index];
    }

    if (description.isEmpty) {
      description = image['U_CK_Description']?.toString() ?? 'Image';
    }

    return description;
  }

  /// Generate HTML content matching App.tsx exactly
  static String _generateHtml(Map<String, dynamic> data, String? logoBase64) {
    // Extract parts/materials
    final parts = data['CK_JOB_MATERIALCollection'] as List? ?? [];

    // Extract files/attachments
    final List<dynamic> files = data['files'] as List? ?? [];

    // Attachment remarks (image title mapping)
    final List<dynamic> attachmentRemarks =
        data['CK_JOB_ATTACHMENT_REMARKS'] as List? ?? [];
    final Map<String, String> remarksByRef = {};
    final List<String> remarksInOrder = [];
    for (final remark in attachmentRemarks) {
      if (remark is! Map) continue;
      final desc = remark['desc']?.toString().trim() ?? '';
      final ref = remark['refImage']?.toString().trim() ?? '';
      if (desc.isNotEmpty) remarksInOrder.add(desc);
      if (ref.isNotEmpty && desc.isNotEmpty) {
        final refLower = ref.toLowerCase();
        remarksByRef[refLower] = desc;
        remarksByRef[refLower.replaceAll(RegExp(r'\.(jpg|jpeg|png)$'), '')] =
            desc;
      }
    }

    // Find signature and images
    final List<dynamic> allImageFiles = [];
    for (var f in files) {
      if (f is Map && f['data'] != null) {
        final ext = f['ext']?.toString().toLowerCase() ?? '';
        if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') {
          allImageFiles.add(f);
        }
      }
    }

    // Find signature (last PNG/JPG or one with signature description)
    Map<String, dynamic>? signatureFile;
    final List<dynamic> regularImages = [];

    for (var f in allImageFiles) {
      final desc = f['U_CK_Description']?.toString().toLowerCase() ?? '';
      if (desc.contains('signature') ||
          desc.contains('sign') ||
          desc.contains('ហត្ថលេខា')) {
        signatureFile = Map<String, dynamic>.from(f);
        break;
      }
    }

    if (signatureFile == null && allImageFiles.isNotEmpty) {
      signatureFile = Map<String, dynamic>.from(allImageFiles.last);
      regularImages.addAll(allImageFiles.sublist(0, allImageFiles.length - 1));
    } else {
      regularImages.addAll(allImageFiles.where((f) => f != signatureFile));
    }

    final images = regularImages.take(4).toList();

    // Build signature image
    String? signatureImage;
    if (signatureFile != null) {
      final ext = signatureFile['ext']?.toString().toLowerCase() ?? 'png';
      signatureImage =
          'data:image/${ext == 'jpg' ? 'jpeg' : ext};base64,${signatureFile['data']}';
    }

    // Build signature HTML
    String signatureHtml;
    if (signatureImage != null) {
      signatureHtml =
          '<div style="flex:1;display:flex;align-items:center;justify-content:center;padding:4px;"><img src="$signatureImage" style="max-height:80px;max-width:100%;" /></div>';
    } else {
      signatureHtml = '''
        <div style="flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;opacity:0.2;">
          <div style="font-size:20px;">✍️</div>
          <div style="font-size:8px;">REQUIRED SIGNATURE</div>
        </div>
      ''';
    }

    // Build parts HTML
    String partsHtml = '';
    for (var p in parts) {
      partsHtml +=
          '<div style="color:#1e3a8a;font-style:italic;font-weight:700;font-size:8px;padding:1px 0;">• ${p['U_CK_ItemName'] ?? ''} (Qty: ${p['U_CK_Qty'] ?? ''})</div>';
    }
    if (partsHtml.isEmpty) {
      partsHtml =
          '<div style="color:#9ca3af;font-size:8px;font-style:italic;">...</div>';
    }

    // Build images HTML
    String imagesHtml = '';
    for (int i = 0; i < 4; i++) {
      final borderRight = i == 3 ? 'none' : '1px solid #000';
      if (i < images.length) {
        final img = images[i];
        final imageData = 'data:image/png;base64,${img['data']}';
        final description =
            _resolveImageDescription(img, remarksByRef, remarksInOrder, i);
        imagesHtml += '''
          <div style="border-right:$borderRight;flex:1;display:flex;flex-direction:column;overflow:hidden;">
            <div style="flex:1;display:flex;align-items:center;justify-content:center;background:#fff;padding:2px;">
              <img src="$imageData" style="width:100%;height:100px;object-fit:cover;" />
            </div>
            <div style="padding:4px;font-size:8px;font-style:italic;color:#1e3a8a;font-weight:400;text-align:left;">$description</div>
          </div>
        ''';
      } else {
        imagesHtml += '''
          <div style="border-right:$borderRight;flex:1;display:flex;flex-direction:column;overflow:hidden;background:#fff;">
            <div style="flex:1;display:flex;align-items:center;justify-content:center;">
            </div>
            <div style="padding:4px;font-size:8px;font-style:italic;color:#e5e7eb;text-align:left;">NO PHOTO</div>
          </div>
        ''';
      }
    }

    // Build signature HTML
    if (signatureImage != null) {
      signatureHtml =
          '<div style="flex:1;display:flex;align-items:center;justify-content:center;padding:4px;"><img src="$signatureImage" style="max-height:80px;max-width:100%;" /></div>';
    } else {
      signatureHtml = '''
        <div style="flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;opacity:0.2;">
          <div style="font-size:20px;">✍️</div>
          <div style="font-size:8px;">REQUIRED SIGNATURE</div>
        </div>
      ''';
    }

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Report - ${data['reportNo']}</title>
    <link href="https://fonts.googleapis.com/css2?family=Siemreap&family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        @page { 
            size: A4 portrait; 
            margin: 10mm; 
        }
        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box;
            -webkit-print-color-adjust: exact;
            print-color-adjust: exact;
            page-break-after: avoid !important;
            break-after: avoid !important;
            page-break-before: avoid !important;
            break-before: avoid !important;
        }
        html, body {
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
        body {
            font-family: 'Inter', sans-serif;
            font-size: 8px;
            color: #000;
            line-height: 1.15;
            background: #fff;
        }
        .page-wrapper {
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        .khmer { font-family: 'Siemreap', cursive; font-size: 8px; }
        .container {
            width: 100%;
            border: 1px solid #000;
            display: flex;
            flex-direction: column;
        }
        .border-b { border-bottom: 1px solid #000; }
        .border-r { border-right: 1px solid #000; }
        .bg-green { background-color: #BCE6B4 !important; }
        .bg-grey { background-color: #f3f4f6 !important; }
        .p-1 { padding: 4px 5px; }
        .p-2 { padding: 8px; }
        .flex { display: flex; }
        .flex-col { display: flex; flex-direction: column; }
        .justify-between { justify-content: space-between; }
        .items-center { align-items: center; }
        .text-blue { color: #1e3a8a !important; }
        .italic { font-style: italic; }
        .bold { font-weight: 700; }
        .font-900 { font-weight: 900; }
        .w-full { width: 100%; }
        .w-50 { width: 50%; }
        .grid { display: grid; }
        .grid-12 { grid-template-columns: repeat(12, 1fr); }
        .span-6 { grid-column: span 6; }
        .span-4 { grid-column: span 4; }
        .span-8 { grid-column: span 8; }
        .span-3 { grid-column: span 3; }
        .span-5 { grid-column: span 5; }
        .min-h-1 { min-height: 22px; }
        .min-h-2 { min-height: 36px; }
        .min-h-diag { min-height: 50px; }
    </style>
</head>
<body>
    <div class="page-wrapper">
        <!-- Header -->
        <div class="grid grid-12" style="margin-bottom: 2px; border: none;">
            <div style="grid-column: span 4;">
                <div style="display: flex; align-items: center; gap: 8px;">
                    ${logoBase64 != null ? '<img src="data:image/png;base64,$logoBase64" style="height:40px;width:auto;" />' : '<span style="font-size:12px;font-weight:900;">CominKhmere</span>'}
                </div>
                <div class="bold" style="font-size: 10px; margin-top: 1px;">
                    <span class="khmer">របាយការណ៍សេវាកម្ម</span>/Service Report
                </div>
            </div>
            <div style="grid-column: span 3; display: flex; flex-direction: column; justify-content: flex-end; align-items: center;">
                 <div class="bold" style="font-size: 9px;">No: ${data['reportNo'] ?? 'N/A'}</div>
            </div>
            <div style="grid-column: span 5; text-align: right; font-size: 6.5px; padding-right: 4px;">
                <div class="italic">Hotline:</div>
                <div class="bold italic">PP: 012 816 800/SHV: 092 777 224</div>
                <div class="bold italic">SR: 012 222 723/PPIA: 092 777 143</div>
                <div class="bold italic">SVIA: 092 666 791</div>
            </div>
        </div>

        <div class="container">
            <!-- Info Section -->
            <div class="grid grid-12 border-b">
                <div class="span-4 border-r p-1 min-h-1 flex items-center justify-between">
                    <div><span class="khmer">កាលបរិច្ឆេទ</span>/ Date:</div>
                    <div class="text-blue italic bold">${data['reportDate'] ?? 'N/A'}</div>
                </div>
                <div class="span-4 border-r p-1 min-h-1 flex items-center justify-between">
                    <div>Quote No.:</div>
                    <div class="text-blue italic bold">${data['wod'] ?? ''}</div>
                </div>
                <div class="span-4 p-1 min-h-1 flex items-center justify-between">
                    <div>Contract:</div>
                    <div class="text-blue italic bold">${data['contract'] ?? 'Yes'}</div>
                </div>
            </div>

            <div class="grid grid-12 border-b">
                <div class="span-4 border-r p-1 flex items-center">
                    <div><span class="khmer">ឈ្មោះអតិថិជន</span> /<br>Customer particular</div>
                </div>
                <div class="span-4 border-r p-1 flex items-center text-blue italic bold">
                    ${data['customer'] ?? ''}
                </div>
                <div class="span-4 flex flex-col">
                    <div class="flex border-b" style="flex: 1;">
                        <div class="w-50 border-r p-1 flex items-center"><span class="khmer">លេខសម្គាល់</span>/ CK no</div>
                        <div class="w-50 p-1 text-blue italic bold flex items-center">${data['ckNo'] ?? ''}</div>
                    </div>
                    <div class="flex" style="flex: 1;">
                    <div class="w-50 border-r p-1 flex items-center"><span class="khmer">ម៉ាក</span> / Brand</div>
                    <div class="w-50 p-1 text-blue italic bold flex items-center">${data['brand'] ?? ''}</div>
                    </div>
                </div>
            </div>

            <div class="grid grid-12 border-b">
                <div class="span-4 border-r p-1 min-h-1">
                    <span class="khmer">ប្រភេទបរិក្ខារ</span> /Type of Equipment
                </div>
                <div class="span-8 grid grid-12">
                    <div class="span-6 border-r p-1 min-h-1 text-blue italic bold">${data['equipmentType'] ?? ''}</div>
                    <div class="span-3 border-r p-1 min-h-1"><span class="khmer">បរិក្ខារ</span>/Equipment</div>
                    <div class="span-3 p-1 min-h-1 text-blue italic bold" style="white-space: pre-wrap;">${data['equipmentId'] ?? ''}</div>
                </div>
            </div>

            <div class="grid grid-12 border-b">
                <div class="span-4 border-r p-1 min-h-1">
                    <span class="khmer">ថ្ងៃថែទាំចុងក្រោយ</span> / last PM
                </div>
                <div class="span-8 grid grid-12">
                    <div class="span-6 border-r p-1 min-h-1 text-blue italic bold">${_formatDate(data['lastPM'])}</div>
                    <div class="span-3 border-r p-1 min-h-1"><span class="khmer">ទីតាំង</span>/Location</div>
                    <div class="span-3 p-1 min-h-1 text-blue italic bold">${data['location'] ?? ''}</div>
                </div>
            </div>

            <div class="grid grid-12 border-b">
                <div class="span-4 border-r p-1 min-h-1">
                    <span class="khmer">ប្រភេទសេវាកម្ម</span> / Service type
                </div>
                <div class="span-8 grid grid-12">
                    <div class="span-6 border-r p-1 min-h-1 text-blue italic bold">${data['serviceType'] ?? ''}</div>
                    <div class="span-3 border-r p-1 min-h-1"><span class="khmer">កុងទ័រម៉ោង</span> / Hour Meter</div>
                    <div class="span-3 p-1 min-h-1 text-blue italic bold">${data['hourMeter'] ?? 'N/A'}</div>
                </div>
            </div>

            <!-- Header Row Green -->
            <div class="bg-green p-1 bold border-b">
                <span class="khmer">ការស្នើសុំ ស្ទើពីអតិថិជន</span>/Customer Request
            </div>
            <div class="p-1 min-h-1 border-b text-blue italic bold">
                ${data['customerRequest'] ?? data['equipmentType'] ?? ''}
            </div>

            <div class="bg-green p-1 bold border-b">
                <span class="khmer">ការវិនិច្ឆ័យកំហូច ឬការថែទាំជូន សេវាកម្មដែលបានផ្ដល់ជូន</span>/Diagnosis Defect Found Service Rendered
            </div>
            <div class="p-1 min-h-diag border-b text-blue italic bold" style="white-space: pre-wrap; font-size: 8px;">${data['diagnosis'] ?? ''}</div>

            <div class="grid grid-12 border-b">
                <div class="span-6 border-r flex flex-col">
                    <div class="bg-green p-1 bold border-b">
                        <span class="khmer">គ្រឿងបន្លាស់</span>/Part Supply
                    </div>
                    <div class="p-1" style="flex-grow: 1; min-height: 120px;">
                        $partsHtml
                    </div>
                </div>
                <div class="span-6 flex flex-col">
                    <div class="bg-green p-1 bold border-b" style="min-height: 14px;">
                        Measurements & Test Conducted (Tool serial.............)
                    </div>
                    <div class="flex flex-col" style="flex-grow: 1;">
                         <div class="p-1 min-h-2 text-blue italic bold">${data['measurements'] ?? ''}</div>
                         <div class="p-1 border-b text-right" style="margin-top: auto;">
                            <span class="khmer italic">កំហុសត្រូវបានជួសជុល</span>/Problem fixed upon departure: <span class="text-blue italic bold">${data['problemFixed'] ?? 'Yes'}</span>
                         </div>
                    </div>
                </div>
            </div>

            <div class="grid grid-12 border-b">
                <div class="span-6 border-r flex flex-col">
                    <div class="flex border-b">
                        <div class="w-full p-1 text-center">
                            <span class="khmer italic">របាយការណ៍ភ្ជាប់</span>/Attached report: <span class="text-blue bold">${data['attachedReport'] ?? 'No'}</span>
                        </div>
                    </div>
                    <div class="flex">
                        <div class="w-full p-1 text-center">
                            <span class="khmer italic">ចំនួនទំព័រ</span>/NOP: <span class="text-blue bold">${data['nop'] ?? ''}</span>
                        </div>
                    </div>
                </div>
                <div class="span-6 p-1 min-h-2 flex flex-col italic bold">
                    <div class="khmer" style="font-size: 6.5px;">បញ្ជាក់ពីមូលហេតុដែលមិនត្រូវបានជួសជុល និងដំណោះស្រាយ if not, mention why:</div>
                    <div class="text-blue" style="margin-top: 2px;">${data['reasonIfNotFixed'] ?? ''}</div>
                </div>
            </div>

            <div class="p-1 border-b italic bold" style="min-height: 40px;">
                Technician Recommendation: <span class="text-blue">${data['recommendation'] ?? ''}</span>
            </div>

            <div class="bg-green p-1 bold border-b">
                <span class="khmer">រូបភាពរបាយការណ៍</span>/ Picture Report
            </div>
            <div class="p-1 border-b" style="height: 130px; overflow: hidden; display: flex;">
                $imagesHtml
            </div>

            <div class="grid grid-12 border-b bg-green bold">
                <div class="span-6 border-r p-1"><span class="khmer">ជាងបច្ចេកទេស</span>/List of Technician</div>
                <div class="span-6 p-1 text-center">Customer: Name, Position, Date, Signature & Comments</div>
            </div>

            <div class="grid grid-12">
                <div class="span-6 border-r flex flex-col">
                    <div class="flex border-b" style="min-height: 72px;">
                        <div style="width: 30%;" class="p-1 border-r bold"><span class="khmer">ឈ្មោះ</span> Names</div>
                        <div style="flex-grow: 1;" class="p-1 text-blue italic bold flex items-center">${data['technician'] ?? ''}</div>
                    </div>
                    <div class="flex border-b">
                        <div style="width: 30%;" class="p-1 border-r bold">Date & Time Arrived</div>
                        <div style="flex-grow: 1;" class="p-1 text-blue italic bold">
                            ${_formatDateTime(data['reportDate'] ?? data['U_CK_Date'], data['timeArrived'])}
                        </div>
                    </div>
                    <div class="flex border-b">
                        <div style="width: 30%;" class="p-1 border-r bold">Date & Time Completed</div>
                        <div style="flex-grow: 1;" class="p-1 text-blue italic bold">
                            ${_formatDateTime(data['reportDate'] ?? data['U_CK_Date'], data['timeCompleted'])}
                        </div>
                    </div>
                    <div class="flex">
                        <div style="width: 30%;" class="p-1 border-r bold">Total Hour</div>
                        <div style="flex-grow: 1;" class="p-1 text-blue italic bold">${data['totalHours'] ?? ''}</div>
                    </div>
                </div>
                <div class="span-6 p-1 flex items-center justify-center">
                    $signatureHtml
                </div>
            </div>

            <div class="grid grid-12" style="height: 24px; border-top: 1px solid #000;">
                <div class="span-4 p-1 flex items-center justify-center">CK use:</div>
                <div class="span-4 p-1 flex items-center justify-center italic">Check by:</div>
                <div class="span-4 p-1 flex items-center justify-center">Checked on:</div>
            </div>
        </div>

        <!-- Footer Metadata -->
        <div class="flex justify-between items-end" style="margin-top: 4px;">
            <div style="font-size: 7px; color: #000; font-weight: 500;">
                <div>Form Number: CK-SDD-F-0042</div>
                <div>Revision: 2</div>
                <div>Date: ${DateFormat('dd-MMM-yyyy').format(DateTime.now())}</div>
                <div>Page: 1 of 1</div>
            </div>
        </div>
    </div>
</body>
</html>
''';
  }

  /// Format date string for display
  static String _formatDate(dynamic dateStr) {
    if (dateStr == null || dateStr == 'N/A' || dateStr == '') return 'N/A';
    try {
      final date = DateTime.parse(dateStr.toString().split('T')[0]);
      return DateFormat('dd-MMM-yy').format(date);
    } catch (e) {
      return dateStr.toString();
    }
  }

  static String _formatDateTime(dynamic dateStr, dynamic timeStr) {
    final datePart = _formatDate(dateStr);
    final timePart = (timeStr ?? '').toString().trim();
    if (timePart.isEmpty || timePart == 'N/A') return datePart;
    if (datePart.isEmpty || datePart == 'N/A') return timePart;
    return '$datePart, $timePart';
  }

  static String _calculateDuration(
      dynamic startTime, dynamic endTime, String fallback) {
    final startMinutes = _parseTimeToMinutes(startTime);
    final endMinutes = _parseTimeToMinutes(endTime);
    if (startMinutes == null || endMinutes == null) return fallback;

    var diff = endMinutes - startMinutes;
    if (diff < 0) diff += 24 * 60;
    final hours = diff ~/ 60;
    final minutes = diff % 60;
    return '${hours}h ${minutes}m';
  }

  static int? _parseTimeToMinutes(dynamic timeStr) {
    if (timeStr == null) return null;
    final raw = timeStr.toString().trim();
    if (raw.isEmpty || raw == 'N/A' || raw == '--:--') return null;

    if (raw.contains('T')) {
      try {
        final dt = DateTime.parse(raw);
        return dt.hour * 60 + dt.minute;
      } catch (_) {}
    }

    final formats = [
      DateFormat('HH:mm:ss'),
      DateFormat('HH:mm'),
      DateFormat('hh:mm a'),
      DateFormat('h:mm a'),
    ];

    for (final format in formats) {
      try {
        final dt = format.parse(raw);
        return dt.hour * 60 + dt.minute;
      } catch (_) {}
    }

    return null;
  }
}
