import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/crashlytics_service.dart';

class QrCodeSaver {
  /// Save QR code to device gallery
  static Future<bool> saveQrCodeToGallery({
    required String data,
    required String filename,
  }) async {
    try {
      // Request permission
      if (Platform.isIOS) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          return false;
        }
      } else if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          return false;
        }
      }

      // Generate QR code image with logo
      final qrImage = await _generateQrCodeWithLogo(data);
      if (qrImage == null) return false;

      // Save to gallery
      final result = await ImageGallerySaver.saveImage(
        qrImage,
        name: filename,
        isReturnImagePathOfIOS: true,
      );

      return result['isSuccess'] ?? false;
    } catch (e, stack) {
      await CrashlyticsService.recordQrError('saveQrCodeToGallery', e, stack);
      print('Error saving QR code: $e');
      return false;
    }
  }

  /// Generate QR code image with app logo overlay
  static Future<Uint8List?> _generateQrCodeWithLogo(String data) async {
    try {
      // Create a custom painter to draw QR code with logo
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = 512.0; // High resolution for better quality
      
      // Draw white background
      final backgroundPaint = Paint()..color = Colors.white;
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, size, size),
        backgroundPaint,
      );

      // Create QR code painter
      final qrPainter = QrPainter(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.H, // High error correction for logo overlay
        color: Colors.black,
        emptyColor: Colors.white,
      );

      // Paint QR code
      qrPainter.paint(canvas, const Size(size, size));

      // Draw app logo in center
      const logoSize = 80.0;
      const logoOffset = (size - logoSize) / 2;
      
      // Draw white background for logo
      final logoBackgroundPaint = Paint()..color = Colors.white;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(logoOffset, logoOffset, logoSize, logoSize),
          const Radius.circular(16),
        ),
        logoBackgroundPaint,
      );

      // Draw logo background (app theme color)
      final logoPaint = Paint()..color = const Color(0xFF6366F1); // AppTheme.primaryColor
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(logoOffset + 4, logoOffset + 4, logoSize - 8, logoSize - 8),
          const Radius.circular(12),
        ),
        logoPaint,
      );

      // Draw walking icon (simplified)
      final iconPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const iconCenter = size / 2;
      
      // Draw simple walking figure
      // Head
      canvas.drawCircle(
        const Offset(iconCenter, iconCenter - 15),
        8,
        Paint()..color = Colors.white,
      );
      
      // Body
      canvas.drawLine(
        const Offset(iconCenter, iconCenter - 7),
        const Offset(iconCenter, iconCenter + 10),
        iconPaint,
      );
      
      // Arms
      canvas.drawLine(
        const Offset(iconCenter - 8, iconCenter - 2),
        const Offset(iconCenter + 8, iconCenter + 3),
        iconPaint,
      );
      
      // Legs
      canvas.drawLine(
        const Offset(iconCenter, iconCenter + 10),
        const Offset(iconCenter - 8, iconCenter + 20),
        iconPaint,
      );
      canvas.drawLine(
        const Offset(iconCenter, iconCenter + 10),
        const Offset(iconCenter + 8, iconCenter + 20),
        iconPaint,
      );

      // Convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e, stack) {
      await CrashlyticsService.recordQrError('generateQrCodeWithLogo', e, stack);
      print('Error generating QR code image: $e');
      return null;
    }
  }
}