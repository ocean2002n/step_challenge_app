import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  /// 根據當前語言環境格式化日期
  static String formatBirthDate(DateTime date, Locale locale) {
    final languageCode = locale.languageCode;
    
    switch (languageCode) {
      case 'zh':
        // 中文格式：2024年 3月 15日
        final months = [
          '', '一月', '二月', '三月', '四月', '五月', '六月',
          '七月', '八月', '九月', '十月', '十一月', '十二月'
        ];
        return '${date.year}年 ${months[date.month]} ${date.day}日';
      
      case 'km':
        // 高棉語格式：15 មីនា 2024
        final months = [
          '', 'មករា', 'កុម្ភៈ', 'មីនា', 'មេសា', 'ឧសភា', 'មិថុនា',
          'កក្កដា', 'សីហា', 'កញ្ញា', 'តុលា', 'វិច្ឆិកា', 'ធ្នូ'
        ];
        return '${date.day} ${months[date.month]} ${date.year}';
      
      default:
        // 英文和其他語言使用系統預設格式
        return DateFormat.yMMMd(locale.toString()).format(date);
    }
  }
  
  /// 獲取年齡文字
  static String getAgeText(DateTime birthDate, Locale locale) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    final languageCode = locale.languageCode;
    
    switch (languageCode) {
      case 'zh':
        return '$age 歲';
      case 'km':
        return '$age ឆ្នាំ';
      default:
        return '$age years old';
    }
  }
  
  /// 格式化時間顯示
  static String formatTime(DateTime time, Locale locale) {
    return DateFormat.Hm(locale.toString()).format(time);
  }
  
  /// 格式化完整日期時間
  static String formatDateTime(DateTime dateTime, Locale locale) {
    return DateFormat.yMd(locale.toString()).add_jm().format(dateTime);
  }
  
  /// 格式化相對時間（今天、昨天等）
  static String formatRelativeDate(DateTime date, Locale locale) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;
    
    final languageCode = locale.languageCode;
    
    if (difference == 0) {
      // 今天
      switch (languageCode) {
        case 'zh':
          return '今天';
        case 'km':
          return 'ថ្ងៃនេះ';
        default:
          return 'Today';
      }
    } else if (difference == 1) {
      // 昨天
      switch (languageCode) {
        case 'zh':
          return '昨天';
        case 'km':
          return 'ម្សិលមិញ';
        default:
          return 'Yesterday';
      }
    } else if (difference < 7) {
      // 本週內
      return DateFormat.EEEE(locale.toString()).format(date);
    } else {
      // 超過一週
      return DateFormat.MMMd(locale.toString()).format(date);
    }
  }
}