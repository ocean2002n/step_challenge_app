import 'package:flutter/foundation.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/daily_steps_model.dart';
import '../models/challenge_model.dart';

class SheetsService extends ChangeNotifier {
  static const String _spreadsheetId = 'YOUR_SPREADSHEET_ID'; // 需要替換
  static const List<String> _scopes = [SheetsApi.spreadsheetsScope];
  
  SheetsApi? _sheetsApi;
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;

  /// 初始化 Google Sheets API
  Future<bool> initialize() async {
    try {
      // 服務帳號認證 (需要在 assets 中放置 service-account.json)
      final accountCredentials = ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "YOUR_PROJECT_ID",
        "private_key_id": "YOUR_PRIVATE_KEY_ID", 
        "private_key": "YOUR_PRIVATE_KEY",
        "client_email": "YOUR_CLIENT_EMAIL",
        "client_id": "YOUR_CLIENT_ID",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
      });

      final httpClient = await clientViaServiceAccount(accountCredentials, _scopes);
      _sheetsApi = SheetsApi(httpClient);
      _isInitialized = true;
      
      // 初始化工作表結構
      await _initializeSheets();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Sheets initialization error: $e');
      return false;
    }
  }

  /// 初始化 Google Sheets 結構
  Future<void> _initializeSheets() async {
    try {
      // 檢查並創建必要的工作表
      await _ensureSheetExists('users', [
        'user_id', 'name', 'email', 'daily_goal', 'created_date', 'last_sync', 'timezone'
      ]);
      
      await _ensureSheetExists('daily_steps', [
        'user_id', 'date', 'steps', 'goal_achieved', 'sync_timestamp', 'device_type'
      ]);
      
      await _ensureSheetExists('challenges', [
        'challenge_id', 'title', 'description', 'creator_id', 'start_date', 
        'end_date', 'goal_type', 'goal_value', 'status', 'created_date'
      ]);
      
      await _ensureSheetExists('challenge_participants', [
        'challenge_id', 'user_id', 'joined_date', 'current_progress', 
        'is_completed', 'completion_date'
      ]);
    } catch (e) {
      debugPrint('Error initializing sheets: $e');
    }
  }

  /// 確保工作表存在，如不存在則創建
  Future<void> _ensureSheetExists(String sheetName, List<String> headers) async {
    try {
      // 檢查工作表是否存在
      final spreadsheet = await _sheetsApi!.spreadsheets.get(_spreadsheetId);
      final sheetExists = spreadsheet.sheets?.any((sheet) => 
          sheet.properties?.title == sheetName) ?? false;

      if (!sheetExists) {
        // 創建新工作表
        final addSheetRequest = AddSheetRequest()
          ..properties = (SheetProperties()..title = sheetName);
        
        final batchUpdateRequest = BatchUpdateSpreadsheetRequest()
          ..requests = [Request()..addSheet = addSheetRequest];
        
        await _sheetsApi!.spreadsheets.batchUpdate(batchUpdateRequest, _spreadsheetId);
        
        // 添加標題行
        await _appendRow(sheetName, headers);
      }
    } catch (e) {
      debugPrint('Error ensuring sheet exists: $e');
    }
  }

  /// 新增用戶
  Future<bool> addUser(User user) async {
    try {
      final values = [
        user.id,
        user.name,
        user.email,
        user.dailyGoal.toString(),
        user.createdDate.toIso8601String(),
        user.lastSync.toIso8601String(),
        user.timezone,
      ];
      
      return await _appendRow('users', values);
    } catch (e) {
      debugPrint('Error adding user: $e');
      return false;
    }
  }

  /// 更新用戶資料
  Future<bool> updateUser(User user) async {
    try {
      // 找到用戶行並更新
      final userRow = await _findRowByValue('users', 0, user.id);
      if (userRow == -1) return false;

      final values = [
        user.id,
        user.name,
        user.email,
        user.dailyGoal.toString(),
        user.createdDate.toIso8601String(),
        user.lastSync.toIso8601String(),
        user.timezone,
      ];

      return await _updateRow('users', userRow, values);
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  /// 新增每日步數記錄
  Future<bool> addDailySteps(DailySteps dailySteps) async {
    try {
      final values = [
        dailySteps.userId,
        dailySteps.date.toIso8601String().split('T')[0],
        dailySteps.steps.toString(),
        dailySteps.goalAchieved.toString(),
        dailySteps.syncTime.toIso8601String(),
        dailySteps.deviceType,
      ];
      
      return await _appendRow('daily_steps', values);
    } catch (e) {
      debugPrint('Error adding daily steps: $e');
      return false;
    }
  }

  /// 批次新增步數記錄
  Future<bool> addMultipleDailySteps(List<DailySteps> stepsList) async {
    try {
      List<List<Object?>> allValues = [];
      
      for (DailySteps steps in stepsList) {
        allValues.add([
          steps.userId,
          steps.date.toIso8601String().split('T')[0],
          steps.steps.toString(),
          steps.goalAchieved.toString(),
          steps.syncTime.toIso8601String(),
          steps.deviceType,
        ]);
      }
      
      return await _appendMultipleRows('daily_steps', allValues);
    } catch (e) {
      debugPrint('Error adding multiple daily steps: $e');
      return false;
    }
  }

  /// 創建挑戰
  Future<bool> createChallenge(Challenge challenge) async {
    try {
      final values = [
        challenge.id,
        challenge.title,
        challenge.description,
        challenge.creatorId,
        challenge.startDate.toIso8601String().split('T')[0],
        challenge.endDate.toIso8601String().split('T')[0],
        challenge.goalType.name,
        challenge.goalValue.toString(),
        challenge.status.name,
        challenge.createdDate.toIso8601String(),
      ];
      
      return await _appendRow('challenges', values);
    } catch (e) {
      debugPrint('Error creating challenge: $e');
      return false;
    }
  }

  /// 加入挑戰
  Future<bool> joinChallenge(ChallengeParticipant participant) async {
    try {
      final values = [
        participant.challengeId,
        participant.userId,
        participant.joinedDate.toIso8601String().split('T')[0],
        participant.currentProgress.toString(),
        participant.isCompleted.toString(),
        participant.completionDate?.toIso8601String().split('T')[0] ?? '',
      ];
      
      return await _appendRow('challenge_participants', values);
    } catch (e) {
      debugPrint('Error joining challenge: $e');
      return false;
    }
  }

  /// 通用方法：新增單行
  Future<bool> _appendRow(String sheetName, List<Object?> values) async {
    try {
      final valueRange = ValueRange()
        ..values = [values];
      
      await _sheetsApi!.spreadsheets.values.append(
        valueRange,
        _spreadsheetId,
        '$sheetName!A:Z',
        valueInputOption: 'RAW',
      );
      
      return true;
    } catch (e) {
      debugPrint('Error appending row: $e');
      return false;
    }
  }

  /// 通用方法：批次新增多行
  Future<bool> _appendMultipleRows(String sheetName, List<List<Object?>> values) async {
    try {
      final valueRange = ValueRange()
        ..values = values;
      
      await _sheetsApi!.spreadsheets.values.append(
        valueRange,
        _spreadsheetId,
        '$sheetName!A:Z',
        valueInputOption: 'RAW',
      );
      
      return true;
    } catch (e) {
      debugPrint('Error appending multiple rows: $e');
      return false;
    }
  }

  /// 通用方法：更新特定行
  Future<bool> _updateRow(String sheetName, int row, List<Object?> values) async {
    try {
      final valueRange = ValueRange()
        ..values = [values];
      
      await _sheetsApi!.spreadsheets.values.update(
        valueRange,
        _spreadsheetId,
        '$sheetName!A$row:Z$row',
        valueInputOption: 'RAW',
      );
      
      return true;
    } catch (e) {
      debugPrint('Error updating row: $e');
      return false;
    }
  }

  /// 通用方法：根據值查找行號
  Future<int> _findRowByValue(String sheetName, int columnIndex, String value) async {
    try {
      final response = await _sheetsApi!.spreadsheets.values.get(
        _spreadsheetId,
        '$sheetName!A:Z',
      );
      
      final values = response.values ?? [];
      
      for (int i = 0; i < values.length; i++) {
        if (values[i].length > columnIndex && values[i][columnIndex] == value) {
          return i + 1; // Google Sheets 行號從 1 開始
        }
      }
      
      return -1; // 未找到
    } catch (e) {
      debugPrint('Error finding row: $e');
      return -1;
    }
  }
}