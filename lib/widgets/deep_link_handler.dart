import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/deep_link_service.dart';
import '../services/friend_service.dart';
import '../screens/qr_scanner_screen.dart';

class DeepLinkHandler extends StatefulWidget {
  final Widget child;
  final DeepLinkService deepLinkService;

  const DeepLinkHandler({
    super.key,
    required this.child,
    required this.deepLinkService,
  });

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  StreamSubscription<String>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _listenForDeepLinks();
  }

  void _listenForDeepLinks() {
    _linkSubscription = widget.deepLinkService.linkStream.listen((String link) {
      _handleDeepLink(link);
    });
  }

  void _handleDeepLink(String link) {
    final inviteCode = widget.deepLinkService.parseInviteCodeFromLink(link);
    if (inviteCode != null && mounted) {
      _processInviteCode(inviteCode);
    }
  }

  Future<void> _processInviteCode(String inviteCode) async {
    try {
      final friendService = context.read<FriendService>();
      final success = await friendService.addFriendByInviteCode(inviteCode);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend added successfully from invite link!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to friends tab
          Navigator.pushReplacementNamed(context, '/');
        } else {
          // Show error and navigate to QR scanner for manual entry
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid invite code. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QrScannerScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error processing invite link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}