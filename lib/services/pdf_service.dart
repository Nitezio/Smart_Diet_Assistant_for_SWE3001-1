import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../providers/app_state.dart';

class PdfService {
  static Future<void> generateMedicalReport(UserProfile user, List<MealHistoryItem> history) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        // Define Header/Footer globally for the MultiPage to prevent builder scope errors
        header: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Text(
            "Smart Diet Assistant - Medical Report",
            style: pw.TextStyle(color: PdfColors.grey, fontSize: 10),
          ),
        ),
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            "Page ${context.pageNumber} of ${context.pagesCount}",
            style: pw.TextStyle(color: PdfColors.grey, fontSize: 10),
          ),
        ),
        build: (pw.Context context) => [
          // 1. MAIN TITLE
          pw.Text("OFFICIAL MEDICAL NUTRITION REPORT", 
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
          pw.SizedBox(height: 5),
          pw.Text("Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}"),
          
          pw.SizedBox(height: 20),

          // 2. PATIENT PROFILE SECTION
          pw.Text("Patient Details", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(thickness: 1, color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Full Name: ${user.name}"),
                    pw.Text("Age: ${user.age}"),
                    pw.Text("Gender: ${user.gender}"),
                    pw.Text("Health Goal: ${user.goal}"),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Conditions: ${user.conditions.join(', ')}"),
                    pw.Text("Allergies: ${user.allergies.join(', ')}"),
                    pw.Text("Activity: ${user.activityLevel}"),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 30),

          // 3. MEAL HISTORY TABLE
          pw.Text("Clinical Intake History", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10),
            headers: ['Date', 'Time', 'Type', 'Dish Name', 'Calories'],
            data: history.isEmpty 
              ? [['No data', 'No data', 'No data', 'No data', 'No data']]
              : history.map((item) => [
                  DateFormat('dd/MM/yy').format(item.timestamp),
                  DateFormat('hh:mm a').format(item.timestamp),
                  item.mealType,
                  item.dishName,
                  "${item.calories} kcal"
                ]).toList(),
          ),
        ],
      ),
    );

    // Show Preview/Share dialog
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: "SDA_Report_${user.name.replaceAll(' ', '_')}.pdf",
      );
    } catch (e) {
      print("🔴 Printing Error: $e");
    }
  }
}
