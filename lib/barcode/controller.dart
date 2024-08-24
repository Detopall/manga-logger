import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:manga_logger/barcode/button_widget.dart';
import 'package:manga_logger/barcode/error_widget.dart';

class BarcodeScannerWithController extends StatefulWidget {
  const BarcodeScannerWithController({super.key});

  @override
  State<BarcodeScannerWithController> createState() =>
      _BarcodeScannerWithControllerState();
}

class _BarcodeScannerWithControllerState
    extends State<BarcodeScannerWithController> with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    autoStart: false,
    torchEnabled: false,
    useNewCameraSelector: true,
  );

  StreamSubscription<Object?>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start listening to barcode scans
    _subscription = controller.barcodes.listen(_handleBarcode);
    controller.start();
  }

  void _handleBarcode(BarcodeCapture barcodes) async {
    final Barcode? barcode = barcodes.barcodes.firstOrNull;
    if (barcode != null && mounted) {
      // Stop scanning and send the barcode back to the parent widget
      await _stopCamera();
      Navigator.pop(context, barcode.displayValue ?? 'No barcode found');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        _subscription ??= controller.barcodes.listen(_handleBarcode);
        controller.start().catchError((_) {});
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _stopCamera();
        break;
    }
  }

  Future<void> _stopCamera() async {
    await _subscription?.cancel();
    _subscription = null;
    await controller.stop().catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            errorBuilder: (context, error, child) {
              return ScannerErrorWidget(error: error);
            },
            fit: BoxFit.contain,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 100,
              color: Colors.black.withOpacity(0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ToggleFlashlightButton(controller: controller),
                  StartStopMobileScannerButton(controller: controller),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Scan something!',
                        overflow: TextOverflow.fade,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SwitchCameraButton(controller: controller),
                  AnalyzeImageFromGalleryButton(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _stopCamera();
    await controller.dispose();
    super.dispose();
  }
}
