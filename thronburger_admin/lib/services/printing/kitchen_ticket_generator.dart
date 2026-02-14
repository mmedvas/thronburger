import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/models.dart';

/// Kitchen Ticket Generator
/// Creates kitchen-optimized ticket PDFs for 80mm thermal printers
class KitchenTicketGenerator {
  /// Generate kitchen ticket PDF bytes
  Future<List<int>> generate(Order order) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat('h:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(8),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Order number - large and prominent
              pw.Center(
                child: pw.Text(
                  'ORDER #${order.orderNumber}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),

              // Order type badge
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 2),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    _getOrderTypeLabel(order.orderType),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 8),

              // Time
              pw.Center(
                child: pw.Text(
                  dateFormatter.format(order.createdAt.toLocal()),
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 12),

              // Divider
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 12),

              // Items - large font for readability
              ...order.items.map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Quantity - prominent
                      pw.Container(
                        width: 36,
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 1),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            '${item.quantity}x',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      // Item name - large
                      pw.Expanded(
                        child: pw.Text(
                          item.menuItem?.name ?? 'Item',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Notes section - highlighted if present
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 2),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'NOTES:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        order.notes!,
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              // Customer info for online orders
              if (order.isOnlineOrder && order.customerName != null) ...[
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Customer: ${order.customerName}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
                if (order.customerPhone != null)
                  pw.Text(
                    'Phone: ${order.customerPhone}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
              ],

              pw.SizedBox(height: 16),
              pw.Divider(thickness: 2),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  String _getOrderTypeLabel(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return 'DINE-IN';
      case OrderType.pickup:
        return 'PICKUP';
      case OrderType.online:
        return 'ONLINE ORDER';
    }
  }
}
