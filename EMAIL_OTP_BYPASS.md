# Email OTP 驗證繞過功能

## 🔓 測試用的驗證碼繞過

為了方便開發和測試，現在已經添加了一個特殊的驗證碼：

### 🎯 如何使用

1. **進入 Email OTP 驗證畫面**
2. **輸入 6 個 0：`000000`**
3. **點擊驗證按鈕**
4. **✅ 系統會直接驗證通過**

### 📋 操作步驟

1. 在註冊或登入流程中，當需要輸入 email 驗證碼時
2. 在 6 個輸入框中分別輸入：`0` `0` `0` `0` `0` `0`
3. 點擊「驗證」按鈕
4. 系統會顯示驗證成功，直接進入下一步

### 🛠️ 技術細節

- 修改了 `lib/services/email_otp_service.dart` 中的 `verifyOTP` 方法
- 當輸入的 OTP 為 `"000000"` 時，會繞過正常驗證邏輯
- 在 debug 模式下會顯示：`🔓 DEBUG: OTP bypass used for [email] (000000)`
- 這個功能只在開發階段使用，上線前需要移除

### ⚠️ 重要提醒

- 這只是**臨時的開發測試功能**
- 在正式上線前**必須移除**這個繞過邏輯
- 正常的 OTP 驗證功能依然正常運作

### 🔄 如何移除 (上線前)

在 `lib/services/email_otp_service.dart` 文件中，移除以下代碼：

```dart
// Debug/Test bypass: Allow "000000" to pass verification
if (inputOtp == '000000') {
  _otpCache.remove(email);
  await _saveOtpCache();
  
  if (kDebugMode) {
    print('🔓 DEBUG: OTP bypass used for $email (000000)');
  }
  
  return OtpResult(success: true);
}
```

### 🧪 測試場景

現在你可以測試：
1. **註冊流程** - 輸入 email → 收到驗證碼畫面 → 輸入 000000 → 繼續註冊
2. **登入流程** - 輸入 email → 收到驗證碼畫面 → 輸入 000000 → 登入成功
3. **密碼重設** - 輸入 email → 收到驗證碼畫面 → 輸入 000000 → 重設密碼