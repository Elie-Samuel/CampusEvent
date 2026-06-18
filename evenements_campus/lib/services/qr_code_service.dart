import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QRCodeService {
  // Générer un QR code pour un événement
  static Widget generateEventQRCode({
    required String eventId,
    required String eventName,
    required String eventDate,
    required String location,
    double size = 200,
  }) {
    final qrData = jsonEncode({
      'type': 'event',
      'id': eventId,
      'name': eventName,
      'date': eventDate,
      'location': location,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      errorStateBuilder: (context, error) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.qr_code, size: 50, color: Colors.grey),
        );
      },
    );
  }
  
  // Partager le QR code
  static Future<void> shareQRCode({
    required String data,
    required String fileName,
  }) async {
    try {
      await Share.share('QR Code: $data');
    } catch (e) {
      print('Erreur lors du partage: $e');
    }
  }
}