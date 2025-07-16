#!/bin/bash

echo "🔧 修復 iOS HealthKit 設定..."

# 移動到 iOS 目錄
cd ios

# 備份原始 project.pbxproj 檔案
cp Runner.xcodeproj/project.pbxproj Runner.xcodeproj/project.pbxproj.backup

# 使用 sed 來修改 project.pbxproj 文件
# 這是一個簡化的方法，在實際專案中建議使用 Xcode 手動設定

echo "📝 更新 project.pbxproj 文件..."

# 查找並添加 entitlements 文件到專案
if ! grep -q "Runner.entitlements" Runner.xcodeproj/project.pbxproj; then
    echo "   Adding entitlements file reference..."
    
    # 這裡需要手動在 Xcode 中添加
    echo "   ⚠️  需要在 Xcode 中手動添加 entitlements 文件"
    echo "   請按照 ios_setup_instructions.md 中的步驟進行設定"
else
    echo "   ✅ Entitlements file already referenced"
fi

# 檢查 Info.plist 中的健康權限
echo "📋 檢查 Info.plist 健康權限..."
if grep -q "NSHealthShareUsageDescription" Runner/Info.plist; then
    echo "   ✅ Health permissions found in Info.plist"
else
    echo "   ❌ Health permissions missing in Info.plist"
fi

# 檢查 entitlements 文件
echo "🔐 檢查 entitlements 文件..."
if [ -f "Runner/Runner.entitlements" ]; then
    echo "   ✅ Runner.entitlements exists"
    if grep -q "com.apple.developer.healthkit" Runner/Runner.entitlements; then
        echo "   ✅ HealthKit entitlement found"
    else
        echo "   ❌ HealthKit entitlement missing"
    fi
else
    echo "   ❌ Runner.entitlements file missing"
fi

echo ""
echo "🎯 下一步："
echo "1. 在 Xcode 中打開 ios/Runner.xcworkspace"
echo "2. 選擇 Runner target"
echo "3. 進入 Signing & Capabilities"
echo "4. 添加 HealthKit capability"
echo "5. 確認 Code Signing Entitlements 指向 Runner/Runner.entitlements"
echo ""
echo "📱 然後運行："
echo "flutter run debug_health.dart"

cd ..