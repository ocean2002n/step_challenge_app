# 健康步數挑戰 APP

一個使用 Flutter 開發的健康步數追蹤和挑戰應用程式，支援 Apple Health 和 Health Connect 整合，資料儲存於 Google Sheets。

## 🎯 主要功能

### 📱 健康資料整合
- 🏃‍♂️ 讀取 Apple Health (iOS) / Health Connect (Android) 步數資料
- 📊 每日步數追蹤和目標設定
- 📈 週週步數統計圖表
- 🎯 個人化目標進度追蹤

### 👥 社群挑戰
- 🏆 創建和參與步數挑戰活動
- 👫 邀請朋友組成挑戰群組
- 📊 即時挑戰進度更新
- 🎉 目標達成推播通知

### 💾 資料管理
- ☁️ Google Sheets 自動同步儲存
- 📱 支援多設備資料同步
- 🔒 安全的資料權限管理

### 🎨 用戶體驗
- 🌈 清新活潑的界面設計
- ✨ 流暢的動畫效果
- 🔔 智能推播提醒
- 📱 響應式設計

## 🏗️ 技術架構

### 前端框架
- **Flutter** - 跨平台開發框架
- **Provider** - 狀態管理
- **Material Design** - UI 設計系統

### 健康資料整合
- **health** ^10.2.0 - iOS HealthKit / Android Health Connect
- **permission_handler** - 權限管理

### 後端服務
- **Google Sheets API** - 資料儲存
- **Firebase** - 推播通知服務

### UI 組件
- **fl_chart** - 圖表顯示
- **flutter_animate** - 動畫效果
- **flutter_local_notifications** - 本地推播

## 📊 資料結構

### Google Sheets 表單設計

#### 1. users (用戶資料)
| 欄位 | 說明 |
|------|------|
| user_id | 用戶唯一識別碼 |
| name | 用戶姓名 |
| email | 用戶電子郵件 |
| daily_goal | 每日步數目標 |
| created_date | 註冊日期 |
| last_sync | 最後同步時間 |
| timezone | 時區設定 |

#### 2. daily_steps (每日步數)
| 欄位 | 說明 |
|------|------|
| user_id | 用戶識別碼 |
| date | 日期 |
| steps | 步數 |
| goal_achieved | 是否達成目標 |
| sync_timestamp | 同步時間戳 |
| device_type | 設備類型 |

#### 3. challenges (挑戰活動)
| 欄位 | 說明 |
|------|------|
| challenge_id | 挑戰識別碼 |
| title | 挑戰標題 |
| description | 挑戰描述 |
| creator_id | 創建者ID |
| start_date | 開始日期 |
| end_date | 結束日期 |
| goal_type | 目標類型 |
| goal_value | 目標數值 |
| status | 挑戰狀態 |
| created_date | 創建日期 |

#### 4. challenge_participants (挑戰參與者)
| 欄位 | 說明 |
|------|------|
| challenge_id | 挑戰識別碼 |
| user_id | 用戶識別碼 |
| joined_date | 加入日期 |
| current_progress | 當前進度 |
| is_completed | 是否完成 |
| completion_date | 完成日期 |

## 🚀 開始使用

### 環境需求
- Flutter SDK 3.24.5+
- Dart 3.1.0+
- iOS 12.0+ / Android API 26+

### 安裝步驟

1. **克隆專案**
   ```bash
   git clone https://github.com/yourusername/step_challenge_app.git
   cd step_challenge_app
   ```

2. **安裝依賴**
   ```bash
   flutter pub get
   ```

3. **設定 Google Sheets API**
   - 在 Google Cloud Console 創建專案
   - 啟用 Google Sheets API
   - 創建服務帳號並下載憑證
   - 更新 `lib/services/sheets_service.dart` 中的憑證資訊

4. **設定 Firebase**
   - 創建 Firebase 專案
   - 新增 iOS/Android 應用
   - 下載配置檔案：
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`

5. **運行應用**
   ```bash
   flutter run
   ```

### 權限設定

#### iOS (Info.plist)
```xml
<key>NSHealthShareUsageDescription</key>
<string>此應用需要讀取您的步數資料以追蹤運動進度和參與挑戰活動</string>
<key>NSHealthUpdateUsageDescription</key>
<string>此應用需要寫入健康資料以記錄您的運動成就</string>
```

#### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.health.READ_STEPS" />
<uses-permission android:name="android.permission.health.WRITE_STEPS" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## 🎨 UI 組件

### StepCounterCard
- 顯示今日步數和目標進度
- 漸變背景設計
- 動態進度條

### WeeklyChartCard  
- 7天步數柱狀圖
- 週統計資訊
- 互動式圖表

### GoalProgressCard
- 圓形進度指示器
- 目標完成狀態
- 鼓勵訊息

### ChallengeListCard
- 挑戰活動列表
- 進度追蹤
- 參與者管理

## 🔧 開發指南

### 專案結構
```
lib/
├── main.dart                 # 應用程式進入點
├── models/                   # 資料模型
│   ├── user_model.dart
│   ├── daily_steps_model.dart
│   └── challenge_model.dart
├── services/                 # 服務層
│   ├── health_service.dart
│   ├── sheets_service.dart
│   └── notification_service.dart
├── screens/                  # 畫面
│   └── home_screen.dart
├── widgets/                  # UI 組件
│   ├── step_counter_card.dart
│   ├── weekly_chart_card.dart
│   ├── goal_progress_card.dart
│   └── challenge_list_card.dart
└── utils/                    # 工具類
    └── app_theme.dart
```

### 狀態管理
使用 Provider 進行狀態管理：
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => HealthService()),
    ChangeNotifierProvider(create: (_) => SheetsService()),
    ChangeNotifierProvider(create: (_) => NotificationService()),
  ],
  child: MaterialApp(...),
)
```

## 🎯 未來計劃

- [ ] 支援更多健康指標 (心率、睡眠等)
- [ ] 加入社交功能 (好友、排行榜)
- [ ] 實作獎勵系統
- [ ] 支援穿戴裝置同步
- [ ] 多語言支援
- [ ] 深色模式

## 🤝 貢獻指南

歡迎提交 Issue 和 Pull Request！

1. Fork 專案
2. 創建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

## 📄 授權條款

此專案採用 MIT 授權條款 - 詳見 [LICENSE](LICENSE) 檔案

## 📞 聯絡資訊

如有問題或建議，歡迎聯絡：
- 📧 Email: your.email@example.com
- 💬 GitHub Issues: [提交問題](https://github.com/yourusername/step_challenge_app/issues)

---

### 🙏 致謝

感謝所有開源社群和套件維護者的貢獻！

---
*讓健康運動成為生活的一部分！ 🏃‍♀️💪*