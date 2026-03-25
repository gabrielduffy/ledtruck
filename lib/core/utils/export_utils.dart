import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;

class ExportUtils {
  /// Exporta uma lista de linhas matriciais para CSV (compatível com Web)
  static Future<void> exportarCSV(List<List<dynamic>> rows, String filename) async {
    try {
      String csvData = const ListToCsvConverter().convert(rows);
      
      // Adicionar BOM para Excel reconhecer UTF-8
      final bytes = utf8.encode(csvData);
      final bom = [0xEF, 0xBB, 0xBF];
      
      final blob = html.Blob([bom, bytes], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$filename.csv')
        ..click();
        
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      debugPrint("Erro ao exportar CSV: $e");
    }
  }

  /// Exporta uma lista de linhas para um Documento tabular PDF (compatível com cross-platform)
  static Future<void> exportarPDF(List<String> headers, List<List<dynamic>> rows, String title, String filename) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange)),
              pw.SizedBox(height: 8),
              pw.Text("Gerado em: ${DateTime.now().toLocal().toString().split('.')[0]}"),
              pw.SizedBox(height: 16),
            ]
          ),
          build: (context) => [
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: rows,
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.deepOrange),
              cellHeight: 30,
              cellAlignments: {
                for (int i = 0; i < headers.length; i++) i: pw.Alignment.centerLeft,
              },
              cellStyle: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      );

      await Printing.sharePdf(bytes: await pdf.save(), filename: '$filename.pdf');
    } catch (e) {
      debugPrint("Erro ao gerar PDF: $e");
    }
  }
}
