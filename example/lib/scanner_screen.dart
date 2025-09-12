import 'package:flutter/material.dart';
import 'package:qris_monit_package/qris_monit_package.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final QRISController qrisController = QRISController();

  @override
  void dispose() {
    qrisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRIS Scanner Example'),
        centerTitle: true,
      ),
      body: QRISScanner(
        qrisController: qrisController,
        onScanCompleted: (rawData, qrisData, qrisError) async {
          if (qrisError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(qrisError.message ?? 'Unknown error'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          qrisController.pause();
          showAdaptiveDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog.adaptive(
                title: const Text('QRIS Result'),
                content: Column(
                  children: [
                    Text('Raw Data: ${rawData ?? 'No Data'}'),
                    Text('Merchant Name: ${qrisData?.merchantName}'),
                    Text('Merchant City: ${qrisData?.merchantCity}'),
                    Text('Transaction Amount: ${qrisData?.transactionAmount}'),
                    Text(
                        'Transaction Currency: ${qrisData?.transactionCurrency}'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      qrisController.start();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
        errorBuilder: (_, error) {
          return Center(
            child: Container(
              color: Colors.white,
              child: Text(error.errorCode.message),
            ),
          );
        },
      ),
    );
  }
}
