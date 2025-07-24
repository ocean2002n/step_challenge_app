import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:step_challenge_app/l10n/app_localizations.dart';
import '../services/friend_service.dart';
import '../services/deep_link_service.dart';
import '../utils/app_theme.dart';
import '../utils/qr_code_saver.dart';
import '../services/crashlytics_service.dart';

class FriendQrScreen extends StatefulWidget {
  const FriendQrScreen({super.key});

  @override
  State<FriendQrScreen> createState() => _FriendQrScreenState();
}

class _FriendQrScreenState extends State<FriendQrScreen> {
  String? _inviteCode;
  String? _inviteLink;

  @override
  void initState() {
    super.initState();
    _generateInviteData();
  }

  void _generateInviteData() {
    final friendService = context.read<FriendService>();
    setState(() {
      _inviteCode = friendService.generateInviteCode();
      _inviteLink = friendService.generateInviteLink();
    });
  }

  Future<void> _shareInviteLink() async {
    final l10n = AppLocalizations.of(context)!;
    final friendService = context.read<FriendService>();
    
    await CrashlyticsService.recordUserAction('share_invite_link');
    
    try {
      // 使用包含詳細說明的分享文字
      final shareText = friendService.generateShareableText();
      
      await Share.share(
        shareText,
        subject: l10n.friendInviteTitle,
      );
    } catch (e) {
      // Fallback to copying to clipboard if sharing fails
      final shareText = friendService.generateShareableText();
      await Clipboard.setData(ClipboardData(text: shareText));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.linkCopied} (分享失敗，已複製到剪貼簿)')),
        );
      }
    }
  }

  Future<void> _copyInviteLink() async {
    final l10n = AppLocalizations.of(context)!;
    await CrashlyticsService.recordUserAction('copy_invite_link');
    
    if (_inviteLink != null) {
      try {
        await Clipboard.setData(ClipboardData(text: _inviteLink!));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.linkCopied)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error copying: $e')),
          );
        }
      }
    }
  }

  // Save QR code to device gallery
  Future<void> _saveQrCodeToGallery() async {
    final l10n = AppLocalizations.of(context)!;
    await CrashlyticsService.recordUserAction('save_qr_code_to_gallery');
    
    if (_inviteLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.qrCodeDataUnavailable),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success = await QrCodeSaver.saveQrCodeToGallery(
        data: _inviteLink!,
        filename: 'StepChallenge_QR_${_inviteCode ?? 'code'}_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? l10n.qrCodeSavedSuccess : l10n.qrCodeSaveFailed,
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.saveError}: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // Build action button widget - LINE style
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: Colors.grey[700],
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(l10n.myQrCode),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
            
              // QR Code section - Redesigned
              if (_inviteCode != null) ...[
                // Main QR Code Container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.grey[50]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      // QR Code with app logo overlay - Clean design
                      Stack(
                        children: [
                          QrImageView(
                            data: _inviteLink ?? _inviteCode ?? '',
                            version: QrVersions.auto,
                            size: 280,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            errorCorrectionLevel: QrErrorCorrectLevel.H, // High error correction for logo overlay
                          ),
                          // App logo overlay in center
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.directions_walk,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
              // LINE-style action buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.shareQrCodeDescription,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons row - LINE style
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Copy link
                        _buildActionButton(
                          icon: Icons.link,
                          label: l10n.copyLink,
                          onTap: _copyInviteLink,
                        ),
                        
                        // Share
                        _buildActionButton(
                          icon: Icons.share,
                          label: l10n.share,
                          onTap: _shareInviteLink,
                        ),
                        
                        // Save QR code to gallery
                        _buildActionButton(
                          icon: Icons.download,
                          label: l10n.save,
                          onTap: _saveQrCodeToGallery,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Scan QR button
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/scan_qr');
                        },
                        icon: Icon(Icons.qr_code_scanner, size: 20, color: Colors.grey[700]),
                        label: Text(
                          l10n.scanQrCode,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}