# Deep Link 分享功能實作指南

## 🎯 新的實作方案

### ✅ 用戶ID簡化
- **原格式**: 8位隨機字符 (ABCD1234)
- **新格式**: 5位隨機字符 (ABC12)
- **邀請碼**: 直接使用用戶ID，無需額外時間戳

### 📱 Deep Link 格式
```
stepchallenge://invite?code=ABC12
```

### 🔄 分享流程優化

#### 分享文字模板
```
🚶 加入我的 Step Challenge 好友！

📱 點擊連結加入：stepchallenge://invite?code=ABC12

🔍 手動輸入邀請碼：ABC12

一起來挑戰每日步數目標吧！🎯
```

## 🛠 技術實作細節

### 1. 用戶ID生成 (FriendService)
```dart
String _generateUserId() {
  final random = Random();
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
}
```

### 2. 邀請碼生成
```dart
String generateInviteCode() {
  if (_currentUserId == null) return '';
  return _currentUserId!; // 直接使用用戶ID
}
```

### 3. Deep Link 生成
```dart
String generateDeepLink() {
  final inviteCode = generateInviteCode();
  return 'stepchallenge://invite?code=$inviteCode';
}
```

### 4. 邀請碼解析與驗證
```dart
String? parseInviteCode(String inviteCode) {
  final cleanCode = inviteCode.trim().toUpperCase();
  
  // 驗證格式：5位英數字符
  if (cleanCode.length == 5 && RegExp(r'^[A-Z0-9]{5}$').hasMatch(cleanCode)) {
    return cleanCode;
  }
  return null;
}
```

## 📱 iOS 深度連結配置

### Info.plist 設定
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>stepchallenge.deeplink</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>stepchallenge</string>
    </array>
  </dict>
</array>
```

### URL Scheme 處理
- **Scheme**: `stepchallenge://`
- **Path**: `invite`
- **參數**: `code=ABC12`

## 🧪 測試功能

### Debug 模式測試
在 debug 模式下，好友QR頁面會顯示「測試深度連結」按鈕：
- 驗證 deep link 格式正確性
- 測試邀請碼解析邏輯
- 檢查分享文字格式

### 測試流程
1. **生成測試**
   - 檢查用戶ID長度 (5位)
   - 驗證字符格式 (A-Z, 0-9)
   - 確認邀請碼 = 用戶ID

2. **Deep Link 測試**
   - URL格式: `stepchallenge://invite?code=ABC12`
   - 解析測試: 提取正確的邀請碼
   - 驗證測試: 格式驗證通過

3. **分享測試**
   - 分享到各種app (WhatsApp, Line, 簡訊)
   - 複製連結功能
   - 手動輸入功能

## 🔄 用戶體驗流程

### 發送邀請
1. 打開「我的QR碼」
2. 點擊「分享邀請連結」
3. 選擇分享到任何app
4. 朋友收到包含deep link的訊息

### 接收邀請
**方法1: 點擊連結** (主要方式)
1. 朋友點擊 `stepchallenge://invite?code=ABC12`
2. 自動開啟Step Challenge app
3. 自動處理邀請碼並添加好友

**方法2: 手動輸入** (備用方式)
1. 打開app → 添加好友 → 掃描QR碼
2. 點擊「手動輸入邀請碼」
3. 輸入5位邀請碼 (ABC12)

## 🎯 優勢分析

### ✅ 簡化設計
- **更短的邀請碼**: 5位 vs 8位+時間戳
- **更簡潔的URL**: 減少複雜性
- **更好記憶**: 用戶可以口頭分享

### ✅ 技術優勢
- **解析效率**: 直接驗證格式
- **儲存效率**: 更少的數據
- **網路效率**: 更短的URL

### ✅ 用戶體驗
- **一鍵分享**: Deep link 直接開啟app
- **多重備用**: 手動輸入、QR掃描
- **清楚指示**: 分享文字包含完整說明

## 🔧 故障排除

### 常見問題

**1. Deep Link 無法開啟app**
- 檢查 iOS URL Scheme 註冊
- 確認app已安裝
- 嘗試手動輸入邀請碼

**2. 邀請碼格式錯誤**
- 必須是5位英數字符
- 自動轉換為大寫
- 移除空白字符

**3. 重複添加好友**
- 系統會自動檢測重複
- 顯示適當錯誤訊息
- 不會產生重複條目

### Debug 工具
- 在debug模式下使用「測試深度連結」按鈕
- 檢查console log輸出
- 驗證邀請碼解析邏輯

## 🚀 實作狀態

- ✅ 用戶ID簡化 (8位 → 5位)
- ✅ 邀請碼優化 (移除時間戳)
- ✅ Deep Link 生成與解析
- ✅ 分享功能整合
- ✅ 手動輸入備用方案
- ✅ Debug 測試工具
- ✅ iOS 建置成功

現在好友分享功能使用簡潔的deep link方案，提供最佳的用戶體驗！🎉