import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/qr_code_service.dart';
import '../../domain/entities/event.dart';
import '../../core/themes/app_theme.dart';
import 'qr_scanner_page.dart';

class EventQRPage extends StatefulWidget {
  final Event event;
  
  const EventQRPage({super.key, required this.event});

  @override
  State<EventQRPage> createState() => _EventQRPageState();
}

class _EventQRPageState extends State<EventQRPage> {
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

  String _formatDate(DateTime date) {
    final monthsFR = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    final monthsEN = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthsES = [
      'ene.', 'feb.', 'mar.', 'abr.', 'may.', 'jun.',
      'jul.', 'ago.', 'sep.', 'oct.', 'nov.', 'dic.'
    ];
    
    switch (_languageCode) {
      case 'en':
        return '${date.day} ${monthsEN[date.month - 1]} ${date.year}';
      case 'es':
        return '${date.day} ${monthsES[date.month - 1]} ${date.year}';
      default:
        return '${date.day} ${monthsFR[date.month - 1]} ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('QR Code Événement', 'Event QR Code', 'Código QR del Evento')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareQRCode(context),
            tooltip: _getText('Partager', 'Share', 'Compartir'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.qr_code,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.event.location,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(widget.event.date),
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: QRCodeService.generateEventQRCode(
                  eventId: widget.event.id,
                  eventName: widget.event.title,
                  eventDate: _formatDate(widget.event.date),
                  location: widget.event.location,
                  size: 250,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                _getText(
                  'Scannez ce code QR pour obtenir les informations de l\'événement',
                  'Scan this QR code to get event information',
                  'Escanee este código QR para obtener información del evento',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareQRCode(context),
                      icon: const Icon(Icons.share),
                      label: Text(_getText('Partager', 'Share', 'Compartir')),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QRScannerPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(_getText('Scanner', 'Scan', 'Escanear')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _shareQRCode(BuildContext context) async {
    final qrData = {
      'type': 'event',
      'id': widget.event.id,
      'name': widget.event.title,
      'date': _formatDate(widget.event.date),
      'location': widget.event.location,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    await QRCodeService.shareQRCode(
      data: jsonEncode(qrData),
      fileName: widget.event.title.replaceAll(' ', '_'),
    );
  }
}