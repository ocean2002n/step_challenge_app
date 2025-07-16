#!/usr/bin/env python3
"""
自動修復 Xcode 專案的 entitlements 引用
"""

import re
import os

def fix_xcode_entitlements():
    project_file = "ios/Runner.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_file):
        print("❌ 找不到 project.pbxproj 文件")
        return False
    
    print("🔧 正在修復 Xcode 專案的 entitlements 引用...")
    
    # 讀取專案文件
    with open(project_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 檢查是否已經有 CODE_SIGN_ENTITLEMENTS 設定
    if 'CODE_SIGN_ENTITLEMENTS' in content:
        print("✅ 專案已經有 entitlements 設定")
        return True
    
    # 查找 buildSettings 區域並添加 entitlements 引用
    # 尋找 Debug 和 Release 的 buildSettings
    pattern = r'(buildSettings = \{[^}]*)(PRODUCT_BUNDLE_IDENTIFIER[^}]*)'
    
    def add_entitlements(match):
        build_settings = match.group(1)
        rest = match.group(2)
        
        # 添加 CODE_SIGN_ENTITLEMENTS
        entitlements_line = '\t\t\t\tCODE_SIGN_ENTITLEMENTS = "Runner/Runner.entitlements";\n'
        
        return build_settings + entitlements_line + '\t\t\t\t' + rest
    
    # 替換內容
    new_content = re.sub(pattern, add_entitlements, content)
    
    if new_content != content:
        # 備份原始文件
        backup_file = project_file + '.backup'
        with open(backup_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        # 寫入修改後的內容
        with open(project_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print("✅ 已成功添加 entitlements 引用")
        print(f"📄 原始文件已備份為: {backup_file}")
        return True
    else:
        print("❌ 無法找到適當的位置插入 entitlements 引用")
        return False

if __name__ == "__main__":
    success = fix_xcode_entitlements()
    if success:
        print("\n🎉 修復完成！")
        print("請執行以下命令來測試：")
        print("1. flutter clean")
        print("2. flutter pub get")
        print("3. flutter build ios --debug --no-codesign")
    else:
        print("\n⚠️  自動修復失敗，請手動在 Xcode 中添加 HealthKit capability")