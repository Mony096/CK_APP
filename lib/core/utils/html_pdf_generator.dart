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
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:flutter_native_html_to_pdf/pdf_page_size.dart';

class HtmlServiceReportGenerator {
  /// Generate service report PDF using HTML rendering (better Khmer font support)
  static Future<File> generateServiceReport(Map<String, dynamic> data) async {
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

    // Build comprehensive report data map
    final Map<String, dynamic> reportData = {
      ...data,
      'reportNo': ticketNum,
      'reportDate': dateStr,
      'wod': data['U_CK_WOD']?.toString() ?? '',
      'contract': data['U_CK_Contract']?.toString() ?? 'Yes',
      'customer': data['CustomerName']?.toString() ?? '',
      'ckNo': data['U_CK_CKNo']?.toString() ?? '',
      'brand': data['U_CK_Brand']?.toString() ?? '',
      'equipmentType': data['U_CK_JobType']?.toString() ?? '',
      'equipmentId': data['U_CK_EquipmentID']?.toString() ?? '',
      'lastPM': data['U_CK_LastPM'],
      'location': data['U_CK_Location']?.toString() ?? '',
      'serviceType': data['U_CK_ServiceType']?.toString() ?? '',
      'hourMeter': data['U_CK_HourMeter']?.toString() ?? 'N/A',
      'customerRequest': data['U_CK_CustomerRequest']?.toString() ??
          data['U_CK_JobType']?.toString() ??
          '',
      'diagnosis': data['U_CK_Diagnosis']?.toString() ?? '',
      'measurements': data['U_CK_Measurements']?.toString() ?? '',
      'recommendation': data['U_CK_Recommendation']?.toString() ?? '',
      'problemFixed': data['U_CK_ProblemFixed']?.toString() ?? 'Yes',
      'attachedReport': data['U_CK_AttachedReport']?.toString() ?? 'No',
      'nop': data['U_CK_NOP']?.toString() ?? '',
      'reasonIfNotFixed': data['U_CK_ReasonIfNotFixed']?.toString() ?? '',
      'technician': data['U_CK_Technician']?.toString() ?? '',
      'dateArrived': dateArrived,
      'timeArrived': timeArrived,
      'dateCompleted': dateCompleted,
      'timeCompleted': timeCompleted,
      'totalHours': totalHours,
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

    final Map<String, dynamic> reportData = {
      ...data,
      'reportNo': ticketNum,
      'reportDate': dateStr,
      'wod': data['U_CK_WOD']?.toString() ?? '',
      'contract': data['U_CK_Contract']?.toString() ?? 'Yes',
      'customer': data['CustomerName']?.toString() ?? '',
      'ckNo': data['U_CK_CKNo']?.toString() ?? '',
      'brand': data['U_CK_Brand']?.toString() ?? '',
      'equipmentType': data['U_CK_JobType']?.toString() ?? '',
      'equipmentId': data['U_CK_EquipmentID']?.toString() ?? '',
      'lastPM': data['U_CK_LastPM'],
      'location': data['U_CK_Location']?.toString() ?? '',
      'serviceType': data['U_CK_ServiceType']?.toString() ?? '',
      'hourMeter': data['U_CK_HourMeter']?.toString() ?? 'N/A',
      'customerRequest': data['U_CK_CustomerRequest']?.toString() ??
          data['U_CK_JobType']?.toString() ??
          '',
      'diagnosis': data['U_CK_Diagnosis']?.toString() ?? '',
      'measurements': data['U_CK_Measurements']?.toString() ?? '',
      'recommendation': data['U_CK_Recommendation']?.toString() ?? '',
      'problemFixed': data['U_CK_ProblemFixed']?.toString() ?? 'Yes',
      'attachedReport': data['U_CK_AttachedReport']?.toString() ?? 'No',
      'nop': data['U_CK_NOP']?.toString() ?? '',
      'reasonIfNotFixed': data['U_CK_ReasonIfNotFixed']?.toString() ?? '',
      'technician': data['U_CK_Technician']?.toString() ?? '',
      'dateArrived': dateArrived,
      'timeArrived': timeArrived,
      'dateCompleted': dateCompleted,
      'timeCompleted': timeCompleted,
      'totalHours': totalHours,
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

  /// Generate HTML content matching App.tsx exactly
  static String _generateHtml(Map<String, dynamic> data, String? logoBase64) {
    // Extract parts/materials
    final parts = data['CK_JOB_MATERIALCollection'] as List? ?? [];

    // Extract files/attachments
    final List<dynamic> files = data['files'] as List? ?? [];

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
          <div style="font-size:7.2px;">REQUIRED SIGNATURE</div>
        </div>
      ''';
    }

    // Build parts HTML
    String partsHtml = '';
    for (var p in parts) {
      partsHtml +=
          '<div style="color:#1e3a8a;font-style:italic;font-weight:700;font-size:7.2px;padding:1px 0;">• ${p['U_CK_ItemName'] ?? ''} (Qty: ${p['U_CK_Qty'] ?? ''})</div>';
    }
    if (partsHtml.isEmpty) {
      partsHtml =
          '<div style="color:#9ca3af;font-size:7.2px;font-style:italic;">...</div>';
    }

    // Build images HTML
    String imagesHtml = '';
    for (int i = 0; i < 4; i++) {
      final borderRight = i == 3 ? 'none' : '1px solid #000';
      if (i < images.length) {
        final img = images[i];
        final imageData = 'data:image/png;base64,${img['data']}';
        final description = img['U_CK_Description']?.toString() ?? 'Image';
        imagesHtml += '''
          <div style="border-right:$borderRight;flex:1;display:flex;flex-direction:column;overflow:hidden;">
            <div style="flex:1;display:flex;align-items:center;justify-content:center;background:#fff;padding:2px;">
              <img src="$imageData" style="width:100%;height:100px;object-fit:cover;" />
            </div>
            <div style="padding:4px;font-size:7.2px;font-style:italic;color:#1e3a8a;font-weight:400;text-align:left;">$description</div>
          </div>
        ''';
      } else {
        imagesHtml += '''
          <div style="border-right:$borderRight;flex:1;display:flex;flex-direction:column;overflow:hidden;background:#fff;">
            <div style="flex:1;display:flex;align-items:center;justify-content:center;">
              <div style="color:#e5e7eb;font-size:24px;">📷</div>
            </div>
            <div style="padding:4px;font-size:7.2px;font-style:italic;color:#e5e7eb;text-align:left;">NO PHOTO</div>
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
          <div style="font-size:7.2px;">REQUIRED SIGNATURE</div>
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
            margin: 0; 
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
            width: 210mm;
            height: 285mm; /* Safety buffer: intentionally shorter than 297mm */
            overflow: hidden; /* Hard clip */
        }
        body {
            font-family: 'Inter', sans-serif;
            font-size: 7.2px;
            color: #000;
            line-height: 1.15;
            background: #fff;
        }
        .page-wrapper {
            width: 210mm;
            height: 285mm; /* Match body height */
            padding: 4mm 6mm; /* slightly less top/bottom padding */
            display: flex;
            flex-direction: column;
            overflow: hidden;
            position: relative;
        }
        .khmer { font-family: 'Siemreap', cursive; font-size: 7.2px; }
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
        .min-h-1 { min-height: 18px; }
        .min-h-2 { min-height: 32px; }
        .min-h-diag { min-height: 40px; }
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
                <div class="bold" style="font-size: 8px; margin-top: 1px;">
                    <span class="khmer">របាយការណ៍សេវាកម្ម</span>/Service Report
                </div>
            </div>
            <div style="grid-column: span 4; display: flex; flex-direction: column; justify-content: flex-end; align-items: center;">
                 <div class="bold" style="font-size: 7px;">No: ${data['reportNo'] ?? 'N/A'}</div>
            </div>
            <div style="grid-column: span 4; text-align: right; font-size: 5px;">
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
                    <div>WOD:</div>
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
                    <div class="span-3 p-1 min-h-1 text-blue italic bold">${data['equipmentId'] ?? ''}</div>
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
            <div class="p-1 min-h-diag border-b text-blue italic bold" style="white-space: pre-wrap; font-size: 7.2px;">${data['diagnosis'] ?? ''}</div>

            <div class="grid grid-12 border-b">
                <div class="span-6 border-r flex flex-col">
                    <div class="bg-green p-1 bold border-b">
                        <span class="khmer">គ្រឿងបន្លាស់</span>/Part Supply
                    </div>
                    <div class="p-1" style="flex-grow: 1; min-height: 100px;">
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
                    <div class="khmer" style="font-size: 5.5px;">បញ្ជាក់ពីមូលហេតុដែលមិនត្រូវបានជួសជុល និងដំណោះស្រាយ if not, mention why:</div>
                    <div class="text-blue" style="margin-top: 2px;">${data['reasonIfNotFixed'] ?? ''}</div>
                </div>
            </div>

            <div class="p-1 border-b italic bold" style="min-height: 40px;">
                Technician Recommendation: <span class="text-blue">${data['recommendation'] ?? ''}</span>
            </div>

            <div class="bg-green p-1 bold border-b">
                <span class="khmer">រូបភាពរបាយការណ៍</span>/ Picture Report
            </div>
            <div class="p-1 border-b" style="height: 120px; overflow: hidden; display: flex;">
                $imagesHtml
            </div>

            <div class="grid grid-12 border-b bg-green bold">
                <div class="span-6 border-r p-1"><span class="khmer">ជាងបច្ចេកទេស</span>/List of Technician</div>
                <div class="span-6 p-1 text-center">Customer: Name, Position, Date, Signature & Comments</div>
            </div>

            <div class="grid grid-12">
                <div class="span-6 border-r flex flex-col">
                    <div class="flex border-b">
                        <div style="width: 30%;" class="p-1 border-r bold"><span class="khmer">ឈ្មោះ</span> Names</div>
                        <div style="flex-grow: 1;" class="p-1 text-blue italic bold">${data['technician'] ?? ''}</div>
                    </div>
                    <div class="flex border-b">
                        <div style="width: 30%;" class="p-1 border-r bold">Date & Time Arrived</div>
                        <div style="flex-grow: 1;" class="p-1 text-blue italic bold flex justify-between">
                            <span>${_formatDate(data['reportDate'])}</span>
                            <span>${data['timeArrived'] ?? ''}</span>
                        </div>
                    </div>
                    <div class="flex border-b">
                        <div style="width: 30%;" class="p-1 border-r bold">Date & Time Completed</div>
                        <div style="flex-grow: 1;" class="p-1 text-blue italic bold flex justify-between">
                            <span>${_formatDate(data['reportDate'])}</span>
                            <span>${data['timeCompleted'] ?? ''}</span>
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

            <div class="grid grid-12" style="height: 14px; border-top: 1px solid #000;">
                <div class="span-4 p-1 flex items-center justify-center">CK use:</div>
                <div class="span-4 p-1 flex items-center justify-center italic">Check by:</div>
                <div class="span-4 p-1 flex items-center justify-center">Checked on:</div>
            </div>
        </div>

        <!-- Footer Metadata -->
        <div class="flex justify-between items-end" style="margin-top: 4px;">
            <div style="font-size: 6px; color: #000; font-weight: 500;">
                <div>Form Number: CK-SDD-F-0042</div>
                <div>Revision: 2</div>
                <div>Date: ${DateFormat('dd-MMM-yyyy').format(DateTime.now())}</div>
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
