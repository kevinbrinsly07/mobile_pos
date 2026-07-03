import 'dart:typed_data';

import 'package:printing/printing.dart';

class PrinterService {
  Future<void> printPdf(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<List<Printer>> discoverPrinters() async {
    return Printing.listPrinters();
  }
}
