# iOS HealthKit 設定指南

## 問題分析
你的 Flutter 應用無法存取健康數據，原因是：
1. ✅ Info.plist 已正確設置健康數據權限描述
2. ✅ 已創建 Runner.entitlements 文件
3. ❌ Xcode 專案沒有正確引用 entitlements 文件

## 修復步驟

### 1. 在 Xcode 中手動設定 (推薦)
1. 打開 `ios/Runner.xcworkspace`
2. 選擇 Runner 專案
3. 選擇 Runner Target
4. 點擊 "Signing & Capabilities" 標籤
5. 點擊 "+ Capability" 按鈕
6. 搜索並添加 "HealthKit"
7. 確認 "Code Signing Entitlements" 欄位指向 `Runner/Runner.entitlements`

### 2. 或者使用指令行 (快速修復)
```bash
# 在 ios 目錄下執行
cd ios
# 使用 PlistBuddy 添加 entitlements 引用
/usr/libexec/PlistBuddy -c "Add :com.apple.developer.healthkit bool true" Runner/Runner.entitlements
```

### 3. 驗證設定
運行以下命令來驗證設定：
```bash
flutter run debug_health.dart
```

### 4. 重新建置專案
```bash
flutter clean
flutter pub get
cd ios
pod install
```

## 注意事項
- 確保使用實體設備測試（模擬器可能不支援某些健康功能）
- 在 iOS 設定中確認應用已獲得健康數據權限
- 如果仍有問題，檢查 iOS 系統日誌以獲取更多錯誤信息

## 測試步驟
1. 運行應用
2. 點擊首頁的 "同步數據" 按鈕
3. 檢查控制台輸出中的調試信息
4. 到設定 → 健康數據權限檢查權限狀態