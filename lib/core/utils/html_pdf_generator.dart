// File location: lib/core/utils/html_pdf_generator.dart
// This file generates PDFs by first creating HTML, then converting to PDF
// WHY: Flutter's PDF library has poor Khmer font support. HTML rendering provides better font rendering.
// RELEVANT FILES: pdf_report_generator.dart, service_detail_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:flutter_native_html_to_pdf/pdf_page_size.dart';

class HtmlServiceReportGenerator {
  /// Generate service report PDF using HTML rendering (better Khmer font support)
  /// 
  /// API Response Field Mapping (Flutter → PDF):
  /// - DocNum → reportNo
  /// - U_CK_Date → date
  /// - U_CK_WOD → wod
  /// - U_CK_Contract → contract
  /// - CustomerName → customer
  /// - U_CK_CKNo → ckNo
  /// - U_CK_Brand → brand
  /// - U_CK_JobType → equipmentType
  /// - U_CK_EquipmentID → equipmentId
  /// - U_CK_LastPM → lastPM
  /// - U_CK_Location → location
  /// - U_CK_ServiceType → serviceType
  /// - U_CK_HourMeter → hourMeter
  /// - U_CK_CustomerRequest → customerRequest
  /// - U_CK_Diagnosis → diagnosis
  /// - CK_JOB_MATERIALCollection → parts (U_CK_ItemName, U_CK_Qty)
  /// - U_CK_Measurements → measurements
  /// - U_CK_ProblemFixed → problemFixed
  /// - U_CK_AttachedReport → attachedReport
  /// - U_CK_NOP → nop
  /// - U_CK_Recommendation → recommendation
  /// - files → pictures & signature
  /// - U_CK_Technician → technician
  /// - CK_JOB_TIMECollection → time entries
  /// - U_CK_Effort → totalHours
  /// - U_CK_ReasonIfNotFixed → reasonIfNotFixed
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
    final List<dynamic> timeEntries = data['CK_JOB_TIMECollection'] as List? ?? [];
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
          timeArrived = entry['U_CK_EndTime']?.toString() ?? entry['U_CK_StartTime']?.toString() ?? '';
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
      'customerRequest': data['U_CK_CustomerRequest']?.toString() ?? data['U_CK_JobType']?.toString() ?? '',
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
    debugPrint('  dateArrived: ${reportData['dateArrived']} ${reportData['timeArrived']}');
    debugPrint('  dateCompleted: ${reportData['dateCompleted']} ${reportData['timeCompleted']}');

    // Generate HTML content
    final htmlContent = _generateHtml(reportData);

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

