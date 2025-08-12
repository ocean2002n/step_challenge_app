import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:step_challenge_app/l10n/app_localizations.dart';
import '../widgets/phone_number_field.dart';
import '../widgets/birth_date_field.dart';
import '../widgets/linked_accounts_widget.dart';
import '../services/auth_service.dart';
import '../services/social_auth_service_simplified.dart';
import '../utils/app_theme.dart';
import 'friend_qr_screen.dart';
import 'qr_scanner_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _birthDate;
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  String _selectedNationality = 'Cambodia';
  String _selectedEmergencyRelation = 'parent';
  bool _emergencyContactExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authService = context.read<AuthService>();
      setState(() {
        _nicknameController.text = prefs.getString('nickname') ?? '';
        _selectedGender = prefs.getString('gender');
        _heightController.text = prefs.getDouble('height')?.toString() ?? '';
        _weightController.text = prefs.getDouble('weight')?.toString() ?? '';
        _idController.text = prefs.getString('idNumber') ?? '';
        _phoneController.text = prefs.getString('phoneNumber') ?? '';
        _emailController.text = prefs.getString('email') ?? '';
        _emergencyNameController.text = prefs.getString('emergencyName') ?? '';
        _emergencyPhoneController.text = prefs.getString('emergencyPhone') ?? '';
        _selectedNationality = prefs.getString('nationality') ?? 'Cambodia';
        _nationalityController.text = _selectedNationality;
        _selectedEmergencyRelation = prefs.getString('emergencyRelation') ?? 'parent';
        _medicalHistoryController.text = prefs.getString('medicalHistory') ?? '';
        
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
    return [l10n.male, l10n.female];
  }
  
  List<String> _getNationalityOptions() {
    return [
      'Cambodia',
      'Thailand', 
      'Vietnam',
      'Laos',
      'Myanmar',
      'Singapore',
      'Malaysia',
      'Indonesia',
      'Philippines',
      'Taiwan',
      'China',
      'Japan',
      'Korea',
      'USA',
      'Other'
    ];
  }
  
  List<String> _getEmergencyRelationOptions() {
    return [
      'parent',
      'spouse',
      'sibling',
      'child',
      'friend',
      'colleague',
      'other'
    ];
  }
  
  String _getRelationDisplayName(String relation, AppLocalizations l10n) {
    switch (relation) {
      case 'parent': return l10n.relationParent;
      case 'spouse': return l10n.relationSpouse;
      case 'sibling': return l10n.relationSibling;
      case 'child': return l10n.relationChild;
      case 'friend': return l10n.relationFriend;
      case 'colleague': return l10n.relationColleague;
      case 'other': return l10n.relationOther;
      default: return relation;
    }
  }
  
  Future<void> _showNationalityPicker() async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return _NationalityPickerDialog(
          currentNationality: _nationalityController.text,
          nationalities: _getNationalityOptions(),
          l10n: AppLocalizations.of(context)!,
        );
      },
    );
    
    if (result != null) {
      setState(() {
        _nationalityController.text = result;
        _selectedNationality = result;
      });
    }
  }

  String? _getGenderKey(String displayName, AppLocalizations l10n) {
    if (displayName == l10n.male) return 'male';
    if (displayName == l10n.female) return 'female';
    return null;
  }

  String? _getDisplayGender(String? key, AppLocalizations l10n) {
    if (key == 'male') return l10n.male;
    if (key == 'female') return l10n.female;
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
        await prefs.setString('idNumber', _idController.text);
        await prefs.setString('phoneNumber', _phoneController.text);
        await prefs.setString('email', _emailController.text);
        await prefs.setString('emergencyName', _emergencyNameController.text);
        await prefs.setString('emergencyPhone', _emergencyPhoneController.text);
        await prefs.setString('nationality', _nationalityController.text);
        await prefs.setString('emergencyRelation', _selectedEmergencyRelation);
        await prefs.setString('medicalHistory', _medicalHistoryController.text);

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
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      final profilePhotoUrl = authService.profilePhotoUrl;
                      
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _avatarImage != null 
                            ? FileImage(_avatarImage!) as ImageProvider
                            : (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty)
                                ? NetworkImage(profilePhotoUrl) as ImageProvider
                                : null,
                        child: (_avatarImage == null && (profilePhotoUrl == null || profilePhotoUrl.isEmpty))
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[600],
                              )
                            : null,
                      );
                    },
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
            BirthDateField(
              selectedDate: _birthDate,
              labelText: l10n.birthDate,
              onDateSelected: (date) => setState(() => _birthDate = date),
              minimumAge: 10,
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
            
            const SizedBox(height: 16),
            
            // ID Number field
            TextFormField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: l10n.idNumber,
                prefixIcon: const Icon(Icons.badge_outlined),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty && value.length < 5) {
                  return l10n.validIdRequired;
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Nationality field
            InkWell(
              onTap: _showNationalityPicker,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.nationality,
                  prefixIcon: const Icon(Icons.flag),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _nationalityController.text.isEmpty ? l10n.selectNationality : _nationalityController.text,
                  style: TextStyle(
                    color: _nationalityController.text.isEmpty ? Colors.grey[600] : Colors.black87,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Phone number field
            PhoneNumberField(
              initialValue: _phoneController.text,
              labelText: l10n.phoneNumber,
              onChanged: (value) => _phoneController.text = value,
              validator: (value) {
                // 手機號碼為必填
                if (value == null || value.isEmpty) {
                  return l10n.phoneNumberRequired;
                }
                if (!RegExp(r'^[+]?[0-9]{8,15}$').hasMatch(value)) {
                  return l10n.validPhoneRequired;
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                // email 為必填
                if (value == null || value.isEmpty) {
                  return l10n.emailRequired;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return l10n.validEmailRequired;
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Medical History field
            TextFormField(
              controller: _medicalHistoryController,
              decoration: InputDecoration(
                labelText: l10n.medicalHistory,
                hintText: l10n.medicalHistoryHint,
                prefixIcon: const Icon(Icons.medical_services_outlined),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Emergency Contact Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _emergencyContactExpanded = !_emergencyContactExpanded;
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emergency,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.emergencyContact,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _emergencyContactExpanded 
                                ? Icons.expand_less 
                                : Icons.expand_more,
                          ),
                        ],
                      ),
                    ),
                    if (_emergencyContactExpanded) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emergencyNameController,
                        decoration: InputDecoration(
                          labelText: l10n.emergencyContactName,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emergencyPhoneController,
                        decoration: InputDecoration(
                          labelText: l10n.emergencyContactPhone,
                          prefixIcon: const Icon(Icons.phone_in_talk),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^[+]?[0-9]{8,15}$').hasMatch(value)) {
                              return l10n.validPhoneRequired;
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedEmergencyRelation,
                        decoration: InputDecoration(
                          labelText: l10n.emergencyContactRelation,
                          prefixIcon: const Icon(Icons.family_restroom),
                          border: const OutlineInputBorder(),
                        ),
                        items: _getEmergencyRelationOptions().map((String relation) {
                          return DropdownMenuItem<String>(
                            value: relation,
                            child: Text(_getRelationDisplayName(relation, l10n)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedEmergencyRelation = newValue!;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Linked accounts section
            const LinkedAccountsWidget(),
            
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
    _idController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _nationalityController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }
}

class _NationalityPickerDialog extends StatefulWidget {
  final String currentNationality;
  final List<String> nationalities;
  final AppLocalizations l10n;

  const _NationalityPickerDialog({
    required this.currentNationality,
    required this.nationalities,
    required this.l10n,
  });

  @override
  State<_NationalityPickerDialog> createState() => _NationalityPickerDialogState();
}

class _NationalityPickerDialogState extends State<_NationalityPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredNationalities = [];

  @override
  void initState() {
    super.initState();
    _filteredNationalities = List.from(widget.nationalities);
    _searchController.addListener(_filterNationalities);
  }

  void _filterNationalities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNationalities = widget.nationalities
          .where((nationality) => nationality.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n.selectNationalityDialog),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: widget.l10n.searchNationality,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredNationalities.length,
                itemBuilder: (context, index) {
                  final nationality = _filteredNationalities[index];
                  final isSelected = nationality == widget.currentNationality;
                  
                  return ListTile(
                    title: Text(nationality),
                    leading: isSelected 
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      Navigator.of(context).pop(nationality);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.l10n.cancel),
        ),
      ],
    );
  }
}