import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/health_service.dart';
import '../services/social_auth_service.dart';
import '../l10n/app_localizations.dart';
import '../screens/home_screen.dart';
import '../screens/social_login_screen.dart';


class RegistrationScreen extends StatefulWidget {
  final int initialStep;
  final bool isSocialLogin;
  
  const RegistrationScreen({
    super.key,
    this.initialStep = 0,
    this.isSocialLogin = false,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PageController _pageController;
  final _nicknameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _emailController = TextEditingController();
  
  late int _currentStep;
  final int _totalSteps = 3;
  
  String? _selectedGender;
  DateTime? _birthDate;
  File? _avatarImage;
  bool _isLoading = false;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _pageController = PageController(initialPage: widget.initialStep);
    _loadSocialLoginData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadSocialLoginData() async {
    if (widget.isSocialLogin) {
      final authService = context.read<AuthService>();
      setState(() {
        _nicknameController.text = authService.nickname ?? '';
        _emailController.text = authService.email ?? '';
        // 不預填其他資料，讓用戶自己填寫
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _getBackButtonAction(),
        ),
        title: Text(
          l10n.createProfile,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(l10n),
                _buildPersonalDetailsStep(l10n),
                _buildPhysicalInfoStep(l10n),
                _buildHealthPermissionStep(l10n),
              ],
            ),
          ),
          
          // Bottom button
          _buildBottomButton(l10n),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isActive = index == _currentStep;
              
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index == _totalSteps - 1 ? 0 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? const Color(0xFF667eea)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            '${_currentStep + 1} / $_totalSteps',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.basicInformation,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.basicInformationSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Avatar selection
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(
                    color: const Color(0xFF667eea),
                    width: 2,
                  ),
                ),
                child: _avatarImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.file(
                          _avatarImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.grey[600],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.tapToAddPhoto,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Nickname field
          TextFormField(
            controller: _nicknameController,
            decoration: InputDecoration(
              labelText: l10n.nickname,
              hintText: l10n.enterNickname,
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterNickname;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.email,
              hintText: l10n.pleaseEnterEmail,
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterEmail;
              }
              if (!value.contains('@')) {
                return l10n.pleaseEnterValidEmail;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsStep(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.personalDetails,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.personalDetailsSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Gender selection
          Text(
            l10n.gender,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildGenderOption(l10n.male, 'male', Icons.male),
              const SizedBox(width: 12),
              _buildGenderOption(l10n.female, 'female', Icons.female),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Birth date
          Text(
            l10n.birthDate,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildBirthDateSelector(),
        ],
      ),
    );
  }

  Widget _buildPhysicalInfoStep(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.physicalInformation,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.physicalInformationSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Height
          TextFormField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.height,
              hintText: l10n.enterHeight,
              suffixText: 'cm',
              prefixIcon: const Icon(Icons.height),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pleaseEnterHeight;
              }
              final height = double.tryParse(value);
              if (height == null || height < 50 || height > 300) {
                return l10n.enterValidHeight;
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          // Weight
          TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.weight,
              hintText: l10n.enterWeight,
              suffixText: 'kg',
              prefixIcon: const Icon(Icons.monitor_weight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pleaseEnterWeight;
              }
              final weight = double.tryParse(value);
              if (weight == null || weight < 20 || weight > 500) {
                return l10n.enterValidWeight;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHealthPermissionStep(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.healthDataPermission,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.healthPermissionSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Health icon
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                size: 60,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            l10n.healthPermissionDescription,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String label, String value, IconData icon) {
    final isSelected = _selectedGender == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF667eea) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleNextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey[400],
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
              : Text(
                  _currentStep == _totalSteps - 1
                      ? l10n.completeRegistration
                      : l10n.next,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  void _handleNextStep() {
    if (_currentStep == _totalSteps - 1) {
      _completeRegistration();
    } else {
      _nextStep();
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  VoidCallback _getBackButtonAction() {
    // 對於社群登入用戶，在第二步（initialStep=1）時也應該能返回到社群登入頁面
    if (widget.isSocialLogin && _currentStep == widget.initialStep) {
      return _goBackToSocialLogin;
    }
    // 對於一般用戶，在第一步時返回到社群登入頁面
    else if (!widget.isSocialLogin && _currentStep == 0) {
      return _goBackToSocialLogin;
    }
    // 其他情況返回上一步
    else {
      return _previousStep;
    }
  }

  void _goBackToSocialLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SocialLoginScreen()),
    );
  }

  bool _validateCurrentStep() {
    final l10n = AppLocalizations.of(context)!;
    
    switch (_currentStep) {
      case 0: // Basic info
        if (_nicknameController.text.trim().isEmpty) {
          _showErrorSnackBar(l10n.pleaseEnterNickname);
          return false;
        }
        break;
      case 1: // Personal details
        if (_selectedGender == null) {
          _showErrorSnackBar(l10n.pleaseSelectGender);
          return false;
        }
        if (_birthDate == null) {
          _showErrorSnackBar(l10n.pleaseSelectBirthDate);
          return false;
        }
        break;
      case 2: // Physical info
        if (_heightController.text.isEmpty) {
          _showErrorSnackBar(l10n.pleaseEnterHeight);
          return false;
        }
        if (_weightController.text.isEmpty) {
          _showErrorSnackBar(l10n.pleaseEnterWeight);
          return false;
        }
        
        final height = double.tryParse(_heightController.text);
        if (height == null || height < 50 || height > 300) {
          _showErrorSnackBar(l10n.enterValidHeight);
          return false;
        }
        
        final weight = double.tryParse(_weightController.text);
        if (weight == null || weight < 20 || weight > 500) {
          _showErrorSnackBar(l10n.enterValidWeight);
          return false;
        }
        break;
    }
    return true;
  }

  void _completeRegistration() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validateCurrentStep()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = context.read<AuthService>();
      final healthService = context.read<HealthService>();
      
      if (widget.isSocialLogin) {
        // For social login users, complete the registration with additional info
        await authService.completeSocialLoginRegistration(
          gender: _selectedGender,
          birthDate: _birthDate,
          height: double.tryParse(_heightController.text),
          weight: double.tryParse(_weightController.text),
        );
      } else {
        // For email registration users
        await authService.registerUser(
          nickname: _nicknameController.text.trim(),
          email: _emailController.text.trim(),
          gender: _selectedGender!,
          birthDate: _birthDate!,
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
        );
      }
      
      // Complete onboarding for all users
      await authService.completeOnboarding();
      
      // Initialize health service
      await healthService.initialize();
      
      // Mark first launch as completed
      await authService.markFirstLaunchCompleted();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showErrorSnackBar('Registration failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _pickImage() async {
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
  }

  Widget _buildBirthDateSelector() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _selectBirthDateWithPicker,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.cake_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _birthDate != null
                            ? _formatBirthDate(_birthDate!)
                            : l10n.selectBirthDate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _birthDate != null ? Colors.black87 : Colors.grey[600],
                        ),
                      ),
                      if (_birthDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _getAgeText(_birthDate!),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatBirthDate(DateTime date) {
    final months = [
      '', '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'
    ];
    return '${date.year}年 ${months[date.month]} ${date.day}日';
  }

  String _getAgeText(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return '$age 歲';
  }

  void _selectBirthDateWithPicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (selectedDate != null) {
      setState(() {
        _birthDate = selectedDate;
      });
    }
  }
}