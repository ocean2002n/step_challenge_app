import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/challenge_model.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../utils/app_theme.dart';
import '../utils/date_formatter.dart';

class CreateChallengeScreen extends StatefulWidget {
  final Challenge? challenge;
  
  const CreateChallengeScreen({super.key, this.challenge});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalValueController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  ChallengeGoalType _selectedGoalType = ChallengeGoalType.daily;
  ChallengePrivacyType _selectedPrivacy = ChallengePrivacyType.public;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  
  bool _isEditing = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final authService = context.read<AuthService>();
    _currentUserId = authService.userId;
    _nameController.text = authService.nickname ?? '';
    _emailController.text = authService.email ?? '';
    
    if (widget.challenge != null) {
      _isEditing = true;
      final challenge = widget.challenge!;
      _titleController.text = challenge.title;
      _descriptionController.text = challenge.description;
      _goalValueController.text = challenge.goalValue.toString();
      _selectedGoalType = challenge.goalType;
      _selectedPrivacy = challenge.privacy;
      _startDate = challenge.startDate;
      _endDate = challenge.endDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _goalValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = !_isEditing || 
        (_isEditing && widget.challenge?.creatorId == _currentUserId);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '編輯挑戰' : '創建新挑戰'),
        actions: [
          if (canEdit)
            TextButton(
              onPressed: _saveChallenge,
              child: Text(
                _isEditing ? '更新' : '創建',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!canEdit)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '只有挑戰創建者可以編輯此挑戰',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              
              _buildSection(
                title: '基本資訊',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      enabled: canEdit,
                      decoration: const InputDecoration(
                        labelText: '挑戰標題',
                        hintText: '為你的挑戰取個響亮的名字',
                        prefixIcon: Icon(Icons.emoji_events_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入挑戰標題';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: canEdit,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '挑戰描述',
                        hintText: '詳細描述你的挑戰內容和規則',
                        prefixIcon: Icon(Icons.description_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入挑戰描述';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '姓名',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入姓名';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入Email';
                        }
                        if (!value.contains('@')) {
                          return '請輸入有效的Email';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: '挑戰類型',
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: ChallengeGoalType.values.asMap().entries.map((entry) {
                          final index = entry.key;
                          final type = entry.value;
                          return Column(
                            children: [
                              RadioListTile<ChallengeGoalType>(
                                title: Text(_getGoalTypeLabel(type)),
                                subtitle: Text(_getGoalTypeDescription(type)),
                                value: type,
                                groupValue: _selectedGoalType,
                                onChanged: canEdit ? (value) {
                                  setState(() {
                                    _selectedGoalType = value!;
                                  });
                                } : null,
                              ),
                              if (index < ChallengeGoalType.values.length - 1)
                                const Divider(height: 1),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: '目標設定',
                child: TextFormField(
                  controller: _goalValueController,
                  enabled: canEdit,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '目標數值',
                    hintText: _getGoalHint(),
                    suffixText: _getGoalUnit(),
                    prefixIcon: const Icon(Icons.flag_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入目標數值';
                    }
                    if (int.tryParse(value) == null) {
                      return '請輸入有效的數字';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: '時間設定',
                child: Column(
                  children: [
                    InkWell(
                      onTap: canEdit ? () => _selectDate(context, true) : null,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '開始日期',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _formatDate(_startDate),
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: canEdit ? () => _selectDate(context, false) : null,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '結束日期',
                          prefixIcon: Icon(Icons.event),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _formatDate(_endDate),
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: '隱私設定',
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<ChallengePrivacyType>(
                            title: const Text('公開'),
                            subtitle: const Text('所有人都可以看到和加入此挑戰'),
                            value: ChallengePrivacyType.public,
                            groupValue: _selectedPrivacy,
                            onChanged: canEdit ? (value) {
                              setState(() {
                                _selectedPrivacy = value!;
                              });
                            } : null,
                          ),
                          const Divider(height: 1),
                          RadioListTile<ChallengePrivacyType>(
                            title: const Text('私人'),
                            subtitle: const Text('只有受邀請的人可以看到和加入此挑戰'),
                            value: ChallengePrivacyType.private,
                            groupValue: _selectedPrivacy,
                            onChanged: canEdit ? (value) {
                              setState(() {
                                _selectedPrivacy = value!;
                              });
                            } : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              if (canEdit)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChallenge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _isEditing ? '更新挑戰' : '創建挑戰',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    
                    if (_isEditing) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showDeleteConfirmation,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            '刪除挑戰',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }
  
  String _getGoalTypeLabel(ChallengeGoalType type) {
    switch (type) {
      case ChallengeGoalType.daily:
        return '每日目標';
      case ChallengeGoalType.total:
        return '總計目標';
      case ChallengeGoalType.duration:
        return '持續時間';
    }
  }
  
  String _getGoalTypeDescription(ChallengeGoalType type) {
    switch (type) {
      case ChallengeGoalType.daily:
        return '每天都要達到指定的步數';
      case ChallengeGoalType.total:
        return '在挑戰期間累計達到指定的總步數';
      case ChallengeGoalType.duration:
        return '連續達成目標的天數';
    }
  }
  
  String _getGoalHint() {
    switch (_selectedGoalType) {
      case ChallengeGoalType.daily:
        return '例如：10000';
      case ChallengeGoalType.total:
        return '例如：100000';
      case ChallengeGoalType.duration:
        return '例如：7';
    }
  }
  
  String _getGoalUnit() {
    switch (_selectedGoalType) {
      case ChallengeGoalType.daily:
      case ChallengeGoalType.total:
        return '步';
      case ChallengeGoalType.duration:
        return '天';
    }
  }
  
  String _formatDate(DateTime date) {
    final localeService = context.read<LocaleService>();
    return DateFormatter.formatBirthDate(date, localeService.locale);
  }
  
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }
  
  void _saveChallenge() {
    if (_formKey.currentState!.validate()) {
      final goalValue = int.parse(_goalValueController.text);
      
      if (_isEditing) {
        _updateChallenge(goalValue);
      } else {
        _createChallenge(goalValue);
      }
    }
  }
  
  void _createChallenge(int goalValue) {
    final challenge = Challenge(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      creatorId: _currentUserId ?? 'anonymous',
      startDate: _startDate,
      endDate: _endDate,
      goalType: _selectedGoalType,
      goalValue: goalValue,
      status: ChallengeStatus.active,
      createdDate: DateTime.now(),
      privacy: _selectedPrivacy,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('挑戰 "${challenge.title}" 創建成功！'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    
    Navigator.pop(context, challenge);
  }
  
  void _updateChallenge(int goalValue) {
    final updatedChallenge = widget.challenge!.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      goalValue: goalValue,
      goalType: _selectedGoalType,
      privacy: _selectedPrivacy,
      startDate: _startDate,
      endDate: _endDate,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('挑戰 "${updatedChallenge.title}" 更新成功！'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    
    Navigator.pop(context, updatedChallenge);
  }
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('刪除挑戰'),
          ],
        ),
        content: Text('確定要刪除挑戰「${widget.challenge!.title}」嗎？此操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteChallenge();
            },
            child: const Text(
              '刪除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  void _deleteChallenge() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('挑戰「${widget.challenge!.title}」已刪除'),
        backgroundColor: Colors.red,
      ),
    );
    
    Navigator.pop(context, 'deleted');
  }
}