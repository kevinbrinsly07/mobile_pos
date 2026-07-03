import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/sale.dart';

class ReceiptService {
  Future<Uint8List> buildReceiptPdf({
    required String storeName,
    required SaleDraft sale,
  }) async {
    final doc = pw.Document();
    final fmt = NumberFormat.simpleCurrency();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(storeName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              ...sale.items.map(
                (item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text('${item.product.name} x${item.quantity}')),
                    pw.Text(fmt.format(item.totalCents / 100)),
                  ],
                ),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text('Total'), pw.Text(fmt.format(sale.totalCents / 100))],
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }
}
