import 'package:flutter/material.dart';
import 'package:jogo_da_velha/channels/qr_code_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  final Function(String) onQrCodeScanned;

  const QrScannerScreen({
    super.key,
    required this.onQrCodeScanned,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
    });

    try {
      final result = await NativeQrScanner.scan();
      
      if (!mounted) return;
      
      if (result != null) {
        widget.onQrCodeScanned(result);
      }
      
      // Fecha a tela se o usuário cancelou ou escaneou
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao escanear: $e')),
      );
      
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Abrindo scanner...'),
          ],
        ),
      ),
    );
  }
}
