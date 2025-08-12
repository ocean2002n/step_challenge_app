# Facebook 登入實作計劃

## 🎯 目標
在現有的 Step Challenge 應用程式中添加 Facebook 登入功能

## 📊 當前狀況
- ✅ 已有 Apple Sign-In
- ✅ Firebase Core 已設定
- ✅ 社群登入架構已建立
- ❌ 缺少 Facebook SDK

## 🚀 實作步驟

### 第一階段：環境準備 (預估時間：2-3小時)

#### 1.1 Facebook Developer 設定
- [ ] 註冊/登入 Facebook Developer Console
- [ ] 創建新的 Facebook App
- [ ] 設定 App Name: "Step Challenge"
- [ ] 選擇 "Consumer" 類型
- [ ] 添加 Facebook Login 產品
- [ ] 獲取 App ID 和 App Secret

#### 1.2 平台設定
**iOS 設定：**
- [ ] 添加 iOS Bundle ID: `com.example.stepChallengeApp`
- [ ] 設定 iOS App Store ID (如果有)
- [ ] 配置 Valid OAuth Redirect URIs

**Android 設定：**
- [ ] 添加 Android Package Name: `com.example.step_challenge_app`
- [ ] 上傳 Android Key Hash
- [ ] 設定 Class Name

### 第二階段：套件安裝 (預估時間：1小時)

#### 2.1 添加依賴套件 ✅
```yaml
# 在 pubspec.yaml 中添加
dependencies:
  flutter_facebook_auth: ^6.0.4
```

#### 2.2 iOS 平台設定 ✅
在 `ios/Runner/Info.plist` 添加：
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>fb-messenger-share-api</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fbYOUR_APP_ID</string>
        </array>
    </dict>
</array>
<key>FacebookAppID</key>
<string>YOUR_APP_ID</string>
<key>FacebookClientToken</key>
<string>YOUR_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>Step Challenge</string>
```

#### 2.3 Android 平台設定
在 `android/app/src/main/res/values/strings.xml` 添加：
```xml
<string name="facebook_app_id">YOUR_APP_ID</string>
<string name="fb_login_protocol_scheme">fbYOUR_APP_ID</string>
<string name="facebook_client_token">YOUR_CLIENT_TOKEN</string>
```

在 `android/app/src/main/AndroidManifest.xml` 添加：
```xml
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
<meta-data android:name="com.facebook.sdk.ClientToken" android:value="@string/facebook_client_token"/>
```

### 第三階段：程式碼實作 (預估時間：3-4小時)

#### 3.1 更新 SocialProvider 枚舉 ✅
```dart
enum SocialProvider { google, apple, facebook }
```

#### 3.2 實作 Facebook 登入服務 ✅
在 `social_auth_service_simplified.dart` 添加：
```dart
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

Future<SocialAuthResult> signInWithFacebook() async {
  try {
    final LoginResult result = await FacebookAuth.instance.login();
    
    if (result.status == LoginStatus.success) {
      final userData = await FacebookAuth.instance.getUserData();
      
      final account = LinkedAccount(
        provider: SocialProvider.facebook,
        id: userData['id'],
        email: userData['email'] ?? '',
        displayName: userData['name'] ?? '',
        photoUrl: userData['picture']?['data']?['url'],
      );
      
      return SocialAuthResult(success: true, account: account);
    } else {
      return SocialAuthResult(
        success: false, 
        error: 'Facebook 登入失敗: ${result.message}'
      );
    }
  } catch (e) {
    return SocialAuthResult(success: false, error: 'Facebook 登入錯誤: $e');
  }
}
```

#### 3.3 更新 UI 元件 ✅
在 `social_login_screen.dart` 添加 Facebook 登入按鈕：
```dart
Widget _buildFacebookSignInButton(AppLocalizations l10n) {
  return ElevatedButton(
    onPressed: _isLoading ? null : _signInWithFacebook,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1877F2),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.facebook, size: 20),
        const SizedBox(width: 12),
        Text(
          '使用 Facebook 註冊',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
```

### 第四階段：測試與驗證 (預估時間：2-3小時)

#### 4.1 功能測試
- [ ] 測試 Facebook 登入流程
- [ ] 驗證用戶資料獲取 (姓名、email、頭像)
- [ ] 測試錯誤處理 (用戶取消、網路錯誤)
- [ ] 測試已存在用戶的帳號連結

#### 4.2 平台測試
- [ ] iOS 實機測試
- [ ] Android 實機測試
- [ ] 檢查權限要求是否正確

#### 4.3 整合測試
- [ ] 與現有認證系統整合
- [ ] 確保不影響其他登入方式
- [ ] 測試登出功能

### 第五階段：上線準備 (預估時間：1-2小時)

#### 5.1 Facebook App Review
- [ ] 提交 Facebook App 審核 (如需要)
- [ ] 準備隱私政策更新
- [ ] 設定 App 為 Live 模式

#### 5.2 監控與分析
- [ ] 添加 Facebook 登入事件追蹤
- [ ] 設定錯誤監控
- [ ] 準備使用數據分析

## 🎯 成功指標
- [ ] Facebook 登入按鈕正常顯示
- [ ] 用戶可以成功使用 Facebook 帳號註冊/登入
- [ ] 用戶資料正確同步到應用程式
- [ ] 沒有破壞現有的登入功能
- [ ] 通過 Facebook 平台政策審核

## ⚠️ 注意事項
1. **隱私權限制**：只申請必要的權限 (public_profile, email)
2. **平台政策**：遵守 Facebook 開發者政策
3. **用戶體驗**：提供清楚的錯誤訊息和指引
4. **數據安全**：不儲存敏感的 Facebook 資料
5. **向後兼容**：確保現有用戶不受影響

## 🔗 相關文件
- [Facebook for Developers](https://developers.facebook.com/)
- [flutter_facebook_auth 套件文件](https://pub.dev/packages/flutter_facebook_auth)
- [Facebook Login 最佳實務](https://developers.facebook.com/docs/facebook-login/best-practices)

## 📅 預估時間表
- **總計**：9-13 小時
- **建議分配**：2-3 個工作天完成
- **優先級**：中等 (現有登入功能運作正常的情況下)