  /// Generate HTML content for the service report
  static String _generateHtml(Map<String, dynamic> data) {
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
    // Strategy: Collect all image files first, then identify signature by multiple methods
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

    // First pass: look for explicit PNG/JPG signatures (prioritize these)
    for (var f in allImageFiles) {
      final desc = f['U_CK_Description']?.toString().toLowerCase() ?? '';
      final ext = f['ext']?.toString().toLowerCase() ?? '';

      final isPngJpgSignature = (ext == 'png' || ext == 'jpg' || ext == 'jpeg') &&
                               (desc.contains('signature') ||
                                desc.contains('sign') ||
                                desc.contains('ហត្ថលេខា') ||
                                desc.contains('ហត្ថ'));

      if (isPngJpgSignature) {
        signatureFile = Map<String, dynamic>.from(f);
        debugPrint('  → Found PNG/JPG signature by description: ext=$ext, desc="$desc"');
        break; // Use the first PNG/JPG signature found
      }
    }

    // Second pass: if no PNG/JPG signature found, look for PDF signatures or any signature
    if (signatureFile == null) {
      for (var f in allImageFiles) {
        final desc = f['U_CK_Description']?.toString().toLowerCase() ?? '';
        final ext = f['ext']?.toString().toLowerCase() ?? '';

        final isAnySignature = desc.contains('signature') ||
                              desc.contains('sign') ||
                              desc.contains('ហត្ថលេខា') ||
                              desc.contains('ហត្ថ') ||
                              ext == 'pdf'; // PDF signatures as fallback

        if (isAnySignature) {
          signatureFile = Map<String, dynamic>.from(f);
          debugPrint('  → Found signature (PDF or other): ext=$ext, desc="$desc"');
          break;
        }
      }
    }

    // Remove signature from regular images list
    if (signatureFile != null) {
      regularImages.removeWhere((f) => f == signatureFile);
    } else {
      regularImages.addAll(allImageFiles); // If no signature found, all files are regular images
    }

    // Method 2: If no signature found by description, use the last PNG/JPG as signature
    // This is the most reliable method since signatures are typically added last
    if (signatureFile == null && regularImages.isNotEmpty) {
      // Find PNG/JPG files (exclude PDFs for signature)
      final pngJpgFiles = regularImages.where((f) {
        final ext = f['ext']?.toString().toLowerCase() ?? '';
        return ext == 'png' || ext == 'jpg' || ext == 'jpeg';
      }).toList();

      if (pngJpgFiles.isNotEmpty) {
        signatureFile = Map<String, dynamic>.from(pngJpgFiles.last);
        regularImages.remove(signatureFile);
        debugPrint('  → Using last PNG/JPG as signature (most reliable method)');
      }
    }
    
    // Use remaining images for picture report (max 4)
    final images = regularImages.take(4).toList();
    debugPrint('📸 Report images: ${images.length}, Signature found: ${signatureFile != null}');
    if (signatureFile != null) {
      debugPrint('  Signature details: ext=${signatureFile['ext']}, desc="${signatureFile['U_CK_Description']}"');
      debugPrint('  💡 Note: PNG signatures can be embedded directly. PDF signatures show as placeholder.');
    } else {
      debugPrint('  💡 No signature found. For new signatures, ensure they are saved as PNG format.');
    }

    // Build signature image data URL
    // PNG/JPG signatures can be embedded directly in HTML img tags
    String? signatureImage;
    if (signatureFile != null) {
      final ext = signatureFile['ext']?.toString().toLowerCase() ?? '';
      if (ext == 'png' || ext == 'jpg' || ext == 'jpeg') {
        signatureImage = 'data:image/${ext == 'jpg' ? 'jpeg' : ext};base64,${signatureFile['data']}';
        debugPrint('✅ Signature PNG/JPG image ready for display');
      } else if (ext == 'pdf') {
        // PDF signature - we can't embed directly, show placeholder
        debugPrint('⚠️ Signature is PDF format - cannot embed in HTML image tag');
        // Option: Could convert PDF to image, but that's complex
        // For now, we'll show a text indicator
      }
    }

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Report - ${data['reportNo']}</title>
    <link href="https://fonts.googleapis.com/css2?family=Siemreap&family=Inter:wght@400;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        @page {
            size: A4;
            margin: 10mm;
        }
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Inter', sans-serif;
            font-size: 11px;
            color: #000;
            line-height: 1.4;
        }
        .khmer {
            font-family: 'Siemreap', cursive;
        }
        .container {
            width: 100%;
            max-width: 100%;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 10px;
        }
        .header-left {
            flex: 1;
        }
        .logo-section {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 5px;
        }
        .logo {
            width: 40px;
            height: 40px;
            border: 3px solid #000;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .company-name {
            font-size: 22px;
            font-weight: 900;
            letter-spacing: -0.5px;
        }
        .report-title {
            font-size: 14px;
            font-weight: bold;
            margin-top: 5px;
        }
        .header-right {
            text-align: right;
            font-size: 8px;
        }
        .hotline {
            font-weight: bold;
            font-size: 8px;
            margin-bottom: 2px;
        }
        .hotline-line {
            font-size: 7px;
            line-height: 1.3;
        }
        .report-number {
            text-align: center;
            font-size: 10px;
            font-weight: bold;
            margin-top: 5px;
        }
        .info-grid {
            border: 0.5px solid #000;
            border-right: none;
            border-bottom: none;
        }
        .info-row {
            display: flex;
            border-bottom: 0.5px solid #000;
        }
        .info-cell {
            border-right: 0.5px solid #000;
            padding: 3px;
            min-height: 30px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .cell-label {
            font-size: 7px;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 3px;
        }
        .cell-value {
            font-size: 8px;
            color: #1e40af;
            font-style: italic;
            margin-top: 2px;
        }
        .section {
            border-left: 0.5px solid #000;
            border-right: 0.5px solid #000;
            border-bottom: 0.5px solid #000;
        }
        .section-header {
            background-color: #BCE6B4;
            padding: 3px 5px;
            font-weight: bold;
            font-size: 8px;
            border-bottom: 0.5px solid #000;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .section-content {
            padding: 5px;
            min-height: 30px;
            font-size: 9px;
            color: #1e40af;
            font-style: italic;
        }
        .two-column {
            display: flex;
        }
        .column {
            flex: 1;
            border-right: 0.5px solid #000;
        }
        .column:last-child {
            border-right: none;
        }
        .parts-list {
            padding: 4px;
            min-height: 60px;
            font-size: 7px;
        }
        .part-item {
            margin-bottom: 2px;
        }
        .picture-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 5px;
            padding: 5px;
        }
        .picture-item {
            display: flex;
            flex-direction: column;
        }
        .picture-image {
            width: 100%;
            height: 100px;
            object-fit: cover;
            border: 0.5px solid #d1d5db;
        }
        .picture-label {
            padding: 3px;
            font-size: 7px;
            text-align: center;
            color: #1e40af;
            font-style: italic;
            font-weight: bold;
        }
        .technician-table {
            width: 100%;
            border-collapse: collapse;
        }
        .technician-table td {
            padding: 3px;
            border-bottom: 0.5px solid #000;
        }
        .technician-label {
            border-right: 0.5px solid #000;
            width: 30%;
            font-size: 7px;
            font-weight: bold;
            background-color: #f9fafb;
        }
        .technician-value {
            font-size: 8px;
            color: #1e40af;
            font-style: italic;
        }
        .signature-area {
            height: 80px;
            padding: 5px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .signature-image {
            max-height: 50px;
            max-width: 100%;
        }
        .footer {
            margin-top: 20px;
            display: flex;
            justify-content: space-between;
            font-size: 8px;
        }
        .footer-meta {
            font-size: 8px;
        }
        .footer-signatures {
            display: flex;
            gap: 10px;
            font-size: 7px;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <div class="header-left">
                <div class="logo-section">
                    <div class="logo">
                        <div style="width: 30px; height: 30px; border: 2px solid #10b981; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                            <div style="width: 6px; height: 6px; background: #10b981; border-radius: 50%;"></div>
                        </div>
                    </div>
                    <div class="company-name">CominKhmere</div>
                </div>
                <div class="report-title">
                    <span class="khmer">របាយការណ៍សេវាកម្ម</span> / Service Report
                </div>
            </div>
            <div class="header-right">
                <div class="hotline">Hotline:</div>
                <div class="hotline-line">PP: 012 816 800/SHV: 092 777 224</div>
                <div class="hotline-line">SR: 012 222 723/PPIA: 092 777 143</div>
                <div class="hotline-line">SVIA: 092 666 791</div>
            </div>
        </div>
        <div class="report-number">No: ${data['reportNo']}</div>

        <!-- Info Grid -->
        <div class="info-grid">
            <div class="info-row">
                <div class="info-cell" style="flex: 3;">
                    <div class="cell-label"><span class="khmer">កាលបរិច្ឆេទ</span> / Date</div>
                    <div class="cell-value">${data['reportDate'] ?? 'N/A'}</div>
                </div>
                <div class="info-cell" style="flex: 3;">
                    <div class="cell-label">WOD</div>
                    <div class="cell-value">${data['wod'] ?? ''}</div>
                </div>
                <div class="info-cell" style="flex: 2;">
                    <div class="cell-label">Contract</div>
                    <div class="cell-value">${data['contract'] ?? 'Yes'}</div>
                </div>
            </div>
            <div class="info-row">
                <div class="info-cell" style="flex: 5;">
                    <div class="cell-label"><span class="khmer">ឈ្មោះអតិថិជន</span> / Customer particular</div>
                    <div class="cell-value">${data['customer'] ?? ''}</div>
                </div>
                <div class="info-cell" style="flex: 5;">
                    <div class="cell-label"><span class="khmer">លេខសម្គាល់</span> / CK no</div>
                    <div class="cell-value">${data['ckNo'] ?? ''}</div>
                </div>
            </div>
            <div class="info-row">
                <div class="info-cell" style="flex: 5;"></div>
                <div class="info-cell" style="flex: 5;">
                    <div class="cell-label"><span class="khmer">ម៉ាក</span> / Brand</div>
                    <div class="cell-value">${data['brand'] ?? ''}</div>
                </div>
            </div>
            <div class="info-row">
                <div class="info-cell" style="flex: 5;">
                    <div class="cell-label"><span class="khmer">ប្រភេទបរិក្ខា</span> / Type of Equipment</div>
                    <div class="cell-value">${data['equipmentType'] ?? ''}</div>
                </div>
                <div class="info-cell" style="flex: 5;">
                    <div class="cell-label"><span class="khmer">បរិក្ខា</span> / Equipment</div>
                    <div class="cell-value">${data['equipmentId'] ?? ''}</div>
                </div>
            </div>
            <div class="info-row">
                <div class="info-cell" style="flex: 5;">
                    <div class="cell-label"><span class="khmer">ថ្ងៃតំហែទាំចុងក្រោយ</span> / last PM</div>
                    <div class="cell-value">${_formatDate(data['lastPM'])}</div>
                </div>
                <div class="info-cell" style="flex: 5;">
                    <div class="cell-label"><span class="khmer">ទីតាំង</span> / Location</div>
                    <div class="cell-value">${data['location'] ?? ''}</div>
                </div>
            </div>
            <div class="info-row">
                <div class="info-cell" style="flex: 5;">
                    <div class="cell-label"><span class="khmer">ប្រភេទសេវាកម្ម</span> / Service type</div>
                    <div class="cell-value">${data['serviceType'] ?? ''}</div>
                </div>
                <div class="info-cell" style="flex: 5;">
                    <div class="cell-label"><span class="khmer">កុងទ័រម៉ោង</span> / Hour Meter</div>
                    <div class="cell-value">${data['hourMeter'] ?? 'N/A'}</div>
                </div>
            </div>
        </div>

        <!-- Customer Request -->
        <div class="section">
            <div class="section-header">
                <span class="khmer">ការស្នើសុំ ស្ទើពីអតិថិជន</span> / Customer Request
            </div>
            <div class="section-content" style="min-height: 30px;">
                ${data['customerRequest'] ?? data['equipmentType'] ?? ''}
            </div>
        </div>

        <!-- Diagnosis -->
        <div class="section">
            <div class="section-header">
                <span class="khmer">ការពិនិត្យកំហូច មូលហេតុនៃកំហូច សេវាកម្មដែលបានផ្តល់</span> / Diagnosis Defect Found Service Rendered
            </div>
            <div class="section-content" style="min-height: 120px; white-space: pre-wrap;">
                ${data['diagnosis'] ?? ''}
            </div>
        </div>

        <!-- Parts & Measurements -->
        <div class="section">
            <div class="two-column">
                <div class="column">
                    <div class="section-header">
                        <span class="khmer">គ្រឿងបន្លាស់</span> / Part Supply
                    </div>
                    <div class="parts-list">
                        ${parts.map((p) => '- ${p['U_CK_ItemName'] ?? ''} (Qty: ${p['U_CK_Qty'] ?? ''})').join('<br>')}
                        ${parts.isEmpty ? '' : '<div style="border-top: 0.5px solid #000; margin-top: 5px; padding-top: 3px; text-align: center; font-size: 7px; font-weight: bold;"><span class="khmer">របាយការណ៍ភ្ជាប់</span> / Attached report: <span style="color: #1e40af; font-style: italic;">${data['attachedReport'] ?? 'No'}</span></div>'}
                        <div style="border-top: 0.5px solid #000; margin-top: 3px; padding-top: 3px; text-align: center; font-size: 7px; font-weight: bold;"><span class="khmer">ចំនួនទំព័រ</span> / NOP: <span style="color: #1e40af; font-style: italic;">${data['nop'] ?? ''}</span></div>
                    </div>
                </div>
                <div class="column">
                    <div class="section-header">
                        <span class="khmer">លទ្ធផលការវាស់ស្ទង់</span> / Measurements & Test Conducted (Tool serial.........)
                    </div>
                    <div class="section-content" style="min-height: 60px;">
                        ${data['measurements'] ?? ''}
                    </div>
                    <div style="border-top: 0.5px solid #000; padding: 3px; text-align: right; font-size: 7px; font-weight: bold;">
                        <span class="khmer">កំហូចត្រូវបានជួសជុល</span> / Problem fixed upon departure: <span style="color: #1e40af; font-style: italic;">${data['problemFixed'] ?? 'Yes'}</span>
                    </div>
                    <div style="border-top: 0.5px solid #000; padding: 3px; font-size: 7px; font-weight: bold;">
                        <span class="khmer">បញ្ជាក់ពីមូលហេតុដែលមិនត្រូវបានជួសជុលនិងដំណោះស្រាយ</span> if not, mention why: <span style="color: #1e40af; font-style: italic;">${data['reasonIfNotFixed'] ?? ''}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recommendation -->
        <div class="section">
            <div style="padding: 3px 5px; font-weight: bold; font-size: 9px; background-color: #f9fafb; border-bottom: 0.5px solid #000;">
                Technician Recommendation:
            </div>
            <div class="section-content" style="min-height: 40px;">
                ${data['recommendation'] ?? ''}
            </div>
        </div>

        <!-- Picture Report -->
        ${images.isNotEmpty ? '''
        <div class="section">
            <div class="section-header">
                <span class="khmer">រូបភាពរបាយការណ៍</span> / Picture Report
            </div>
            <div class="picture-grid">
                ${images.take(4).map((img) {
                  try {
                    final imageData = 'data:image/png;base64,${img['data']}';
                    final description = img['U_CK_Description']?.toString() ?? 'Image';
                    return '''
                    <div class="picture-item">
                        <img src="$imageData" class="picture-image" />
                        <div class="picture-label">$description</div>
                    </div>
                    ''';
                  } catch (e) {
                    return '';
                  }
                }).join('')}
            </div>
        </div>
        ''' : ''}

        <!-- Technician & Signature -->
        <div class="section" style="border-top: 0.5px solid #000;">
            <div class="two-column">
                <div class="column">
                    <div class="section-header">
                        <span class="khmer">ជាងបច្ចេកទេស</span> / List of Technician
                    </div>
                    <table class="technician-table">
                        <tr>
                            <td class="technician-label"><span class="khmer">ឈ្មោះ</span> Names</td>
                            <td class="technician-value">${data['technician'] ?? ''}</td>
                        </tr>
                        <tr>
                            <td class="technician-label">Date & Time Arrived</td>
                            <td class="technician-value">${data['dateArrived'] ?? ''} ${data['timeArrived'] ?? ''}</td>
                        </tr>
                        <tr>
                            <td class="technician-label">Date & Time Completed</td>
                            <td class="technician-value">${data['dateCompleted'] ?? ''} ${data['timeCompleted'] ?? ''}</td>
                        </tr>
                        <tr>
                            <td class="technician-label">Total Hour</td>
                            <td class="technician-value">${data['totalHours'] ?? ''}</td>
                        </tr>
                    </table>
                </div>
                <div class="column">
                    <div class="section-header">
                        <span class="khmer">អតិថិជន: ឈ្មោះ, តួនាទី, កាលបរិច្ឆេទ, ហត្ថលេខា និង មតិយោបល់</span> / Customer: Name, Position, Date, Signature & Comments
                    </div>
                    <div class="signature-area">
                        ${signatureImage != null
                          ? '<img src="$signatureImage" class="signature-image" />'
                          : signatureFile != null
                            ? '<div style="text-align: center; color: #6b7280; font-size: 8px;"><div style="font-size: 20px;">📝</div><div>Digital Signature</div><div style="font-size: 6px; margin-top: 2px; color: #9ca3af;">${signatureFile['ext']?.toString().toUpperCase() ?? 'FILE'}</div></div>'
                            : '<div style="text-align: center; color: #d1d5db; font-size: 8px;">No signature</div>'}
                    </div>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="footer">
            <div class="footer-meta">
                <div>Form Number: CK-SDD-F-0042</div>
                <div>Revision: 2</div>
                <div>Date: 12-Aug-2025</div>
            </div>
            <div class="footer-signatures">
                <div>CK use: ________</div>
                <div>Check by: ________</div>
                <div>Checked on: ________</div>
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
