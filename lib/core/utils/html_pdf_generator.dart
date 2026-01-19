// File location: lib/core/utils/html_pdf_generator.dart
// This file generates PDFs by first creating HTML, then converting to PDF
// WHY: Flutter's PDF library has poor Khmer font support. HTML rendering provides better font rendering.
// RELEVANT FILES: pdf_report_generator.dart, service_detail_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:flutter_native_html_to_pdf/pdf_page_size.dart';
import 'package:flutter/services.dart';

class HtmlServiceReportGenerator {
  /// Generate service report PDF using HTML rendering (better Khmer font support)
  /// ...
  static Future<File> generateServiceReport(Map<String, dynamic> data) async {
    // Debug: Log all available fields from API response
    debugPrint('📋 PDF Generator - Available API fields:');
    data.forEach((key, value) {
      if (value is! List && value is! Map) {
        debugPrint('  $key: $value');
      } else if (value is List) {
        debugPrint('  $key: List[${value.length}]');
      } else {
        debugPrint('  $key: Map');
      }
    });

    // Load fonts for offline support
    final fontBase64 = await _loadFonts();

    // Extract ticket number
    final String ticketNum =
        data['DocNum']?.toString() ?? data['id']?.toString() ?? 'N/A';

    // Format date
    final String dateStr = data['U_CK_Date'] != null
        ? DateFormat('dd-MMM-yy')
            .format(DateTime.parse(data['U_CK_Date'].toString().split('T')[0]))
        : 'N/A';

    // Parse time entries for technician section
    // Matches React template: dateArrived, timeArrived, dateCompleted, timeCompleted
    final List<dynamic> timeEntries =
        data['CK_JOB_TIMECollection'] as List? ?? [];
    String dateArrived = '';
    String timeArrived = '';
    String dateCompleted = '';
    String timeCompleted = '';
    String totalHours = data['U_CK_Effort']?.toString() ?? '';

    debugPrint('📋 Time Entries: ${timeEntries.length}');
    for (var entry in timeEntries) {
      if (entry is Map) {
        final desc = entry['U_CK_Description']?.toString() ?? '';
        debugPrint('  Time entry: $desc');

        if (desc == 'Travel Time') {
          // Travel Time = when technician arrived
          dateArrived = dateStr; // Use service date as arrival date
          timeArrived = entry['U_CK_EndTime']?.toString() ??
              entry['U_CK_StartTime']?.toString() ??
              '';
        } else if (desc == 'Service Time') {
          // Service Time = when work was completed
          dateCompleted = dateStr; // Use service date as completion date
          timeCompleted = entry['U_CK_EndTime']?.toString() ?? '';
          // Calculate total hours from service time effort
          if (entry['U_CK_Effort'] != null) {
            totalHours = entry['U_CK_Effort'].toString();
          }
        }
      }
    }

    // Build comprehensive report data map matching React template's ServiceReportData
    final Map<String, dynamic> reportData = {
      ...data,
      // Basic info
      'reportNo': ticketNum,
      'reportDate': dateStr,
      'wod': data['U_CK_WOD']?.toString() ?? '',
      'contract': data['U_CK_Contract']?.toString() ?? 'Yes',

      // Customer info
      'customer': data['CustomerName']?.toString() ?? '',
      'ckNo': data['U_CK_CKNo']?.toString() ?? '',
      'brand': data['U_CK_Brand']?.toString() ?? '',

      // Equipment info
      'equipmentType': data['U_CK_JobType']?.toString() ?? '',
      'equipmentId': data['U_CK_EquipmentID']?.toString() ?? '',
      'lastPM': data['U_CK_LastPM'],
      'location': data['U_CK_Location']?.toString() ?? '',
      'serviceType': data['U_CK_ServiceType']?.toString() ?? '',
      'hourMeter': data['U_CK_HourMeter']?.toString() ?? 'N/A',

      // Service details
      'customerRequest': data['U_CK_CustomerRequest']?.toString() ??
          data['U_CK_JobType']?.toString() ??
          '',
      'diagnosis': data['U_CK_Diagnosis']?.toString() ?? '',
      'measurements': data['U_CK_Measurements']?.toString() ?? '',
      'recommendation': data['U_CK_Recommendation']?.toString() ?? '',

      // Status
      'problemFixed': data['U_CK_ProblemFixed']?.toString() ?? 'Yes',
      'attachedReport': data['U_CK_AttachedReport']?.toString() ?? 'No',
      'nop': data['U_CK_NOP']?.toString() ?? '',
      'reasonIfNotFixed': data['U_CK_ReasonIfNotFixed']?.toString() ?? '',

      // Technician info (matching React template format)
      'technician': data['U_CK_Technician']?.toString() ?? '',
      'dateArrived': dateArrived,
      'timeArrived': timeArrived,
      'dateCompleted': dateCompleted,
      'timeCompleted': timeCompleted,
      'totalHours': totalHours,
    };

    debugPrint('📋 Mapped report data:');
    debugPrint('  reportNo: ${reportData['reportNo']}');
    debugPrint('  customer: ${reportData['customer']}');
    debugPrint('  technician: ${reportData['technician']}');
    debugPrint(
        '  dateArrived: ${reportData['dateArrived']} ${reportData['timeArrived']}');
    debugPrint(
        '  dateCompleted: ${reportData['dateCompleted']} ${reportData['timeCompleted']}');

    // Generate HTML content with embedded fonts
    final htmlContent = _generateHtml(reportData, fontBase64);

    // Convert HTML to PDF using flutter_native_html_to_pdf
    // This package has excellent support for complex scripts like Khmer
    final outputDir = await getApplicationDocumentsDirectory();

    try {
      final plugin = FlutterNativeHtmlToPdf();

      // Convert HTML to PDF file
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

  static Future<Map<String, String>> _loadFonts() async {
    final fonts = <String, String>{};
    try {
      // Load Khmer OS Siemreap
      final khmerData =
          await rootBundle.load('assets/fonts/Khmer OS Siemreap Regular.ttf');
      fonts['khmer'] = base64Encode(khmerData.buffer.asUint8List());

      // Note: We could also load 'NotoSansKhmer-Regular.ttf' if preferred
    } catch (e) {
      debugPrint('⚠️ Could not load Khmer font for HTML: $e');
    }
    return fonts;
  }

  /// Generate HTML content for the service report
  /// Matches the React App.tsx template exactly with all Tailwind styles converted to inline CSS
  static String _generateHtml(
      Map<String, dynamic> data, Map<String, String> fonts) {
    // Extract parts/materials collection
    final parts = data['CK_JOB_MATERIALCollection'] as List? ?? [];

    // Extract files/attachments
    final List<dynamic> files = data['files'] as List? ?? [];

    // Debug: Log all files to understand structure
    debugPrint('📎 Files in API response: ${files.length}');
    for (int i = 0; i < files.length; i++) {
      final f = files[i];
      if (f is Map) {
        final ext = f['ext']?.toString() ?? 'unknown';
        final desc = f['U_CK_Description']?.toString() ?? 'no description';
        final hasData = f['data'] != null;
        debugPrint('  [$i] ext: $ext, desc: $desc, hasData: $hasData');
      }
    }

    // Separate images from signature
    final List<dynamic> allImageFiles = [];

    for (var f in files) {
      if (f is Map && f['data'] != null) {
        final ext = f['ext']?.toString().toLowerCase() ?? '';
        if (ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'pdf') {
          allImageFiles.add(f);
        }
      }
    }

    debugPrint('  Found ${allImageFiles.length} total image/PDF files');

    // Method 1: Check for explicit signature descriptions
    Map<String, dynamic>? signatureFile;
    final List<dynamic> regularImages = [];

    // First pass: look for explicit PNG/JPG signatures
    for (var f in allImageFiles) {
      final desc = f['U_CK_Description']?.toString().toLowerCase() ?? '';
      final ext = f['ext']?.toString().toLowerCase() ?? '';

      final isPngJpgSignature =
          (ext == 'png' || ext == 'jpg' || ext == 'jpeg') &&
              (desc.contains('signature') ||
                  desc.contains('sign') ||
                  desc.contains('ហត្ថលេខា') ||
                  desc.contains('ហត្ថ'));

      if (isPngJpgSignature) {
        signatureFile = Map<String, dynamic>.from(f);
        debugPrint(
            '  → Found PNG/JPG signature by description: ext=$ext, desc="$desc"');
        break;
      }
    }

    // Second pass: if no PNG/JPG signature found, look for PDF signatures
    if (signatureFile == null) {
      for (var f in allImageFiles) {
        final desc = f['U_CK_Description']?.toString().toLowerCase() ?? '';
        final ext = f['ext']?.toString().toLowerCase() ?? '';

        final isAnySignature = desc.contains('signature') ||
            desc.contains('sign') ||
            desc.contains('ហត្ថលេខា') ||
            desc.contains('ហត្ថ') ||
            ext == 'pdf';

        if (isAnySignature) {
          signatureFile = Map<String, dynamic>.from(f);
          debugPrint(
              '  → Found signature (PDF or other): ext=$ext, desc="$desc"');
          break;
        }
      }
    }

    // Remove signature from regular images list
    if (signatureFile != null) {
      regularImages.removeWhere((f) => f == signatureFile);
    } else {
      regularImages.addAll(allImageFiles);
    }

    // Method 2: If no signature found, use the last PNG/JPG as signature
    if (signatureFile == null && regularImages.isNotEmpty) {
      final pngJpgFiles = regularImages.where((f) {
        final ext = f['ext']?.toString().toLowerCase() ?? '';
        return ext == 'png' || ext == 'jpg' || ext == 'jpeg';
      }).toList();

      if (pngJpgFiles.isNotEmpty) {
        signatureFile = Map<String, dynamic>.from(pngJpgFiles.last);
        regularImages.remove(signatureFile);
        debugPrint(
            '  → Using last PNG/JPG as signature (most reliable method)');
      }
    }

    // Use remaining images for picture report (max 4)
    final images = regularImages.take(4).toList();
    debugPrint(
        '📸 Report images: ${images.length}, Signature found: ${signatureFile != null}');

    // Build signature image data URL
    String? signatureImage;
    if (signatureFile != null) {
      final ext = signatureFile['ext']?.toString().toLowerCase() ?? '';
      if (ext == 'png' || ext == 'jpg' || ext == 'jpeg') {
        signatureImage =
            'data:image/${ext == 'jpg' ? 'jpeg' : ext};base64,${signatureFile['data']}';
        debugPrint('✅ Signature PNG/JPG image ready for display');
      }
    }

    // Build parts HTML
    String partsHtml = '';
    for (var p in parts) {
      partsHtml +=
          '<div style="color: #1e40af; font-style: italic; font-weight: 600; font-size: 11px; padding: 2px 0;">- ${p['U_CK_ItemName'] ?? ''} (Qty: ${p['U_CK_Qty'] ?? ''})</div>';
    }
    if (partsHtml.isEmpty) {
      partsHtml =
          '<div style="color: #9ca3af; font-size: 10px; font-style: italic;">...</div>';
    }

    // Build images HTML
    String imagesHtml = '';
    for (int i = 0; i < images.length; i++) {
      final img = images[i];
      // Only add right border if it's NOT the last column (index 3)
      final borderRight = i == 3 ? 'none' : '1px solid #000';

      try {
        final imageData = 'data:image/png;base64,${img['data']}';
        final description = img['U_CK_Description']?.toString() ?? 'Image';
        imagesHtml += '''
          <div style="border-right: $borderRight; flex: 1; display: flex; flex-direction: column; overflow: hidden;">
            <div style="flex: 1; display: flex; align-items: center; justify-content: center; background: #f9fafb;">
              <img src="$imageData" style="width: 100%; height: 100px; object-fit: cover;" />
            </div>
            <div style="padding: 6px; border-top: 1px solid #000; font-size: 9px; font-style: italic; color: #1e40af; font-weight: 900; text-align: center; text-transform: uppercase; letter-spacing: -0.025em; background: #fff;">$description</div>
          </div>
        ''';
      } catch (e) {
        // Skip invalid images
      }
    }
    // Fill remaining slots with empty placeholders (up to 4)
    for (var i = images.length; i < 4; i++) {
      imagesHtml += '''
        <div style="border-right: ${i < 3 ? '1px solid #000' : 'none'}; flex: 1; display: flex; flex-direction: column; overflow: hidden;">
          <div style="flex: 1; display: flex; align-items: center; justify-content: center; background: #f9fafb;">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#d1d5db" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2-2z"></path><circle cx="12" cy="13" r="4"></circle></svg>
          </div>
          <div style="padding: 6px; border-top: 1px solid #000; font-size: 9px; font-style: italic; color: #d1d5db; font-weight: 900; text-align: center; text-transform: uppercase; background: #fff;">—</div>
        </div>
      ''';
    }

    // Build signature HTML
    String signatureHtml;
    if (signatureImage != null) {
      signatureHtml =
          '<img src="$signatureImage" style="max-height: 60px; max-width: 100%;" />';
    } else if (signatureFile != null) {
      signatureHtml = '''
        <div style="text-align: center; color: #6b7280;">
          <div style="font-size: 32px;">📝</div>
          <div style="font-size: 9px; font-weight: 900; text-transform: uppercase; letter-spacing: 0.1em; color: #9ca3af; margin-top: 4px;">Sign Above</div>
        </div>
      ''';
    } else {
      signatureHtml = '''
        <div style="flex: 1; border: 2px dashed #e5e7eb; border-radius: 12px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 8px;">
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#e5e7eb" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19l7-7 3 3-7 7-3-3z"></path><path d="M18 13l-1.5-7.5L2 2l3.5 14.5L13 18l5-5z"></path><path d="M2 2l7.586 7.586"></path><circle cx="11" cy="11" r="2"></circle></svg>
          <span style="font-size: 9px; font-weight: 900; color: #d1d5db; text-transform: uppercase; letter-spacing: 0.1em;">Sign Above</span>
        </div>
      ''';
    }

    // Font face definition
    final fontFace = fonts['khmer'] != null
        ? '''
          @font-face {
              font-family: 'Battambang';
              src: url(data:font/truetype;charset=utf-8;base64,${fonts['khmer']}) format('truetype');
          }
          '''
        : '';

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Report - ${data['reportNo']}</title>
    <style>
        $fontFace
        
        @page {
            size: A4;
            margin: 0;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            font-size: 11px;
            color: #000;
            line-height: 1.4;
            background: #fff;
            -webkit-print-color-adjust: exact;
            print-color-adjust: exact;
        }
        
        .khmer-font {
            font-family: 'Battambang', 'Khmer OS Siemreap', 'Khmer OS', cursive, sans-serif;
        }
        
        .report-container {
            width: 210mm;
            min-height: 297mm;
            padding: 24px 40px;
            background: #fff;
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <div class="report-container">
        
        <!-- Header Section -->
        <div style="display: flex; margin-bottom: 12px;">
            <!-- Left: Logo + Title -->
            <div style="flex: 5; display: flex; flex-direction: column;">
                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 6px;">
                    <!-- Logo -->
                    <div style="width: 40px; height: 40px; border: 3px solid #000; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 4px;">
                        <div style="width: 100%; height: 100%; border: 2px solid #10b981; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                            <div style="width: 6px; height: 6px; background: #10b981; border-radius: 50%;"></div>
                        </div>
                    </div>
                    <div style="line-height: 1;">
                        <span style="font-size: 24px; font-weight: 900; letter-spacing: -0.05em; color: #000;">CominKhmere</span>
                    </div>
                </div>
                <h2 style="font-size: 16px; font-weight: 700; display: flex; align-items: center; gap: 8px;">
                    <span class="khmer-font" style="font-size: 18px; line-height: 1;">របាយការណ៍សេវាកម្ម</span>
                    <span style="color: #d1d5db;">/</span>
                    <span style="text-transform: uppercase; letter-spacing: -0.025em; font-size: 14px;">Service Report</span>
                </h2>
            </div>
            
            <!-- Center: Report Number -->
            <div style="flex: 3; display: flex; flex-direction: column; justify-content: flex-end; align-items: center; padding-bottom: 8px;">
                <div style="font-weight: 700; font-size: 14px;">
                    No: <span style="font-weight: 900; color: #dc2626; margin-left: 4px; font-family: monospace;">${data['reportNo'] ?? 'N/A'}</span>
                </div>
            </div>
            
            <!-- Right: Hotline -->
            <div style="flex: 4; text-align: right;">
                <div style="font-weight: 700; font-size: 9px; margin-bottom: 4px; color: #6b7280; text-transform: uppercase; letter-spacing: 0.1em;">Hotline</div>
                <div style="font-size: 8px; line-height: 1.4; font-weight: 700; color: #000; font-style: italic;">
                    <div>PP: 012 816 800 / SHV: 092 777 224</div>
                    <div>SR: 012 222 723 / PPIA: 092 777 143</div>
                    <div>SVIA: 092 666 791</div>
                </div>
            </div>
        </div>

        <!-- Info Grid -->
        <div style="border-top: 1px solid #000; border-left: 1px solid #000; border-right: 1px solid #000;">
            <!-- Row 1: Date, WOD, Contract -->
            <div style="display: flex;">
                <div style="flex: 4; border-right: 1px solid #000; border-bottom: 1px solid #000; padding: 6px; min-height: 42px; display: flex; flex-direction: column; justify-content: center;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: -0.025em; color: #000;">
                        <span class="khmer-font" style="font-size: 10px; font-weight: 400; line-height: 1;">កាលបរិច្ឆេទ</span>
                        <span style="color: #9ca3af; font-weight: 400;">/</span>
                        <span>Date</span>
                    </div>
                    <div style="font-size: 11px; font-style: italic; font-weight: 600; color: #1e40af; margin-top: 2px;">${data['reportDate'] ?? 'N/A'}</div>
                </div>
                <div style="flex: 4; border-right: 1px solid #000; border-bottom: 1px solid #000; padding: 6px; min-height: 42px; display: flex; flex-direction: column; justify-content: center;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: -0.025em; color: #000;">
                        <span class="khmer-font" style="font-size: 10px; font-weight: 400; line-height: 1;">WOD</span>
                        <span style="color: #9ca3af; font-weight: 400;">/</span>
                        <span>WOD</span>
                    </div>
                    <div style="font-size: 11px; font-style: italic; font-weight: 600; color: #1e40af; margin-top: 2px;">${data['wod'] ?? ''}</div>
                </div>
                <div style="flex: 4; border-bottom: 1px solid #000; padding: 6px; min-height: 42px; display: flex; align-items: center; justify-content: flex-end; padding-right: 16px; font-weight: 900; font-size: 10px;">
                    CONTRACT: <span style="color: #1d4ed8; margin-left: 8px; font-style: italic; text-decoration: underline; text-decoration-color: #bfdbfe;">${data['contract'] ?? 'Yes'}</span>
                </div>
            </div>

            <!-- Row 2: Customer, CK No -->
            <div style="display: flex;">
                <div style="flex: 6; border-right: 1px solid #000; border-bottom: 1px solid #000; padding: 6px; min-height: 42px; display: flex; flex-direction: column; justify-content: center;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: -0.025em; color: #000;">
                        <span class="khmer-font" style="font-size: 10px; font-weight: 400; line-height: 1;">ឈ្មោះអតិថិជន</span>
                        <span style="color: #9ca3af; font-weight: 400;">/</span>
                        <span>Customer particular</span>
                    </div>
                    <div style="font-size: 11px; font-style: italic; font-weight: 600; color: #1e40af; margin-top: 2px;">${data['customer'] ?? ''}</div>
                </div>
                <div style="flex: 6; border-bottom: 1px solid #000; padding: 6px; min-height: 42px; display: flex; flex-direction: column; justify-content: center;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: -0.025em; color: #000;">
                        <span class="khmer-font" style="font-size: 10px; font-weight: 400; line-height: 1;">លេខសម្គាល់</span>
                        <span style="color: #9ca3af; font-weight: 400;">/</span>
                        <span>CK no</span>
                    </div>
                    <div style="font-size: 11px; font-style: italic; font-weight: 600; color: #1e40af; margin-top: 2px;">${data['ckNo'] ?? ''}</div>
                </div>
            </div>

            <!-- Row 3: Empty, Brand -->
            <div style="display: flex;">
                <div style="flex: 6; border-right: 1px solid #000; border-bottom: 1px solid #000; background: rgba(249,250,251,0.2);"></div>
                <div style="flex: 6; border-bottom: 1px solid #000; padding: 6px; min-height: 42px; display: flex; flex-direction: column; justify-content: center;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: -0.025em; color: #000;">
                        <span class="khmer-font" style="font-size: 10px; font-weight: 400; line-height: 1;">ម៉ាក</span>
                        <span style="color: #9ca3af; font-weight: 400;">/</span>
                        <span>Brand</span>
                    </div>
                    <div style="font-size: 11px; font-style: italic; font-weight: 600; color: #1e40af; margin-top: 2px;">${data['brand'] ?? ''}</div>
                </div>
            </div>

            <!-- Row 4: Type of Equipment, Equipment -->
            <div style="display: flex;">
                <div style="flex: 6; border-right: 1px solid #000; border-bottom: 1px solid #000; padding: 6px; min-height: 42px; display: flex; flex-direction: column; justify-content: center;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: -0.025em; color: #000;">
                        <span class="khmer-font" style="font-size: 10px; font-weight: 400; line-height: 1;">ប្រភេទបរិក្ខារ</span>
                        <span style="color: #9ca3af; font-weight: 400;">/</span>
                        <span>Type of Equipment</span>
                    </div>
                    <div style="font-size: 11px; font-style: italic; font-weight: 600; color: #1e40af; margin-top: 2px;">${data['equipmentType'] ?? ''}</div>
                </div>
                <div style="flex: 6; border-bottom: 1px solid #000; padding: 6px; min-height: 42px; display: flex; flex-direction: column; justify-content: center;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: -0.025em; color: #000;">
                        <span class="khmer-font" style="font-size: 10px; font-weight: 400; line-height: 1;">បរិក្ខារ</span>
                        <span style="color: #9ca3af; font-weight: 400;">/</span>
                        <span>Equipment</span>
                    </div>
                    <div style="font-size: 11px; font-style: italic; font-weight: 600; color: #1e40af; margin-top: 2px;">${data['equipmentId'] ?? ''}</div>
                </div>
            </div>

            <!-- Row 5: Last PM, Location -->
            <div style="display: flex;">
                <div style="flex: 6; border-right: 1px solid #000; border-bottom: 1px solid #000; padding: 6px; min-height: 42px; display: flex; flex-direction: column; justify-content: center;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: -0.025em; color: #000;">
                        <span class="khmer-font" style="font-size: 10px; font-weight: 400; line-height: 1;">ថ្ងៃថែទាំចុងក្រោយ</span>
                        <span style="color: #9ca3af; font-weight: 400;">/</span>
                        <span>last PM</span>
                    </div>
                    <div style="font-size: 11px; font-style: italic; font-weight: 600; color: #1e40af; margin-top: 2px;">${_formatDate(data['lastPM'])}</div>
                </div>
                <div style="flex: 6; border-bottom: 1px solid #000; padding: 6px; min-height: 42px; display: flex; flex-direction: column; justify-content: center;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: -0.025em; color: #000;">
                        <span class="khmer-font" style="font-size: 10px; font-weight: 400; line-height: 1;">ទីតាំង</span>
                        <span style="color: #9ca3af; font-weight: 400;">/</span>
                        <span>Location</span>
                    </div>
                    <div style="font-size: 11px; font-style: italic; font-weight: 600; color: #1e40af; margin-top: 2px;">${data['location'] ?? ''}</div>
                </div>
            </div>

            <!-- Row 6: Service Type, Hour Meter -->
            <div style="display: flex;">
                <div style="flex: 6; border-right: 1px solid #000; border-bottom: 1px solid #000; padding: 6px; min-height: 42px; display: flex; flex-direction: column; justify-content: center;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: -0.025em; color: #000;">
                        <span class="khmer-font" style="font-size: 10px; font-weight: 400; line-height: 1;">ប្រភេទសេវាកម្ម</span>
                        <span style="color: #9ca3af; font-weight: 400;">/</span>
                        <span>Service type</span>
                    </div>
                    <div style="font-size: 11px; font-style: italic; font-weight: 600; color: #1e40af; margin-top: 2px;">${data['serviceType'] ?? ''}</div>
                </div>
                <div style="flex: 6; border-bottom: 1px solid #000; padding: 6px; min-height: 42px; display: flex; flex-direction: column; justify-content: center;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: -0.025em; color: #000;">
                        <span class="khmer-font" style="font-size: 10px; font-weight: 400; line-height: 1;">កុងទ័រម៉ោង</span>
                        <span style="color: #9ca3af; font-weight: 400;">/</span>
                        <span>Hour Meter</span>
                    </div>
                    <div style="font-size: 11px; font-style: italic; font-weight: 600; color: #1e40af; margin-top: 2px;">${data['hourMeter'] ?? 'N/A'}</div>
                </div>
            </div>
        </div>

        <!-- Customer Request Section -->
        <div style="border-left: 1px solid #000; border-right: 1px solid #000;">
            <div style="background: #BCE6B4; padding: 6px 12px; font-weight: 700; display: flex; align-items: center; gap: 8px; border-bottom: 1px solid #000; font-size: 10px;">
                <span class="khmer-font" style="font-size: 11px; font-weight: 500; line-height: 1;">ការស្នើសុំ ស្ទើពីអតិថិជន</span>
                <span style="color: rgba(0,0,0,0.3); font-weight: 400;">/</span>
                <span style="text-transform: uppercase; letter-spacing: 0.05em; color: #000;">Customer Request</span>
            </div>
            <div style="padding: 8px; min-height: 40px; border-bottom: 1px solid #000; background: #fff; color: #1e40af; font-style: italic; font-weight: 600; font-size: 11px; display: flex; align-items: center;">
                ${data['customerRequest'] ?? data['equipmentType'] ?? ''}
            </div>
        </div>

        <!-- Diagnosis Section -->
        <div style="border-left: 1px solid #000; border-right: 1px solid #000;">
            <div style="background: #BCE6B4; padding: 6px 12px; font-weight: 700; display: flex; align-items: center; gap: 8px; border-bottom: 1px solid #000; font-size: 10px;">
                <span class="khmer-font" style="font-size: 11px; font-weight: 500; line-height: 1;">ការវិនិច្ឆ័យកំហូច ឬការថែទាំជូន សេវាកម្មដែលបានផ្ដល់ជូន</span>
                <span style="color: rgba(0,0,0,0.3); font-weight: 400;">/</span>
                <span style="text-transform: uppercase; letter-spacing: 0.05em; color: #000;">Diagnosis Defect Found / Service Rendered</span>
            </div>
            <div style="padding: 12px; min-height: 120px; border-bottom: 1px solid #000; background: #fff;">
                <div style="white-space: pre-wrap; font-style: italic; color: #1e40af; line-height: 1.5; font-weight: 600; font-size: 11px;">${data['diagnosis'] ?? ''}</div>
            </div>
        </div>

        <!-- Parts & Measurements Table -->
        <div style="border-left: 1px solid #000; border-right: 1px solid #000;">
            <div style="display: flex; border-bottom: 1px solid #000;">
                <!-- Part Supply Column -->
                <div style="flex: 1; border-right: 1px solid #000; display: flex; flex-direction: column;">
                    <div style="background: #BCE6B4; padding: 6px 12px; font-weight: 700; border-bottom: 1px solid #000; font-size: 10px;">
                        <span class="khmer-font" style="font-size: 11px; font-weight: 500; line-height: 1;">គ្រឿងបន្លាស់</span>
                        <span style="color: rgba(0,0,0,0.3); font-weight: 400;"> / </span>
                        <span style="text-transform: uppercase; letter-spacing: 0.05em; color: #000;">Part Supply</span>
                    </div>
                    <div style="padding: 8px; min-height: 100px; background: #fff; display: flex; flex-direction: column; gap: 4px;">
                        $partsHtml
                    </div>
                </div>
                <!-- Measurements Column -->
                <div style="flex: 1; display: flex; flex-direction: column;">
                    <div style="background: #BCE6B4; padding: 6px 12px; font-weight: 700; border-bottom: 1px solid #000; font-size: 10px;">
                        Measurements & Test Conducted (Tool serial.............)
                    </div>
                    <div style="padding: 8px; min-height: 100px; position: relative; background: #fff; display: flex; flex-direction: column; flex: 1;">
                        <div style="flex: 1; font-style: italic; color: #1e40af; font-weight: 600; font-size: 11px;">${data['measurements'] ?? ''}</div>
                        <div style="margin-top: auto; border-top: 1px solid #f3f4f6; padding-top: 4px; display: flex; justify-content: flex-end; gap: 8px; align-items: center; font-weight: 900; font-size: 9px; text-transform: uppercase; letter-spacing: -0.05em;">
                            <span class="khmer-font" style="text-transform: none; font-weight: 700; font-size: 10px;">កំហុសត្រូវបានជួសជុល</span>
                            <span style="color: #9ca3af;">/</span>
                            PROBLEM FIXED:
                            <span style="color: #1d4ed8; margin-left: 4px; font-style: italic;">${data['problemFixed'] ?? 'Yes'}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Attached Report & Comments Row -->
        <div style="border-left: 1px solid #000; border-right: 1px solid #000;">
            <div style="display: flex; border-bottom: 1px solid #000;">
                <div style="flex: 1; border-right: 1px solid #000;">
                    <div style="border-bottom: 1px solid #000; padding: 8px; display: flex; justify-content: center; align-items: center; font-style: italic; font-weight: 900; font-size: 10px; text-transform: uppercase;">
                        <span class="khmer-font" style="font-style: normal; text-transform: none; margin-right: 8px; font-weight: 700; font-size: 11px;">របាយការណ៍ភ្ជាប់</span>
                        <span style="color: #9ca3af; margin-right: 8px;">/</span>
                        ATTACHED REPORT:
                        <span style="color: #1d4ed8; margin-left: 12px;">${data['attachedReport'] ?? 'No'}</span>
                    </div>
                    <div style="padding: 8px; display: flex; justify-content: center; align-items: center; font-weight: 900; font-size: 10px; text-transform: uppercase;">
                        <span class="khmer-font" style="margin-right: 8px; font-weight: 700; font-size: 11px;">ចំនួនទំព័រ</span>
                        <span style="color: #9ca3af; margin-right: 8px;">/</span>
                        NOP:
                        <span style="width: 48px; margin-left: 8px; text-align: center; color: #1d4ed8; font-weight: 900; font-style: italic; border-bottom: 1px solid #dbeafe;">${data['nop'] ?? ''}</span>
                    </div>
                </div>
                <div style="flex: 1; padding: 8px; font-style: italic; font-size: 9px; line-height: 1.4; font-weight: 900; background: #fff;">
                    <div style="display: flex; align-items: center; gap: 6px; margin-bottom: 4px; text-transform: uppercase; letter-spacing: -0.025em;">
                        <span class="khmer-font" style="font-style: normal; font-weight: 700; font-size: 10px; text-transform: none;">បញ្ជាក់ពីមូលហេតុដែលមិនត្រូវបានជួសជុល</span>
                        <span style="color: #9ca3af;">/</span>
                        if not fixed, mention why:
                    </div>
                    <div style="color: #1e40af; font-style: italic; font-weight: 600; font-size: 11px;">${data['reasonIfNotFixed'] ?? ''}</div>
                </div>
            </div>
        </div>

        <!-- Recommendation Section -->
        <div style="border-left: 1px solid #000; border-right: 1px solid #000;">
            <div style="padding: 6px 12px; font-weight: 900; font-size: 9px; background: #f9fafb; text-transform: uppercase; letter-spacing: 0.1em; border-bottom: 1px solid #000; color: #9ca3af; font-style: italic;">
                Technician Recommendation:
            </div>
            <div style="padding: 8px; min-height: 40px; border-bottom: 1px solid #000; background: #fff; color: #1e40af; font-style: italic; font-weight: 600; display: flex; align-items: center; font-size: 11px;">
                ${data['recommendation'] ?? ''}
            </div>
        </div>

        <!-- Picture Report Section -->
        <div style="border-left: 1px solid #000; border-right: 1px solid #000;">
            <div style="background: #BCE6B4; padding: 6px 12px; font-weight: 700; display: flex; align-items: center; gap: 8px; border-bottom: 1px solid #000; font-size: 10px;">
                <span class="khmer-font" style="font-size: 11px; font-weight: 500; line-height: 1;">រូបភាពរបាយការណ៍</span>
                <span style="color: rgba(0,0,0,0.3); font-weight: 400;">/</span>
                <span style="text-transform: uppercase; letter-spacing: 0.05em; color: #000;">Picture Report</span>
            </div>
            <div style="display: flex; height: 140px; background: #f9fafb; border-bottom: 1px solid #000;">
                $imagesHtml
            </div>
        </div>

        <!-- Personnel & Signature Section -->
        <div style="border-left: 1px solid #000; border-right: 1px solid #000;">
            <!-- Header Row -->
            <div style="display: flex; background: #BCE6B4; border-bottom: 1px solid #000; height: 36px; position: relative; z-index: 10;">
                <div style="flex: 6; border-right: 1px solid #000; padding: 0 12px; display: flex; align-items: center; font-weight: 900; font-size: 9px; text-transform: uppercase; letter-spacing: -0.05em;">
                    <span class="khmer-font" style="margin-right: 8px; font-size: 11px; font-weight: 700; text-transform: none;">ជាងបច្ចេកទេស</span>
                    <span style="color: #9ca3af; margin-right: 8px;">/</span>
                    List of Technician
                </div>
                <div style="flex: 6; padding: 0 12px; display: flex; align-items: center; justify-content: center; font-weight: 900; font-size: 9px; text-transform: uppercase; letter-spacing: -0.05em; text-align: center;">
                    Customer: Name, Position, Date, Signature & Comments
                </div>
            </div>

            <!-- Content Row -->
            <div style="display: flex; border-bottom: 1px solid #000; min-height: 160px;">
                <!-- Technician Table -->
                <div style="flex: 6; border-right: 1px solid #000; display: flex; flex-direction: column; background: #fff;">
                    <table style="width: 100%; border-collapse: collapse; height: 100%;">
                        <tbody>
                            <tr>
                                <td style="padding: 8px 12px; border-right: 1px solid #000; font-weight: 900; font-size: 9px; width: 33%; background: rgba(249,250,251,0.3); text-transform: uppercase; letter-spacing: -0.05em; border-bottom: 1px solid #000;">
                                    <span class="khmer-font" style="text-transform: none; font-weight: 700; font-size: 10px; display: block;">ឈ្មោះ</span> Names
                                </td>
                                <td style="padding: 8px 12px; color: #1e40af; font-weight: 900; font-style: italic; font-size: 11px; border-bottom: 1px solid #000;">${data['technician'] ?? ''}</td>
                            </tr>
                            <tr>
                                <td style="padding: 8px 12px; border-right: 1px solid #000; font-weight: 900; font-size: 9px; background: rgba(249,250,251,0.3); text-transform: uppercase; letter-spacing: -0.05em; border-bottom: 1px solid #000;">Date & Time Arrived</td>
                                <td style="padding: 8px 12px; display: flex; justify-content: space-between; align-items: center; color: #1e40af; font-weight: 900; font-style: italic; font-size: 11px; border-bottom: 1px solid #000;">
                                    <span>${data['dateArrived'] ?? ''}</span>
                                    <span>${data['timeArrived'] ?? ''}</span>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 8px 12px; border-right: 1px solid #000; font-weight: 900; font-size: 9px; background: rgba(249,250,251,0.3); text-transform: uppercase; letter-spacing: -0.05em; border-bottom: 1px solid #000;">Date & Time Completed</td>
                                <td style="padding: 8px 12px; display: flex; justify-content: space-between; align-items: center; color: #1e40af; font-weight: 900; font-style: italic; font-size: 11px; border-bottom: 1px solid #000;">
                                    <span>${data['dateCompleted'] ?? ''}</span>
                                    <span>${data['timeCompleted'] ?? ''}</span>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 12px; border-right: 1px solid #000; font-weight: 900; font-size: 9px; background: rgba(249,250,251,0.3); text-transform: uppercase; letter-spacing: -0.05em;">Total Hour</td>
                                <td style="padding: 12px; color: #1e40af; font-weight: 900; font-style: italic; font-size: 11px;">${data['totalHours'] ?? ''}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Signature Area -->
                <div style="flex: 6; background: #fff; display: flex; flex-direction: column; padding: 16px; position: relative; cursor: crosshair;">
                    $signatureHtml
                </div>
            </div>
        </div>

        <!-- Final Meta Footer Row -->
        <div style="border-left: 1px solid #000; border-right: 1px solid #000;">
            <div style="display: flex; font-size: 9px; font-weight: 900; height: 36px; background: #f9fafb; border-bottom: 1px solid #000; text-transform: uppercase; letter-spacing: -0.05em; align-items: center;">
                <div style="flex: 4; padding: 0 16px; border-right: 1px solid #000; height: 100%; display: flex; align-items: center;">CK USE: ........................</div>
                <div style="flex: 4; height: 100%; display: flex; align-items: center; justify-content: center; border-right: 1px solid #000;">CHECK BY: ........................</div>
                <div style="flex: 4; height: 100%; display: flex; align-items: center; justify-content: flex-end; padding: 0 16px;">CHECKED ON: ........................</div>
            </div>
        </div>

        <!-- Document Tracking Metadata -->
        <div style="margin-top: 16px; display: flex;">
            <div style="flex: 1; font-size: 9px; font-weight: 700; color: #6b7280; line-height: 1.5; letter-spacing: 0.05em;">
                <div>FORM NO: CK-SDD-F-0042</div>
                <div>REVISION: 2</div>
                <div>DATED: 12-AUG-2025</div>
            </div>
            <div style="flex: 1; text-align: right; display: flex; flex-direction: column; justify-content: flex-end;">
                <div style="font-size: 8px; font-weight: 900; color: #10b981; text-transform: uppercase; letter-spacing: 0.1em; font-style: italic; opacity: 0.5;">Precision Digital Twin</div>
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
}
