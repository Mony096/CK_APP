import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ServiceReportGenerator {
  static const PdfColor primaryGreen = PdfColor.fromInt(0xffBCE6B4);
  static const double borderWidth = 1.0; // Increased for crisper lines

  /// Unicode-supporting font for PDF text rendering
  static pw.Font? _pdfFont;

  /// Initialize the PDF font with Unicode support
  /// Tries multiple Khmer fonts in order of compatibility, then falls back to system fonts
  static Future<pw.Font> _getPdfFont() async {
    if (_pdfFont != null) return _pdfFont!;
    
    // Priority 1: Try Noto Sans Khmer (most compatible with PDF libraries)
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoSansKhmer-Regular.ttf');
      _pdfFont = pw.Font.ttf(fontData);
      debugPrint('✅ Successfully loaded Noto Sans Khmer font for PDF generation');
      return _pdfFont!;
    } catch (e) {
      debugPrint('⚠️ Could not load Noto Sans Khmer font: $e');
    }
    
    // Priority 2: Try Khmer OS Siemreap font (user's preferred font)
    try {
      final fontData = await rootBundle.load('assets/fonts/Khmer OS Siemreap Regular.ttf');
      // Verify it's a valid TTF by checking file signature
      final bytes = fontData.buffer.asUint8List();
      if (bytes.length > 4) {
        final signature = bytes.sublist(0, 4);
        final isTTF = signature[0] == 0x00 && signature[1] == 0x01 && signature[2] == 0x00 && signature[3] == 0x00;
        
        if (isTTF) {
          try {
            _pdfFont = pw.Font.ttf(fontData);
            debugPrint('✅ Successfully loaded Khmer OS Siemreap font for PDF generation');
            return _pdfFont!;
          } catch (ttfError) {
            debugPrint('⚠️ TTF parsing error for Khmer OS Siemreap font: $ttfError');
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not load Khmer OS Siemreap font: $e');
    }
    
    // Fallback: Use Helvetica which has good Unicode support for Khmer
    _pdfFont = pw.Font.helvetica();
    debugPrint('📄 Using Helvetica font for PDF generation (fallback - good Unicode support)');
    return _pdfFont!;
  }

  static Future<File> generateServiceReport(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // Load PDF font
    final pdfFont = await _getPdfFont();

    // Load logo image
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('images/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {}

    final String ticketNum =
        data['DocNum']?.toString() ?? data['id']?.toString() ?? 'N/A';
    final String dateStr = data['U_CK_Date'] != null
        ? DateFormat('dd-MMM-yy')
            .format(DateTime.parse(data['U_CK_Date'].toString().split('T')[0]))
        : 'N/A';

    final Map<String, dynamic> reportData = {
      ...data,
      'reportDate': dateStr,
      'reportNo': ticketNum,
      'wod': data['U_CK_WOD']?.toString() ?? '',
      'customer': data['CustomerName']?.toString() ?? '',
      'ckNo': data['U_CK_CKNo']?.toString() ?? '',
      'brand': data['U_CK_Brand']?.toString() ?? '',
      'equipmentType': data['U_CK_JobType']?.toString() ?? '',
      'equipmentId': data['U_CK_EquipmentID']?.toString() ?? '',
      'serviceType': data['U_CK_ServiceType']?.toString() ?? '',
      'location': data['U_CK_Location']?.toString() ?? '',
      'hourMeter': data['U_CK_HourMeter']?.toString() ?? 'N/A',
      'diagnosis': data['U_CK_Diagnosis']?.toString() ?? '',
      'recommendation': data['U_CK_Recommendation']?.toString() ?? '',
      'problemFixed': data['U_CK_ProblemFixed']?.toString() ?? 'Yes',
      'attachedReport': data['U_CK_AttachedReport']?.toString() ?? 'No',
      'nop': data['U_CK_NOP']?.toString() ?? '',
    };

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return [
            _buildHeader(ticketNum, pdfFont, logoImage),
            _buildInfoGrid(reportData, pdfFont),
            _buildFullWidthSection("ការស្នើសុំ ស្ទើពីអតិថិជន/Customer Request",
                reportData['equipmentType'] ?? '', pdfFont,
                height: 30),
            _buildFullWidthSection("ការពិនិត្យកំហូច មូលហេតុនៃកំហូច សេវាកម្មដែលបានផ្តល់/Diagnosis Defect Found Service Rendered",
                reportData['diagnosis'] ?? '', pdfFont,
                height: 120),
            _buildPartsAndMeasurements(reportData, pdfFont),
            _buildFullWidthSection("Technician Recommendation:",
                reportData['recommendation'] ?? '', pdfFont,
                showHeader: false, height: 40),
            _buildImageAttachments(reportData, pdfFont: pdfFont),
            _buildTechnicianAndSignature(reportData, pdfFont),
            _buildFooterMeta(pdfFont: pdfFont),
          ];
        },
      ),
    );

    final outputDir = await getApplicationDocumentsDirectory();
    final file = File('${outputDir.path}/service_report_$ticketNum.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildHeader(String ticketNum, pw.Font pdfFont, pw.MemoryImage? logoImage) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logoImage != null)
                pw.Container(
                  height: 40,
                  child: pw.Image(logoImage),
                )
              else
                pw.Text("CominKhmere",
                    style: pw.TextStyle(
                        font: pdfFont,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold)),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("Hotline:",
                      style: pw.TextStyle(
                          font: pdfFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text("PP: 012 816 800/SHV: 092 777 224",
                      style: pw.TextStyle(font: pdfFont, fontSize: 7)),
                  pw.Text("SR: 012 222 723/PPIA: 092 777 143",
                      style: pw.TextStyle(font: pdfFont, fontSize: 7)),
                  pw.Text("SVIA: 092 666 791",
                      style: pw.TextStyle(font: pdfFont, fontSize: 7)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.SizedBox(width: 5),
              pw.Text("របាយការណ៍សេវាកម្ម/Service Report",
                  style: pw.TextStyle(
                      font: pdfFont,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text("No: $ticketNum",
                  style: pw.TextStyle(
                      font: pdfFont,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoGrid(
      Map<String, dynamic> data, pw.Font pdfFont) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
          border: pw.Border(
        top: pw.BorderSide(width: borderWidth),
        left: pw.BorderSide(width: borderWidth),
        right: pw.BorderSide(width: borderWidth),
      )),
      child: pw.Column(
        children: [
          _buildInfoRow([
            _buildCell("កាលបរិច្ឆេទ/ Date:", data['reportDate'] ?? '',
                flex: 3, pdfFont: pdfFont),
            _buildCell("WOD:", data['wod'] ?? '',
                flex: 3, pdfFont: pdfFont),
            _buildCell("Contract:", data['U_CK_Contract']?.toString() ?? "Yes",
                flex: 2, isLast: true, pdfFont: pdfFont),
          ]),
          _buildInfoRow([
            _buildCell("ឈ្មោះអតិថិជន /\nCustomer particular", data['customer'] ?? '',
                flex: 5, pdfFont: pdfFont),
            _buildCell("លេខសម្គាល់/ CK no", data['ckNo'] ?? '',
                flex: 5, isLast: true, pdfFont: pdfFont),
          ]),
          _buildInfoRow([
            _buildCell("", "", flex: 5, pdfFont: pdfFont),
            _buildCell("ម៉ាក / Brand", data['brand'] ?? '',
                flex: 5, isLast: true, pdfFont: pdfFont),
          ]),
          _buildInfoRow([
            _buildCell("ប្រភេទបរិក្ខា /Type of Equipment", data['equipmentType'] ?? '',
                flex: 5, pdfFont: pdfFont),
            _buildCell("បរិក្ខា/Equipment", data['equipmentId'] ?? '',
                flex: 5, isLast: true, pdfFont: pdfFont),
          ]),
          _buildInfoRow([
            _buildCell("ថ្ងៃតំហែទាំចុងក្រោយ / last PM", _formatDate(data['U_CK_LastPM']),
                flex: 5, pdfFont: pdfFont),
            _buildCell("ទីតាំង/Location", data['location'] ?? '',
                flex: 5, isLast: true, pdfFont: pdfFont),
          ]),
          _buildInfoRow([
            _buildCell("ប្រភេទសេវាកម្ម/ Service type", data['serviceType'] ?? '',
                flex: 5, pdfFont: pdfFont),
            _buildCell("ក្នុងទំហំម៉ោង/ Hour Meter", data['hourMeter'] ?? '',
                flex: 5, isLast: true, pdfFont: pdfFont),
          ]),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(List<pw.Widget> cells) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(width: borderWidth))),
      child: pw.Row(children: cells),
    );
  }

  static pw.Widget _buildCell(String label, String value,
      {int flex = 1, bool isLast = false, required pw.Font pdfFont}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(3),
        decoration: pw.BoxDecoration(
          border: isLast
              ? null
              : const pw.Border(right: pw.BorderSide(width: borderWidth)),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label ?? '',
                style: pw.TextStyle(
                    font: pdfFont,
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
                child: pw.Text(value ?? '',
                    style: pw.TextStyle(
                        font: pdfFont,
                        fontSize: 8,
                        color: PdfColors.blue800,
                        fontStyle: pw.FontStyle.italic))),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildFullWidthSection(
      String title, String content, pw.Font pdfFont,
      {bool showHeader = true, double height = 30}) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(width: borderWidth),
          right: pw.BorderSide(width: borderWidth),
          bottom: pw.BorderSide(width: borderWidth),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (showHeader)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(3),
              decoration: const pw.BoxDecoration(
                  color: primaryGreen,
                  border: pw.Border(bottom: pw.BorderSide(width: borderWidth))),
              child: pw.Text(title ?? '',
                  style: pw.TextStyle(
                      font: pdfFont,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold)),
            ),
          pw.Container(
            constraints: pw.BoxConstraints(minHeight: height),
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(content ?? '',
                style: pw.TextStyle(
                    font: pdfFont,
                    fontSize: 9,
                    color: PdfColors.blue800,
                    fontStyle: pw.FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPartsAndMeasurements(
      Map<String, dynamic> data, pw.Font pdfFont) {
    final parts = data['CK_JOB_MATERIALCollection'] as List? ?? [];
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(width: borderWidth),
          right: pw.BorderSide(width: borderWidth),
          bottom: pw.BorderSide(width: borderWidth),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(3),
                  decoration: const pw.BoxDecoration(
                      color: primaryGreen,
                      border:
                          pw.Border(bottom: pw.BorderSide(width: borderWidth))),
                  child: pw.Text("គ្រឿងបន្លាស់/Part Supply",
                      style: pw.TextStyle(
                          font: pdfFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold)),
                ),
                pw.Container(
                  constraints: const pw.BoxConstraints(minHeight: 60),
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: parts
                        .map((p) => pw.Text(
                            "- ${p['U_CK_ItemName'] ?? ''} (Qty: ${p['U_CK_Qty'] ?? ''})",
                            style: pw.TextStyle(font: pdfFont, fontSize: 7)))
                        .toList(),
                  ),
                ),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(3),
                  decoration: const pw.BoxDecoration(
                      border:
                          pw.Border(top: pw.BorderSide(width: borderWidth))),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text("របាយការណ៍ភ្ជាប់/Attached report:",
                          style: pw.TextStyle(
                              font: pdfFont,
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 5),
                      pw.Text(data['attachedReport'] ?? '',
                          style: pw.TextStyle(
                              font: pdfFont,
                              fontSize: 7,
                              color: PdfColors.blue800,
                              fontStyle: pw.FontStyle.italic)),
                    ],
                  ),
                ),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(3),
                  decoration: const pw.BoxDecoration(
                      border:
                          pw.Border(top: pw.BorderSide(width: borderWidth))),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text("ចំនួនទំព័រ/NOP:",
                          style: pw.TextStyle(
                              font: pdfFont,
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 5),
                      pw.Text(data['nop'] ?? '',
                          style: pw.TextStyle(
                              font: pdfFont,
                              fontSize: 7,
                              color: PdfColors.blue800,
                              fontStyle: pw.FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.Container(width: borderWidth, color: PdfColors.black),
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(3),
                  decoration: const pw.BoxDecoration(
                      color: primaryGreen,
                      border:
                          pw.Border(bottom: pw.BorderSide(width: borderWidth))),
                  child: pw.Text(
                      "លទ្ធផលការវាស់ស្ទង់/Measurements & Test Conducted (Tool serial............. )",
                      style: pw.TextStyle(
                          font: pdfFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold)),
                ),
                pw.Container(
                  constraints: const pw.BoxConstraints(minHeight: 60),
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(data['U_CK_Measurements']?.toString() ?? '',
                      style: pw.TextStyle(
                          font: pdfFont,
                          fontSize: 7,
                          color: PdfColors.blue800,
                          fontStyle: pw.FontStyle.italic)),
                ),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(
                      border:
                          pw.Border(top: pw.BorderSide(width: borderWidth))),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text("កំហូចត្រូវបានជួសជុល/Problem fixed upon departure:",
                          style: pw.TextStyle(
                              font: pdfFont,
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 5),
                      pw.Text(data['problemFixed'] ?? '',
                          style: pw.TextStyle(
                              font: pdfFont,
                              fontSize: 7,
                              color: PdfColors.blue800,
                              fontStyle: pw.FontStyle.italic)),
                    ],
                  ),
                ),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(3),
                  decoration: const pw.BoxDecoration(
                      border:
                          pw.Border(top: pw.BorderSide(width: borderWidth))),
                  child: pw.Text(
                      "បញ្ជាក់ពីមូលហេតុដែលមិនត្រូវបានជួសជុលនិងដំណោះស្រាយ if not, mention why: ${data['U_CK_ReasonIfNotFixed']?.toString() ?? ''}",
                      style: pw.TextStyle(
                          font: pdfFont,
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTechnicianAndSignature(
      Map<String, dynamic> data, pw.Font pdfFont) {
    final List<dynamic> files = data['files'] as List? ?? [];
    pw.MemoryImage? signatureImage;
    try {
      final allImages = files
          .where((f) => (f is Map &&
              (f['ext']?.toString().toLowerCase() == 'png' ||
                  f['ext']?.toString().toLowerCase() == 'jpg') &&
              f['data'] != null))
          .toList();
      if (allImages.isNotEmpty) {
        signatureImage = pw.MemoryImage(base64Decode(allImages.last['data']));
      }
    } catch (e) {}

    final List<dynamic> timeEntries =
        data['CK_JOB_TIMECollection'] as List? ?? [];

    Map<String, dynamic> travelTime = <String, dynamic>{};
    for (var e in timeEntries) {
      if (e is Map && e['U_CK_Description'] == 'Travel Time') {
        travelTime = Map<String, dynamic>.from(e);
        break;
      }
    }

    Map<String, dynamic> serviceTime = <String, dynamic>{};
    for (var e in timeEntries) {
      if (e is Map && e['U_CK_Description'] == 'Service Time') {
        serviceTime = Map<String, dynamic>.from(e);
        break;
      }
    }

    return pw.Container(
      decoration: const pw.BoxDecoration(
          border: pw.Border(
        left: pw.BorderSide(width: borderWidth),
        right: pw.BorderSide(width: borderWidth),
        bottom: pw.BorderSide(width: borderWidth),
        top: pw.BorderSide(width: borderWidth),
      )),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(3),
                  decoration: const pw.BoxDecoration(
                      color: primaryGreen,
                      border:
                          pw.Border(bottom: pw.BorderSide(width: borderWidth))),
                  child: pw.Text("ជាងបច្ចេកទេស/List of Technician",
                      style: pw.TextStyle(
                          font: pdfFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold)),
                ),
                _buildTechRow(
                    "ឈ្មោះ: Names", data['U_CK_Technician']?.toString() ?? '',
                    pdfFont: pdfFont),
                _buildTechRow("Date & Time Arrived",
                    "${travelTime['U_CK_StartTime'] ?? ''} ${travelTime['U_CK_EndTime'] ?? ''}",
                    pdfFont: pdfFont),
                _buildTechRow("Date & Time Completed",
                    "${serviceTime['U_CK_StartTime'] ?? ''} ${serviceTime['U_CK_EndTime'] ?? ''}",
                    pdfFont: pdfFont),
                _buildTechRow(
                    "Total Hour", data['U_CK_Effort']?.toString() ?? '',
                    pdfFont: pdfFont, isLast: true),
              ],
            ),
          ),
          pw.Container(width: borderWidth, color: PdfColors.black),
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(3),
                  decoration: const pw.BoxDecoration(
                      color: primaryGreen,
                      border:
                          pw.Border(bottom: pw.BorderSide(width: borderWidth))),
                  child: pw.Text(
                      "អតិថិជន: ឈ្មោះ, តួនាទី, កាលបរិច្ឆេទ, ហត្ថលេខា និង មតិយោបល់/Customer: Name, Position, Date, Signature & Comments",
                      style: pw.TextStyle(
                          font: pdfFont,
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold)),
                ),
                pw.Container(
                  height: 80,
                  padding: const pw.EdgeInsets.all(5),
                  child: signatureImage != null
                      ? pw.Center(child: pw.Image(signatureImage, height: 50))
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTechRow(String label, String value,
      {bool isLast = false, required pw.Font pdfFont}) {
    return pw.Container(
      decoration: pw.BoxDecoration(
          border: isLast
              ? null
              : const pw.Border(bottom: pw.BorderSide(width: borderWidth))),
      child: pw.Row(
        children: [
          pw.Container(
            width: 80,
            padding: const pw.EdgeInsets.all(3),
            decoration: pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(width: borderWidth))),
            child: pw.Text(label ?? '',
                style: pw.TextStyle(
                    font: pdfFont,
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 5),
              child: pw.Text(value ?? '',
                  style: pw.TextStyle(
                      font: pdfFont,
                      fontSize: 8,
                      color: PdfColors.blue800,
                      fontStyle: pw.FontStyle.italic)),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildImageAttachments(Map<String, dynamic> data,
      {pw.Font? pdfFont}) {
    final List<dynamic> files = data['files'] as List? ?? [];
    final List<dynamic> allImages = files
        .where((f) => (f is Map &&
            (f['ext']?.toString().toLowerCase() == 'jpg' ||
                f['ext']?.toString().toLowerCase() == 'jpeg' ||
                f['ext']?.toString().toLowerCase() == 'png') &&
            f['data'] != null))
        .toList();
    
    // Usually the last image is the signature, so we exclude it
    final List<dynamic> reportImages =
        allImages.length > 1 ? allImages.sublist(0, allImages.length - 1) : [];
    
    if (reportImages.isEmpty) return pw.SizedBox();

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      decoration: const pw.BoxDecoration(
          border: pw.Border(
        left: pw.BorderSide(width: borderWidth),
        right: pw.BorderSide(width: borderWidth),
        bottom: pw.BorderSide(width: borderWidth),
        top: pw.BorderSide(width: borderWidth),
      )),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(3),
            decoration: const pw.BoxDecoration(
                color: primaryGreen,
                border: pw.Border(bottom: pw.BorderSide(width: borderWidth))),
            child: pw.Text("រូបភាពរបាយការណ៍/ Picture Report",
                style: pw.TextStyle(
                    font: pdfFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: reportImages.take(4).map((img) {
                try {
                  final image = pw.MemoryImage(base64Decode(img['data']));
                  return pw.Expanded(
                    child: pw.Container(
                      margin: const pw.EdgeInsets.symmetric(horizontal: 2),
                      child: pw.Column(
                        children: [
                          pw.Container(
                            height: 100,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.grey300, width: borderWidth)),
                            child: pw.Image(image, fit: pw.BoxFit.cover),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(img['U_CK_Description']?.toString() ?? 'Image',
                              style: pw.TextStyle(
                                  font: pdfFont,
                                  fontSize: 7,
                                  color: PdfColors.blue800,
                                  fontStyle: pw.FontStyle.italic)),
                        ],
                      ),
                    ),
                  );
                } catch (e) {
                  return pw.SizedBox();
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooterMeta({pw.Font? pdfFont}) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Form Number: CK-SDD-F-0042",
                  style: pw.TextStyle(font: pdfFont, fontSize: 8)),
              pw.Text("Revision: 2",
                  style: pw.TextStyle(font: pdfFont, fontSize: 8)),
              pw.Text("Date: 12-Aug-2025",
                  style: pw.TextStyle(font: pdfFont, fontSize: 8)),
            ],
          ),
          pw.Row(
            children: [
              pw.Text("CK use: ________",
                  style: pw.TextStyle(font: pdfFont, fontSize: 7)),
              pw.SizedBox(width: 10),
              pw.Text("Check by: ________",
                  style: pw.TextStyle(font: pdfFont, fontSize: 7)),
              pw.SizedBox(width: 10),
              pw.Text("Checked on: ________",
                  style: pw.TextStyle(font: pdfFont, fontSize: 7)),
            ],
          ),
        ],
      ),
    );
  }

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
