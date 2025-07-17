import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_challenge_app/l10n/app_localizations.dart';
import '../utils/app_theme.dart';
import 'friend_qr_screen.dart';
import 'qr_scanner_screen.dart';

class ProfileScreenTest extends StatefulWidget {
  const ProfileScreenTest({super.key});

  @override
  State<ProfileScreenTest> createState() => _ProfileScreenTestState();
}

class _ProfileScreenTestState extends State<ProfileScreenTest> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _birthDate;
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _nicknameController.text = prefs.getString('nickname') ?? '';
        _selectedGender = prefs.getString('gender');
        _heightController.text = prefs.getDouble('height')?.toString() ?? '';
        _weightController.text = prefs.getDouble('weight')?.toString() ?? '';
        
        final birthDateString = prefs.getString('birthDate');
        if (birthDateString != null) {
          _birthDate = DateTime.parse(birthDateString);
        }
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  List<String> _getGenderOptions(AppLocalizations l10n) {
    return [l10n.male, l10n.female, l10n.other];
  }

  String? _getGenderKey(String displayName, AppLocalizations l10n) {
    if (displayName == l10n.male) return 'male';
    if (displayName == l10n.female) return 'female';
    if (displayName == l10n.other) return 'other';
    return null;
  }

  String? _getDisplayGender(String? key, AppLocalizations l10n) {
    if (key == 'male') return l10n.male;
    if (key == 'female') return l10n.female;
    if (key == 'other') return l10n.other;
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _avatarImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.imageSelectionError}: $e')),
        );
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: Localizations.localeOf(context),
    );
    
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        
        // Save basic profile data
        await prefs.setString('nickname', _nicknameController.text);
        if (_selectedGender != null) {
          await prefs.setString('gender', _selectedGender!);
        }
        if (_heightController.text.isNotEmpty) {
          await prefs.setDouble('height', double.parse(_heightController.text));
        }
        if (_weightController.text.isNotEmpty) {
          await prefs.setDouble('weight', double.parse(_weightController.text));
        }
        if (_birthDate != null) {
          await prefs.setString('birthDate', _birthDate!.toIso8601String());
        }

        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.personalProfileSaved)),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.saveFailed}: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // 如果本地化對象為空，顯示錯誤信息
    if (l10n == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Localization not available',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.personalProfile),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              l10n.save,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar selection
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _avatarImage != null 
                        ? FileImage(_avatarImage!) 
                        : null,
                    child: _avatarImage == null 
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[600],
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Nickname field
            TextFormField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: l10n.nickname,
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterNickname;
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Gender selection
            DropdownButtonFormField<String>(
              value: _getDisplayGender(_selectedGender, l10n),
              decoration: InputDecoration(
                labelText: l10n.gender,
                prefixIcon: const Icon(Icons.wc),
                border: const OutlineInputBorder(),
              ),
              items: _getGenderOptions(l10n).map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = _getGenderKey(newValue!, l10n);
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Birth date selection
            InkWell(
              onTap: _selectBirthDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.birthDate,
                  prefixIcon: const Icon(Icons.cake),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _birthDate != null
                      ? '${_birthDate!.year}年${_birthDate!.month}月${_birthDate!.day}日'
                      : l10n.pleaseSelectBirthDate,
                  style: TextStyle(
                    color: _birthDate != null ? Colors.black : Colors.grey[600],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Height and weight fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: InputDecoration(
                      labelText: l10n.height,
                      prefixIcon: const Icon(Icons.height),
                      border: const OutlineInputBorder(),
                      suffixText: 'cm',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final height = double.tryParse(value);
                        if (height == null || height <= 0 || height > 300) {
                          return l10n.enterValidHeight;
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: l10n.weight,
                      prefixIcon: const Icon(Icons.monitor_weight),
                      border: const OutlineInputBorder(),
                      suffixText: 'kg',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0 || weight > 500) {
                          return l10n.enterValidWeight;
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Friend sharing section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.addFriends,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FriendQrScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.qr_code),
                            label: Text(l10n.myQrCode),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const QrScannerScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.qr_code_scanner),
                            label: Text(l10n.scanQrCode),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Save button
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.savePersonalProfile,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}