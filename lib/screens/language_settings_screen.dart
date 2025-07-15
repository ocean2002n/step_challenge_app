import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_challenge_app/l10n/app_localizations.dart';
import '../services/locale_service.dart';
import '../utils/app_theme.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeService = context.watch<LocaleService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSettings),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.selectLanguage,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _buildLanguageTile(
                  context,
                  languageCode: 'en',
                  languageName: l10n.english,
                  nativeName: 'English',
                  isSelected: localeService.isCurrentLanguage('en'),
                  onTap: () => _changeLanguage(context, 'en'),
                ),
                const Divider(height: 1),
                _buildLanguageTile(
                  context,
                  languageCode: 'zh',
                  languageName: l10n.traditionalChinese,
                  nativeName: '繁體中文',
                  isSelected: localeService.isCurrentLanguage('zh'),
                  onTap: () => _changeLanguage(context, 'zh'),
                ),
                const Divider(height: 1),
                _buildLanguageTile(
                  context,
                  languageCode: 'km',
                  languageName: l10n.khmer,
                  nativeName: 'ខ្មែរ',
                  isSelected: localeService.isCurrentLanguage('km'),
                  onTap: () => _changeLanguage(context, 'km'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.restartRequired,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String languageCode,
    required String languageName,
    required String nativeName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey[300],
        child: Text(
          languageCode.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(languageName),
      subtitle: Text(
        nativeName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: AppTheme.primaryColor,
            )
          : const Icon(Icons.circle_outlined),
      onTap: onTap,
    );
  }

  Future<void> _changeLanguage(BuildContext context, String languageCode) async {
    final localeService = context.read<LocaleService>();
    final l10n = AppLocalizations.of(context)!;
    
    if (!localeService.isCurrentLanguage(languageCode)) {
      await localeService.setLanguage(languageCode);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.restartRequired),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}