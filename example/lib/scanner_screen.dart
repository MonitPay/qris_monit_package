import 'package:flutter/material.dart';
import 'package:qris_monit_package/qris_monit_package.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

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
      body: QRISScanner(
        qrisController: qrisController,
        onScanCompleted: (rawData, qrisData, qrisError) async {
          debugPrint('Raw Data === $rawData');
          debugPrint('Merchant Name === ${qrisData?.merchantName}');
          debugPrint('Merchant City === ${qrisData?.merchantCity}');
        },
        errorBuilder: (_, error, __) {
          return Center(
            child: Container(
              color: Colors.white,
              child: Text('${error.errorDetails?.message}'),
            ),
          );
        },
        frontCanvasBuilder: (qrisData) {
          return [
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            qrisController.toggleTorch();
                          },
                          icon: ValueListenableBuilder(
                              valueListenable: qrisController,
                              builder: (context, state, child) {
                                switch (state.torchState) {
                                  case TorchState.off:
                                    return const Icon(Icons.flash_off);
                                  case TorchState.on:
                                    return const Icon(Icons.flash_on);
                                  default:
                                    return const Icon(Icons.flash_off);
                                }
                              }),
                        ),
                        IconButton(
                          onPressed: () {
                            qrisController.openGallery();
                          },
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                        ),
                      ],
                    ),
                    Builder(builder: (context) {
                      if (qrisData != null) {
                        return ExpansionTile(
                          title: const Text('Result'),
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'QRIS Result',
                                  style: TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Merchant Name: ${qrisData.merchantName}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Merchant City: ${qrisData.merchantCity}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Transaction Amount: ${qrisData.transactionAmount}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Transaction Currency: ${qrisData.transactionCurrency}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                FutureBuilder<Currency?>(
                                  future: qrisData.getTransactionCurrency(),
                                  builder: (_, data) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Transaction Currency: ${data.data?.currency}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Transaction Currency Name: ${data.data?.name}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Transaction Currency Symbol: ${data.data?.symbol}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox();
                      }
                    }),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );
  }
}
