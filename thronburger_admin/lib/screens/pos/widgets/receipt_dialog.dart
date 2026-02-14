import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/models.dart';
import '../../../services/printing/printing_service.dart';

/// Receipt Dialog
/// Shows order receipt with print options for kitchen ticket and receipt
class ReceiptDialog extends StatelessWidget {
  final Order order;

  const ReceiptDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'en');
    final dateFormatter = DateFormat('MMM d, yyyy h:mm a');

    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        width: 320,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Receipt content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    const Text(
                      'THRONBURGER',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Empire City, Erbil',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),

                    // Order type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.orderType.label.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.black26),
                    const SizedBox(height: 16),

                    // Order info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order #',
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          '${order.orderNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          dateFormatter.format(order.createdAt.toLocal()),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.black26),
                    const SizedBox(height: 16),

                    // Items
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              child: Text(
                                '${item.quantity}x',
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.menuItem?.name ?? 'Item',
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                            Text(
                              formatter.format(item.lineTotal.toInt()),
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Divider(color: Colors.black26),
                    const SizedBox(height: 16),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${formatter.format(order.totalAmount.toInt())} IQD',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Thank you for your order!',
                      style: TextStyle(
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Column(
                children: [
                  // Print buttons row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _printKitchenTicket(context),
                          icon: const Icon(Icons.restaurant, size: 18),
                          label: const Text('Kitchen'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange.shade700,
                            side: BorderSide(color: Colors.orange.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _printReceipt(context),
                          icon: const Icon(Icons.receipt_long, size: 18),
                          label: const Text('Receipt'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black54,
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printKitchenTicket(BuildContext context) async {
    try {
      await PrintingService().printKitchenTicket(order);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print kitchen ticket: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printReceipt(BuildContext context) async {
    try {
      await PrintingService().printReceipt(order);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
