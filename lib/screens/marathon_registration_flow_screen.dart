import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/marathon_model.dart';
import '../services/marathon_service.dart';
import '../services/auth_service.dart';
import '../widgets/phone_number_field.dart';
import '../widgets/birth_date_field.dart';
import 'terms_conditions_screen.dart';

enum RegistrationStep { information, payment }
enum PaymentMethod { creditCard, abaPayment }

class MarathonRegistrationFlowScreen extends StatefulWidget {
  final String eventId;
  final String raceId;

  const MarathonRegistrationFlowScreen({
    super.key,
    required this.eventId,
    required this.raceId,
  });

  @override
  State<MarathonRegistrationFlowScreen> createState() =>
      _MarathonRegistrationFlowScreenState();
}

class _MarathonRegistrationFlowScreenState
    extends State<MarathonRegistrationFlowScreen> {
  RegistrationStep _currentStep = RegistrationStep.information;
  PaymentMethod? _selectedPaymentMethod;
  bool _agreedToTerms = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  String? _selectedGender;
  DateTime? _birthDate;
  String? _selectedNationality;
  String? _selectedEmergencyContactRelation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authService = context.read<AuthService>();
    // 預設帶入用戶個人資訊
    _nameController.text = authService.nickname ?? '';
    _phoneController.text = '';
    _emailController.text = authService.email ?? '';
    _idNumberController.text = '';
    _selectedGender = authService.gender;
    _birthDate = authService.birthDate;
    _selectedNationality = null;
    _emergencyContactNameController.text = '';
    _emergencyContactPhoneController.text = '';
    _selectedEmergencyContactRelation = null;
    _medicalHistoryController.text = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idNumberController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final marathonService = context.read<MarathonService>();
    final event = marathonService.getEventById(widget.eventId);
    final race = event?.races.firstWhere((r) => r.id == widget.raceId);

    if (event == null || race == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.registerForRace)),
        body: Center(child: Text(l10n.registrationFailed)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStep == RegistrationStep.information
            ? l10n.registrationStep1
            : l10n.registrationStep2),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildStepIndicator(l10n),
          Expanded(
            child: _currentStep == RegistrationStep.information
                ? _buildInformationStep(l10n, event, race)
                : _buildPaymentStep(l10n, event, race),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepCircle(1, _currentStep.index >= 0, true),
          Expanded(child: _buildStepLine(_currentStep.index >= 1)),
          _buildStepCircle(2, _currentStep.index >= 1, false),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int stepNumber, bool isActive, bool isCompleted) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
      ),
      child: Center(
        child: isCompleted && _currentStep.index > 0
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : Text(
                stepNumber.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      height: 2,
      color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildInformationStep(
      AppLocalizations l10n, MarathonEvent event, MarathonRace race) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 參賽者基本資訊
            Text(
              l10n.participantName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.nickname,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterParticipantName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 性別
            Text(
              l10n.gender,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'male', child: Text(l10n.male)),
                DropdownMenuItem(value: 'female', child: Text(l10n.female)),
                DropdownMenuItem(value: 'other', child: Text(l10n.other)),
              ],
              onChanged: (value) => setState(() => _selectedGender = value),
              validator: (value) {
                if (value == null) return l10n.pleaseSelectGender;
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 出生日期
            BirthDateField(
              selectedDate: _birthDate,
              labelText: l10n.birthDate,
              onDateSelected: (date) => setState(() => _birthDate = date),
              minimumAge: 10,
            ),
            const SizedBox(height: 16),

            // 聯絡資訊
            PhoneNumberField(
              initialValue: _phoneController.text,
              labelText: l10n.phoneNumber,
              onChanged: (value) => _phoneController.text = value,
            ),
            const SizedBox(height: 16),

            Text(
              l10n.email,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // 身份證號
            Text(
              l10n.idNumber,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _idNumberController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 緊急聯絡人
            Text(
              l10n.emergencyContact,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emergencyContactNameController,
              decoration: InputDecoration(
                labelText: l10n.emergencyContactName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emergencyContactPhoneController,
              decoration: InputDecoration(
                labelText: l10n.emergencyContactPhone,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // 醫療資訊
            Text(
              l10n.medicalInformation,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _medicalHistoryController,
              decoration: InputDecoration(
                labelText: l10n.medicalHistory,
                hintText: l10n.medicalHistoryHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // 條款與條件
            if (event.termsAndConditions != null) ...[
              Text(
                l10n.termsAndConditions,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) =>
                          setState(() => _agreedToTerms = value ?? false),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showTermsAndConditions(event),
                        child: Text(
                          l10n.iAgreeToTerms,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 繼續按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canProceedToPayment() ? _proceedToPayment : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  l10n.proceedToPayment,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep(
      AppLocalizations l10n, MarathonEvent event, MarathonRace race) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 付款金額資訊
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.blue[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.paymentAmount,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      race.getDistanceText(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      'USD \${race.currentFee.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                if (race.isEarlyBirdPeriod && race.earlyBirdFee != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.earlyBird} (${l10n.regularPrice}: USD \${race.entryFee.toStringAsFixed(2)})',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 選擇付款方式
          Text(
            l10n.selectPaymentMethod,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          _buildPaymentMethodOption(
            l10n.creditCard,
            Icons.credit_card,
            PaymentMethod.creditCard,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodOption(
            l10n.abaPayment,
            Icons.account_balance,
            PaymentMethod.abaPayment,
          ),
          const SizedBox(height: 32),

          // 付款按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedPaymentMethod != null ? _processPayment : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                l10n.makePayment,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
      String title, IconData icon, PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  bool _canProceedToPayment() {
    if (_nameController.text.isEmpty) return false;
    if (_selectedGender == null) return false;
    if (_birthDate == null) return false;
    // 如果有條款與條件，必須同意
    final marathonService = context.read<MarathonService>();
    final event = marathonService.getEventById(widget.eventId);
    if (event?.termsAndConditions != null && !_agreedToTerms) return false;
    return true;
  }

  void _proceedToPayment() {
    setState(() => _currentStep = RegistrationStep.payment);
  }

  void _processPayment() {
    // 模擬付款處理
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // 模擬付款延遲
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // 關閉loading
        _showPaymentResult(true); // 模擬成功
      }
    });
  }

  void _showPaymentResult(bool success) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(success ? l10n.paymentSuccessful : l10n.paymentFailed),
          ],
        ),
        content: Text(
          success ? l10n.registrationCompleted : l10n.registrationFailed,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 關閉dialog
              Navigator.pop(context); // 返回詳情頁
              if (success) {
                Navigator.pop(context); // 返回活動列表
              }
            },
            child: Text(success ? l10n.backToEvents : l10n.cancel),
          ),
        ],
      ),
    );
  }


  void _showTermsAndConditions(MarathonEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TermsConditionsScreen(
          title: event.name,
          content: event.termsAndConditions!,
        ),
      ),
    );
  }
}