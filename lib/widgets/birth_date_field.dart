import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';
import '../utils/date_formatter.dart';

class BirthDateField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  final String? labelText;
  final String? errorText;
  final bool enabled;
  final int minimumAge;

  const BirthDateField({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
    this.labelText,
    this.errorText,
    this.enabled = true,
    this.minimumAge = 10,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: enabled ? () => _selectBirthDate(context) : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
              errorText: errorText,
              enabled: enabled,
            ),
            child: Consumer<LocaleService>(
              builder: (context, localeService, child) {
                return Text(
                  selectedDate != null
                      ? DateFormatter.formatBirthDate(selectedDate!, localeService.locale)
                      : l10n.selectBirthDate,
                  style: TextStyle(
                    color: selectedDate != null 
                      ? (enabled ? null : Colors.grey) 
                      : Colors.grey[600],
                  ),
                );
              },
            ),
          ),
        ),
        if (selectedDate != null) ...[
          const SizedBox(height: 4),
          Consumer<LocaleService>(
            builder: (context, localeService, child) {
              return Text(
                DateFormatter.getAgeText(selectedDate!, localeService.locale),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    
    // 計算最大允許日期（最小年齡限制）
    final maxAllowedDate = DateTime(
      now.year - minimumAge,
      now.month,
      now.day,
    );

    // 設定初始日期
    final initialDate = selectedDate != null 
      ? (selectedDate!.isAfter(maxAllowedDate) ? maxAllowedDate : selectedDate!)
      : DateTime(now.year - 20); // 預設20歲

    try {
      final selectedDateResult = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900), // 最早可選1900年
        lastDate: maxAllowedDate, // 最晚日期考慮最小年齡限制
        helpText: '選擇出生日期',
        cancelText: l10n.cancel,
        confirmText: l10n.confirm,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Theme.of(context).primaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedDateResult != null) {
        // 驗證日期
        final validationError = _validateBirthDate(selectedDateResult, context);
        if (validationError == null) {
          onDateSelected(selectedDateResult);
        } else {
          // 顯示錯誤訊息
          _showErrorDialog(context, validationError);
        }
      }
    } catch (e) {
      debugPrint('Error selecting birth date: $e');
    }
  }

  String? _validateBirthDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    
    // 檢查是否為未來日期
    if (date.isAfter(now)) {
      return '生日不能是未來日期';
    }
    
    // 檢查年齡是否滿足最小年齡要求
    final age = _calculateAge(date);
    if (age < minimumAge) {
      return '年齡不得小於 $minimumAge 歲';
    }
    
    // 檢查是否過於久遠（超過150歲）
    if (age > 150) {
      return '請選擇有效的出生日期';
    }
    
    return null;
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    // 如果今年的生日還沒到，年齡減1
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  void _showErrorDialog(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('輸入錯誤'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  static String? validateBirthDate(DateTime? date, {int minimumAge = 10}) {
    if (date == null) return '請選擇出生日期';
    
    final now = DateTime.now();
    
    // 檢查是否為未來日期
    if (date.isAfter(now)) {
      return '生日不能是未來日期';
    }
    
    // 計算年齡
    int age = now.year - date.year;
    if (now.month < date.month || 
        (now.month == date.month && now.day < date.day)) {
      age--;
    }
    
    // 檢查年齡限制
    if (age < minimumAge) {
      return '年齡不得小於 $minimumAge 歲';
    }
    
    if (age > 150) {
      return '請選擇有效的出生日期';
    }
    
    return null;
  }
}