import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/themes/app_theme.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  String? _lastScannedData;
  String _languageCode = 'fr';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _languageCode = prefs.getString('language') ?? 'fr';
    });
  }

  String _getText(String fr, String en, String es) {
    switch (_languageCode) {
      case 'en':
        return en;
      case 'es':
        return es;
      default:
        return fr;
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          _getText('Scanner QR Code', 'Scan QR Code', 'Escanear Código QR'),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _scannerController.toggleTorch(),
            tooltip: _getText('Lampe torche', 'Flashlight', 'Linterna'),
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () => _scannerController.switchCamera(),
            tooltip: _getText('Changer caméra', 'Switch camera', 'Cambiar cámara'),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onQRCodeDetected,
          ),
          _buildScannerOverlay(),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Traitement en cours...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor, width: 3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 50,
              color: Colors.white70,
            ),
            const SizedBox(height: 10),
            Text(
              _getText(
                'Positionnez le QR code dans le cadre',
                'Position the QR code in the frame',
                'Coloque el código QR en el marco',
              ),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _onQRCodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    
    final qrData = barcode!.rawValue!;
    if (_lastScannedData == qrData) return;
    
    _lastScannedData = qrData;
    _isProcessing = true;
    
    try {
      final decodedData = jsonDecode(qrData);
      final type = decodedData['type'];
      
      if (type == 'event') {
        _handleEventQR(decodedData);
      } else {
        _showErrorDialog(_getText(
          'Format de QR code non reconnu',
          'QR code format not recognized',
          'Formato de código QR no reconocido',
        ));
      }
    } catch (e) {
      _showErrorDialog(_getText(
        'QR code invalide',
        'Invalid QR code',
        'Código QR inválido',
      ));
    } finally {
      _isProcessing = false;
      await Future.delayed(const Duration(seconds: 2));
      _lastScannedData = null;
    }
  }
  
  void _handleEventQR(Map<String, dynamic> data) {
    final eventId = data['id'];
    final eventName = data['name'];
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getText(
          'Événement scanné: $eventName',
          'Event scanned: $eventName',
          'Evento escaneado: $eventName',
        )),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: _getText('Voir', 'View', 'Ver'),
          onPressed: () {
            context.go('/event/$eventId');
          },
        ),
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getText('Erreur', 'Error', 'Error')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('OK', 'OK', 'OK')),
          ),
        ],
      ),
    );
  }
}