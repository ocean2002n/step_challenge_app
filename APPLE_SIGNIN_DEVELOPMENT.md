# Apple Sign-In 開發配置指南

由於 Apple Sign-In 需要正確的 Provisioning Profile 和 App ID 配置，我們實施了條件性顯示策略來避開開發期間的配置問題。

## 當前狀態 ✅

### 自動偵測機制
- **智能顯示**: Apple Sign-In 按鈕會根據配置可用性自動顯示/隱藏
- **零錯誤**: 當配置不正確時，app 不會崩潰，只是不顯示 Apple 登入選項
- **向下兼容**: Google 登入和電子郵件註冊功能完全正常

### 代碼層面的保護
1. **SocialAuthService.isAppleSignInAvailable** - 動態檢查 Apple Sign-In 可用性
2. **條件性 UI 渲染** - 只在可用時顯示相關按鈕
3. **優雅降級** - 配置問題時自動回退到其他登入方式

## 測試建議 📱

### 開發環境測試
```bash
# 建置不會報錯，但 Apple Sign-In 按鈕會被隱藏
flutter build ios --debug --no-codesign
```

### 功能驗證
- ✅ Google 登入功能
- ✅ 電子郵件註冊流程  
- ✅ 語言本地化
- ✅ 日期格式化
- ⚠️ Apple Sign-In (僅在正確配置後可用)

## 重新啟用 Apple Sign-In 的步驟

### 1. 開發者帳號配置
1. 登入 [Apple Developer Console](https://developer.apple.com/account/)
2. 創建或更新 App ID，啟用 "Sign In with Apple"
3. 創建包含 Apple Sign-In 權限的 Provisioning Profile
4. 在 Xcode 中設定正確的 Team 和 Bundle ID

### 2. 修改 Entitlements
取消註釋 `ios/Runner/Runner.entitlements` 中的 Apple Sign-In 配置：

```xml
<!-- 從這個: -->
<!--
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
-->

<!-- 改為這個: -->
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

### 3. 在 Xcode 中配置
1. 開啟 `ios/Runner.xcworkspace`
2. 選擇 Runner target
3. 進入 "Signing & Capabilities" 
4. 添加 "Sign In with Apple" capability
5. 確認 Team 和 Bundle ID 正確

### 4. 驗證配置
```bash
# 清理並重新建置
flutter clean
flutter pub get
flutter build ios --debug

# 在實體設備上測試
flutter run --debug
```

## 常見問題排解 🔧

### 問題 1: "Provisioning profile doesn't include entitlement"
**原因**: Provisioning Profile 不包含 Apple Sign-In 權限
**解決**: 在 Apple Developer Console 重新生成包含 Apple Sign-In 的 Profile

### 問題 2: "Apple Sign-In 按鈕不顯示"
**原因**: 條件檢查失敗，可能是配置問題
**檢查**: 
```dart
// 在 console 中查看調試訊息
debugPrint('🍎 Apple Sign-In availability: $isAvailable');
```

### 問題 3: "Authentication failed"
**原因**: Bundle ID 不匹配或 nonce 問題
**解決**: 確認 Bundle ID 在代碼、Xcode 和 Developer Console 中一致

## 開發流程建議 📋

### 短期 (開發階段)
- 使用當前的條件性顯示機制
- 主要測試 Google 登入和電子郵件註冊
- Apple Sign-In 功能在模擬器中會自動隱藏

### 長期 (發布準備)
- 配置正確的 Apple Developer 帳號
- 重新啟用 Apple Sign-In entitlement
- 在實體設備上進行完整測試
- 確保 App Store Connect 配置正確

## 程式碼結構說明 🏗️

### 自動偵測邏輯
```dart
// SocialAuthService.dart
Future<bool> get isAppleSignInAvailable async {
  // 1. 檢查設備支援性
  // 2. 檢查配置正確性
  // 3. 捕獲權限錯誤
}
```

### UI 條件渲染
```dart
// SocialLoginScreen.dart
if (_isAppleSignInAvailable) ...[
  _buildAppleSignInButton(l10n),
]
```

這樣的設計確保：
- **開發期間**: 不會遇到配置錯誤
- **用戶體驗**: 沒有破損的功能
- **維護性**: 容易在準備好時重新啟用