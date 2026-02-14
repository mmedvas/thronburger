import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/models.dart';

/// Receipt Generator
/// Creates branded receipt PDFs with logo for 80mm thermal printers
class ReceiptGenerator {
  pw.MemoryImage? _logoImage;

  /// Load logo from assets
  Future<void> _loadLogo() async {
    if (_logoImage != null) return;

    try {
      final data = await rootBundle.load('assets/images/logo_original.png');
      _logoImage = pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      // Logo loading failed, will proceed without logo
      _logoImage = null;
    }
  }

  /// Generate receipt PDF bytes
  Future<List<int>> generate(Order order) async {
    await _loadLogo();

    final pdf = pw.Document();
    final formatter = NumberFormat('#,###', 'en');
    final dateFormatter = DateFormat('MMM d, yyyy h:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(8),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Logo
              if (_logoImage != null)
                pw.Container(
                  width: 80,
                  height: 80,
                  child: pw.Image(_logoImage!),
                )
              else
                pw.Text(
                  'THRONBURGER',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              pw.SizedBox(height: 4),

              // Store info
              pw.Text(
                'THRONBURGER',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Empire City, Erbil',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 12),

              // Order type badge
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  order.orderType.label.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),

              pw.Divider(),
              pw.SizedBox(height: 8),

              // Order info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Order #', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    '${order.orderNumber}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    dateFormatter.format(order.createdAt.toLocal()),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),

              // Customer info for online orders
              if (order.isOnlineOrder) ...[
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Customer',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (order.customerName != null)
                        pw.Text(
                          order.customerName!,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      if (order.customerPhone != null)
                        pw.Text(
                          order.customerPhone!,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      if (order.customerAddress != null)
                        pw.Text(
                          order.customerAddress!,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                    ],
                  ),
                ),
              ],

              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Items
              ...order.items.map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 20,
                        child: pw.Text(
                          '${item.quantity}x',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          item.menuItem?.name ?? 'Item',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Text(
                        formatter.format(item.lineTotal.toInt()),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${formatter.format(order.totalAmount.toInt())} IQD',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Thank you footer
              pw.Text(
                'Thank you for your order!',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'See you again soon!',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 16),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
