# 重置應用程式狀態以查看完整動畫流程

## 方法 1：清除應用程式數據 (iOS 模擬器)
1. 在 iOS 模擬器中，長按應用程式圖標
2. 選擇「刪除 App」
3. 重新運行 `flutter run`

## 方法 2：清除應用程式數據 (Android)
1. 在設定中找到應用程式
2. 清除應用程式數據和緩存
3. 重新啟動應用程式

## 方法 3：修改代碼強制顯示歡迎頁面
在 `lib/main.dart` 的 `_getHomeScreen` 函數中，暫時修改：

```dart
Widget _getHomeScreen(AuthService authService) {
  // 強制顯示歡迎頁面以查看動畫
  return const WelcomeScreen();
  
  // 註釋掉原來的邏輯：
  // if (authService.isFirstLaunch) {
  //   return const WelcomeScreen();
  // }
  // if (!authService.isUserRegistered) {
  //   return const SocialLoginScreen();
  // }
  // return const HomeScreen();
}
```

完成測試後記得恢復原來的代碼。

## 動畫出現的順序
1. **WelcomeScreen** - CorporateHeroAnimation (背景跑步動畫)
2. **點擊「開始」** 
3. **SocialLoginScreen** - LoginBackgroundAnimation (浮動圖標動畫)