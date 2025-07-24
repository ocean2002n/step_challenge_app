import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/social_auth_service.dart';
import '../utils/app_theme.dart';
import '../l10n/app_localizations.dart';

class LinkedAccountsWidget extends StatefulWidget {
  const LinkedAccountsWidget({super.key});

  @override
  State<LinkedAccountsWidget> createState() => _LinkedAccountsWidgetState();
}

class _LinkedAccountsWidgetState extends State<LinkedAccountsWidget> {
  bool _isAppleSignInAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAppleSignInAvailability();
  }

  Future<void> _checkAppleSignInAvailability() async {
    try {
      final socialAuthService = context.read<SocialAuthService>();
      final isAvailable = await socialAuthService.isAppleSignInAvailable;
      
      if (mounted) {
        setState(() {
          _isAppleSignInAvailable = isAvailable;
        });
      }
    } catch (e) {
      debugPrint('Error checking Apple Sign-In availability: $e');
      if (mounted) {
        setState(() {
          _isAppleSignInAvailable = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<SocialAuthService>(
      builder: (context, socialAuthService, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.link,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.linkedAccounts,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Google Account
                _buildAccountRow(
                  context: context,
                  provider: SocialProvider.google,
                  socialAuthService: socialAuthService,
                  l10n: l10n,
                ),
                
                // 條件性顯示 Apple Account
                if (_isAppleSignInAvailable) ...[
                  const SizedBox(height: 12),
                  _buildAccountRow(
                    context: context,
                    provider: SocialProvider.apple,
                    socialAuthService: socialAuthService,
                    l10n: l10n,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountRow({
    required BuildContext context,
    required SocialProvider provider,
    required SocialAuthService socialAuthService,
    required AppLocalizations l10n,
  }) {
    final account = socialAuthService.getAccountByProvider(provider);
    final isLinked = account != null;
    
    return Row(
      children: [
        // Provider icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getProviderColor(provider).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: _getProviderIcon(provider),
          ),
        ),
        const SizedBox(width: 12),
        
        // Account info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                socialAuthService.getProviderDisplayName(provider),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (isLinked) ...[
                Text(
                  account.email ?? account.displayName ?? l10n.linked,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                Text(
                  l10n.notLinked,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Action button
        if (isLinked) ...[
          TextButton(
            onPressed: () => _showUnlinkDialog(context, provider, socialAuthService),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.unlink),
          ),
        ] else ...[
          ElevatedButton(
            onPressed: () => _linkAccount(context, provider, socialAuthService),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getProviderColor(provider),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(l10n.link),
          ),
        ],
      ],
    );
  }

  Widget _getProviderIcon(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return SvgPicture.asset(
          'assets/images/google_g_logo.svg',
          width: 24,
          height: 24,
        );
      case SocialProvider.apple:
        return const Icon(
          Icons.apple,
          color: Colors.black,
          size: 24,
        );
    }
  }

  Color _getProviderColor(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return Colors.red;
      case SocialProvider.apple:
        return Colors.black;
    }
  }

  Future<void> _linkAccount(
    BuildContext context,
    SocialProvider provider,
    SocialAuthService socialAuthService,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      SocialAuthResult result;
      
      if (provider == SocialProvider.google) {
        result = await socialAuthService.signInWithGoogle();
      } else {
        result = await socialAuthService.signInWithApple();
      }
      
      if (result.success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${socialAuthService.getProviderDisplayName(provider)} ${l10n.accountLinkedSuccessfully}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? l10n.linkFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.linkError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showUnlinkDialog(
    BuildContext context,
    SocialProvider provider,
    SocialAuthService socialAuthService,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unlink),
        content: Text('${l10n.confirmUnlinkAccount} ${socialAuthService.getProviderDisplayName(provider)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.unlink),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await socialAuthService.unlinkAccount(provider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? '${socialAuthService.getProviderDisplayName(provider)} ${l10n.accountUnlinkedSuccessfully}'
                : l10n.unlinkFailed
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}