import 'dart:typed_data';

import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../models/models.dart';
import 'kitchen_ticket_generator.dart';
import 'receipt_generator.dart';

/// Printing Service
/// Orchestrates printing of receipts and kitchen tickets
class PrintingService {
  final KitchenTicketGenerator _kitchenTicketGenerator = KitchenTicketGenerator();
  final ReceiptGenerator _receiptGenerator = ReceiptGenerator();

  /// Print customer receipt with branding
  Future<void> printReceipt(Order order) async {
    final pdfBytes = await _receiptGenerator.generate(order);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => Uint8List.fromList(pdfBytes),
      format: PdfPageFormat.roll80,
    );
  }

  /// Print kitchen ticket (no prices, optimized for kitchen staff)
  Future<void> printKitchenTicket(Order order) async {
    final pdfBytes = await _kitchenTicketGenerator.generate(order);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => Uint8List.fromList(pdfBytes),
      format: PdfPageFormat.roll80,
    );
  }

  /// Get receipt PDF bytes (for preview or direct printing)
  Future<List<int>> getReceiptPdf(Order order) async {
    return _receiptGenerator.generate(order);
  }

  /// Get kitchen ticket PDF bytes (for preview or direct printing)
  Future<List<int>> getKitchenTicketPdf(Order order) async {
    return _kitchenTicketGenerator.generate(order);
  }
}
