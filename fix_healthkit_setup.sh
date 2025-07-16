#!/bin/bash

echo "🏥 修復 HealthKit 配置..."
echo "================================"

# 移動到 iOS 目錄
cd ios

echo "1. 檢查 Info.plist 健康權限..."
if grep -q "NSHealthShareUsageDescription" Runner/Info.plist; then
    echo "   ✅ NSHealthShareUsageDescription 已存在"
else
    echo "   ❌ NSHealthShareUsageDescription 缺失"
fi

if grep -q "NSHealthUpdateUsageDescription" Runner/Info.plist; then
    echo "   ✅ NSHealthUpdateUsageDescription 已存在"
else
    echo "   ❌ NSHealthUpdateUsageDescription 缺失"
fi

echo ""
echo "2. 檢查 entitlements 文件..."
if [ -f "Runner/Runner.entitlements" ]; then
    echo "   ✅ Runner.entitlements 存在"
    if grep -q "com.apple.developer.healthkit" Runner/Runner.entitlements; then
        echo "   ✅ HealthKit entitlement 已配置"
    else
        echo "   ❌ HealthKit entitlement 缺失"
    fi
else
    echo "   ❌ Runner.entitlements 文件不存在"
fi

echo ""
echo "3. 檢查 Xcode 專案設定..."
if grep -q "CODE_SIGN_ENTITLEMENTS" Runner.xcodeproj/project.pbxproj; then
    echo "   ✅ 專案已引用 entitlements 文件"
else
    echo "   ❌ 專案沒有引用 entitlements 文件"
    echo "   ⚠️  需要在 Xcode 中手動添加 HealthKit capability"
fi

echo ""
echo "4. 檢查 Bundle Identifier..."
BUNDLE_ID=$(grep -o 'PRODUCT_BUNDLE_IDENTIFIER = [^;]*' Runner.xcodeproj/project.pbxproj | head -1 | sed 's/PRODUCT_BUNDLE_IDENTIFIER = //' | sed 's/;//')
echo "   Bundle ID: $BUNDLE_ID"

echo ""
echo "🔧 修復步驟："
echo "================================"
echo "1. 打開 Xcode："
echo "   open Runner.xcworkspace"
echo ""
echo "2. 在 Xcode 中："
echo "   - 選擇 Runner project"
echo "   - 選擇 Runner target"
echo "   - 點擊 'Signing & Capabilities' 標籤"
echo "   - 點擊 '+ Capability' 按鈕"
echo "   - 搜索並添加 'HealthKit'"
echo "   - 確認 'Code Signing Entitlements' 指向 Runner/Runner.entitlements"
echo ""
echo "3. 清理並重新建置："
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter build ios --debug --no-codesign"
echo ""
echo "4. 在實體設備上測試："
echo "   flutter run -d <device_id>"
echo ""
echo "5. 檢查 Apple Health："
echo "   設定 → 隱私與安全性 → 健康 → 數據存取與裝置"
echo "   你的 APP 應該會出現在這裡"

cd ..