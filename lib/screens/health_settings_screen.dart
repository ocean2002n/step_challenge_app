import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/health_service.dart';
import '../l10n/app_localizations.dart';

class HealthSettingsScreen extends StatefulWidget {
  const HealthSettingsScreen({super.key});

  @override
  State<HealthSettingsScreen> createState() => _HealthSettingsScreenState();
}

class _HealthSettingsScreenState extends State<HealthSettingsScreen> {
  bool _autoSyncEnabled = true;
  bool _heartRateSyncEnabled = true;
  bool _workoutSyncEnabled = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final healthService = context.watch<HealthService>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Apple 健康',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black87),
            onPressed: () {
              // 顯示更多選項
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Apple Health 連接狀態
            _buildConnectionStatus(healthService),
            
            const SizedBox(height: 30),
            
            // 同步設定區域
            _buildSyncSettings(l10n, healthService),
            
            const SizedBox(height: 30),
            
            // 說明文字
            _buildDescriptionText(),
            
            const SizedBox(height: 30),
            
            // 操作按鈕
            _buildActionButtons(l10n, healthService),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(HealthService healthService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apple 健康',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  healthService.isAuthorized ? '已連接' : '未連接',
                  style: TextStyle(
                    fontSize: 14,
                    color: healthService.isAuthorized ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: healthService.isAuthorized ? Colors.green : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              healthService.isAuthorized ? '已連接' : '未連接',
              style: TextStyle(
                color: healthService.isAuthorized ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSettings(AppLocalizations l10n, HealthService healthService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '同步設置',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          
          // 自動上傳數據
          _buildSyncToggle(
            title: '自動上傳數據',
            subtitle: '開啟後，「Apple 健康」同步至 Keep 的數據將自動上傳並保存至 Keep 服務器。你可以在「數據中心」中查看與管理已上傳的數據。',
            value: _autoSyncEnabled,
            onChanged: (value) {
              setState(() {
                _autoSyncEnabled = value;
              });
            },
          ),
          
          const Divider(height: 1),
          
          // 同步心率
          _buildSyncToggle(
            title: '同步心率',
            subtitle: '開啟後，「Apple 健康」所支持的心率設備將支持在訓練過程中實時同步心率數據。若你希望使用相關心率設備，請確保「Keep 對於 Apple 健康的心率讀取授權」已開啟。',
            value: _heartRateSyncEnabled,
            onChanged: (value) {
              setState(() {
                _heartRateSyncEnabled = value;
              });
            },
          ),
          
          const Divider(height: 1),
          
          // 同步運動數據
          _buildSyncToggle(
            title: '同步運動數據',
            subtitle: '開啟後，將同步運動和體能訓練數據、跑步和行走距離、身高體重以及步數等數據。',
            value: _workoutSyncEnabled,
            onChanged: (value) {
              setState(() {
                _workoutSyncEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSyncToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF4CAF50),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '同步說明',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '連接「健康」後，Keep 會與健康中心同步你的訓練數據、跑步和行走距離、身高體重以及步數等數據。',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '在這之後，你也可以進入「健康」的數據來源，來選擇是否同步 Keep 數據到「健康」。',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n, HealthService healthService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 立即同步按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _syncHealthData(healthService),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '立即同步健康數據',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 重新授權按鈕
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => _reauthorizeHealth(healthService),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '重新授權健康數據',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncHealthData(HealthService healthService) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await healthService.syncHealthData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  '健康數據同步完成！今日步數：${healthService.todaySteps}',
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text('同步失敗：$e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reauthorizeHealth(HealthService healthService) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await healthService.forceReauthorizeAndSync();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(success ? '重新授權成功！' : '重新授權失敗，請檢查健康應用設定'),
              ],
            ),
            backgroundColor: success ? const Color(0xFF4CAF50) : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text('重新授權失敗：$e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}