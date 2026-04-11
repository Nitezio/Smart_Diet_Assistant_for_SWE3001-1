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
        build: (context) => [
          // 1. HEADER
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Smart Diet Assistant - Medical Report", 
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
              ]
            ),
          ),
          
          pw.SizedBox(height: 20),

          // 2. PATIENT PROFILE SECTION
          pw.Text("Patient Profile", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Name: ${user.name}"),
                  pw.Text("Age: ${user.age}"),
                  pw.Text("Gender: ${user.gender}"),
                  pw.Text("Goal: ${user.goal}"),
                ],
              ),
              pw.SizedBox(width: 50),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Conditions: ${user.conditions.join(', ')}"),
                  pw.Text("Allergies: ${user.allergies.join(', ')}"),
                  pw.Text("Activity Level: ${user.activityLevel}"),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 30),

          // 3. MEAL HISTORY TABLE
          pw.Text("Nutritional Intake History", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green),
            cellAlignment: pw.Alignment.centerLeft,
            headers: ['Date', 'Time', 'Meal Type', 'Dish Name', 'Calories'],
            data: history.map((item) => [
              DateFormat('dd/MM/yyyy').format(item.timestamp),
              DateFormat('hh:mm a').format(item.timestamp),
              item.mealType,
              item.dishName,
              "${item.calories} kcal"
            ]).toList(),
          ),

          pw.SizedBox(height: 20),
          pw.Footer(
            margin: const pw.EdgeInsets.only(top: 20),
            trailing: pw.Text("Page ${context.pageNumber} of ${context.pagesCount}"),
          )
        ],
      ),
    );

    // Show Preview/Share dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "SDA_Medical_Report_${user.name}.pdf",
    );
  }
}
