import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_provider.dart';
import '../controllers/sales_provider.dart';
import '../models/transaction_model.dart'; // Import TransactionModel for the dialog

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesProvider>(context, listen: false).fetchMyTransactions();
    });
  }

  // --- NEW: Function to show transaction details including address ---
  void _showTransactionDetails(
      BuildContext context, TransactionModel transaction, bool isSale) {
    final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            isSale
                ? 'Sale: ${transaction.productName}'
                : 'Purchase: ${transaction.productName}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Status and ID
                _buildDetailRow(
                    'Status:',
                    transaction.paymentStatus == 'completed'
                        ? 'Completed'
                        : 'Failed/Pending',
                    transaction.paymentStatus == 'completed'
                        ? Colors.green
                        : Colors.orange),
                _buildDetailRow('Transaction ID:', transaction.transactionId),
                _buildDetailRow('Payment ID:',
                    transaction.paymentId.isNotEmpty ? transaction.paymentId : 'N/A'),
                const Divider(),
                // Product & Price
                _buildDetailRow('Date:', formatter.format(transaction.timestamp.toDate())),
                _buildDetailRow('Unit Price:', '₹${transaction.unitPrice.toStringAsFixed(2)} / ${transaction.unit}'),
                _buildDetailRow('Quantity:', '${transaction.quantityPurchased} ${transaction.unit}'),
                _buildDetailRow('Total Amount:', '₹${transaction.totalPrice.toStringAsFixed(2)}', Colors.black, true),
                const Divider(),
                // Counterparty
                _buildDetailRow(isSale ? 'Buyer:' : 'Seller:',
                    isSale ? transaction.buyerName : transaction.sellerName),
                
                const SizedBox(height: 10),
                // --- SHIPPING ADDRESS SECTION (NEW) ---
                const Text('Shipping Address:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
                const SizedBox(height: 5),
                Text(transaction.shippingAddress),
                Text('${transaction.city}, ${transaction.state}'),
                Text('Pincode: ${transaction.postalCode}'),
                // --- END OF SHIPPING ADDRESS SECTION ---
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value,
      [Color color = Colors.black, bool isTotal = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
  // --- END OF NEW FUNCTION ---

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).userModel?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.myTransactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null &&
              provider.myTransactions.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.myTransactions.isEmpty) {
            return const Center(
              child: Text(
                'You have no transaction history yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMyTransactions(),
            child: ListView.builder(
              itemCount: provider.myTransactions.length,
              itemBuilder: (context, index) {
                final transaction = provider.myTransactions[index];
                final bool isSale = transaction.sellerId == currentUserId;
                final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');

                final String unitDisplay = transaction.unit ?? 'units';

                String transactionDetail =
                    '${isSale ? "Sold to" : "Bought from"} ${isSale ? transaction.buyerName : transaction.sellerName}\n'
                    '${transaction.quantityPurchased} ${unitDisplay} @ ₹${transaction.unitPrice.toStringAsFixed(2)} each\n'
                    '${formatter.format(transaction.timestamp.toDate())}';

                // --- ADDED TO DISPLAY PAYMENT STATUS ---
                if (transaction.paymentStatus == 'completed') {
                  // Safely get the last 6 chars of the payment ID
                  String shortId = transaction.paymentId.length > 6
                      ? transaction.paymentId
                          .substring(transaction.paymentId.length - 6)
                      : transaction.paymentId;
                  transactionDetail += '\nStatus: Completed (ID: ...$shortId)';
                } else if (transaction.paymentStatus.isNotEmpty) {
                  // This will show 'failed' or 'dummy' if they exist
                  transactionDetail += '\nStatus: ${transaction.paymentStatus}';
                }
                // --- END OF ADDED CODE ---

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  // --- NEW: Add onTap to show details ---
                  child: InkWell(
                    onTap: () => _showTransactionDetails(context, transaction, isSale),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSale
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        child: Icon(
                          isSale ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isSale ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        transaction.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        transactionDetail,
                      ),
                      trailing: Text(
                        '${isSale ? "+" : "-"} ₹${transaction.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isSale ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  // --- END OF onTap change ---
                );
              },
            ),
          );
        },
      ),
    );
  }
}