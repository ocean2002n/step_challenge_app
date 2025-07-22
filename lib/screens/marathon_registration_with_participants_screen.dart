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

enum RegistrationStep { participantSelection, information, payment }
enum PaymentMethod { creditCard, abaPayment }

class ParticipantData {
  String name;
  String email;
  String? phone;
  String? gender;
  DateTime? birthDate;
  String? idNumber;
  String? emergencyContactName;
  String? emergencyContactPhone;
  String? emergencyContactRelation;
  String? medicalHistory;

  ParticipantData({
    this.name = '',
    this.email = '',
    this.phone,
    this.gender,
    this.birthDate,
    this.idNumber,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.medicalHistory,
  });
}

class MarathonRegistrationWithParticipantsScreen extends StatefulWidget {
  final String eventId;
  final String raceId;

  const MarathonRegistrationWithParticipantsScreen({
    super.key,
    required this.eventId,
    required this.raceId,
  });

  @override
  State<MarathonRegistrationWithParticipantsScreen> createState() =>
      _MarathonRegistrationWithParticipantsScreenState();
}

class _MarathonRegistrationWithParticipantsScreenState
    extends State<MarathonRegistrationWithParticipantsScreen> {
  RegistrationStep _currentStep = RegistrationStep.participantSelection;
  PaymentMethod? _selectedPaymentMethod;
  bool _agreedToTerms = false;
  int _participantCount = 1;
  List<ParticipantData> _participants = [];
  List<bool> _participantExpanded = [];

  @override
  void initState() {
    super.initState();
    _initializeParticipants();
  }

  void _initializeParticipants() {
    _participants = List.generate(_participantCount, (index) => ParticipantData());
    _participantExpanded = List.generate(_participantCount, (index) => index == 0);
    
    // Pre-populate first participant with user data
    if (_participants.isNotEmpty) {
      _loadUserDataForFirstParticipant();
    }
  }

  void _loadUserDataForFirstParticipant() {
    final authService = context.read<AuthService>();
    final firstParticipant = _participants[0];
    
    firstParticipant.name = authService.nickname ?? '';
    firstParticipant.email = authService.email ?? '';
    firstParticipant.gender = authService.gender;
    firstParticipant.birthDate = authService.birthDate;
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
        title: Text(_getStepTitle(l10n)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildStepIndicator(l10n),
          Expanded(
            child: _buildCurrentStepContent(l10n, event, race),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(AppLocalizations l10n) {
    switch (_currentStep) {
      case RegistrationStep.participantSelection:
        return l10n.registerForRace;
      case RegistrationStep.information:
        return l10n.registrationStep1;
      case RegistrationStep.payment:
        return l10n.registrationStep2;
    }
  }

  Widget _buildStepIndicator(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepCircle(1, _currentStep.index >= 0, _currentStep.index > 0),
          Expanded(child: _buildStepLine(_currentStep.index >= 1)),
          _buildStepCircle(2, _currentStep.index >= 1, _currentStep.index > 1),
          Expanded(child: _buildStepLine(_currentStep.index >= 2)),
          _buildStepCircle(3, _currentStep.index >= 2, false),
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
        child: isCompleted
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

  Widget _buildCurrentStepContent(AppLocalizations l10n, MarathonEvent event, MarathonRace race) {
    switch (_currentStep) {
      case RegistrationStep.participantSelection:
        return _buildParticipantSelectionStep(l10n, event, race);
      case RegistrationStep.information:
        return _buildInformationStep(l10n, event, race);
      case RegistrationStep.payment:
        return _buildPaymentStep(l10n, event, race);
    }
  }

  Widget _buildParticipantSelectionStep(AppLocalizations l10n, MarathonEvent event, MarathonRace race) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Race Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    race.getDistanceText(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRaceInfoRow(Icons.calendar_today, l10n.raceDate, dateFormat.format(race.raceDate)),
                  if (race.registrationDeadline != null) ...[
                    const SizedBox(height: 8),
                    _buildRaceInfoRow(Icons.schedule, l10n.registrationDeadline, dateFormat.format(race.registrationDeadline!)),
                  ],
                  const SizedBox(height: 8),
                  _buildRaceInfoRow(Icons.people, l10n.participants, '${race.currentParticipants}/${race.maxParticipants}'),
                  const SizedBox(height: 8),
                  _buildEntryFeeDisplay(race, l10n),
                  if (race.notes != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.notes,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      race.notes!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Participant Count Selection
          Text(
            '選擇參賽人數',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '最多可報名3人',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Text('參賽人數: ', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 16),
              ...List.generate(3, (index) {
                final count = index + 1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$count人'),
                    selected: _participantCount == count,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _participantCount = count;
                          _initializeParticipants();
                        });
                      }
                    },
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 32),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = RegistrationStep.information),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                '填寫報名資料',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationStep(AppLocalizations l10n, MarathonEvent event, MarathonRace race) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '參賽者資料 ($_participantCount人)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Participants Forms
          ExpansionPanelList(
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (index, isExpanded) {
              setState(() {
                _participantExpanded[index] = !isExpanded;
              });
            },
            children: _participants.asMap().entries.map((entry) {
              final index = entry.key;
              final participant = entry.value;
              return ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(
                      '${l10n.participantName} ${index + 1}${index == 0 ? ' (${l10n.mainContact})' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(participant.name.isEmpty ? l10n.notFilled : participant.name),
                  );
                },
                body: _buildParticipantForm(participant, index == 0, l10n),
                isExpanded: _participantExpanded[index],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Terms and Conditions
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
                    onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
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

          // Continue Button
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
    );
  }

  Widget _buildParticipantForm(ParticipantData participant, bool isMainContact, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          TextFormField(
            initialValue: participant.name,
            decoration: InputDecoration(
              labelText: l10n.name,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => participant.name = value,
          ),
          const SizedBox(height: 12),

          // Email
          TextFormField(
            initialValue: participant.email,
            decoration: InputDecoration(
              labelText: l10n.email,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => participant.email = value,
          ),
          const SizedBox(height: 12),

          // Phone (optional)
          PhoneNumberField(
            initialValue: participant.phone,
            labelText: l10n.phoneNumber,
            onChanged: (value) => participant.phone = value,
          ),
          const SizedBox(height: 12),

          // Gender
          DropdownButtonFormField<String>(
            value: participant.gender,
            decoration: InputDecoration(
              labelText: l10n.gender,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'male', child: Text(l10n.male)),
              DropdownMenuItem(value: 'female', child: Text(l10n.female)),
              DropdownMenuItem(value: 'other', child: Text(l10n.other)),
            ],
            onChanged: (value) => setState(() => participant.gender = value),
          ),
          const SizedBox(height: 12),

          // Birth Date
          BirthDateField(
            selectedDate: participant.birthDate,
            labelText: l10n.birthDate,
            onDateSelected: (date) => setState(() => participant.birthDate = date),
            minimumAge: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep(AppLocalizations l10n, MarathonEvent event, MarathonRace race) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Amount
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
                      '${race.getDistanceText()} × $_participantCount${l10n.people}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      'USD \${(race.currentFee * _participantCount).toStringAsFixed(2)}',
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
                    '${l10n.earlyBird} (${l10n.regularPrice}: USD \${(race.entryFee * _participantCount).toStringAsFixed(2)})',
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

          // Payment Method Selection
          Text(
            l10n.selectPaymentMethod,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodOption(l10n.creditCard, Icons.credit_card, PaymentMethod.creditCard),
          const SizedBox(height: 12),
          _buildPaymentMethodOption(l10n.abaPayment, Icons.account_balance, PaymentMethod.abaPayment),
          const SizedBox(height: 32),

          // Payment Button
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

  Widget _buildRaceInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildEntryFeeDisplay(MarathonRace race, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: race.isEarlyBirdPeriod ? Colors.green[50] : Colors.blue[50],
        border: Border.all(
          color: race.isEarlyBirdPeriod ? Colors.green : Colors.blue,
          width: race.isEarlyBirdPeriod ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.entryFee,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: race.isEarlyBirdPeriod ? Colors.green[700] : Colors.blue[700],
                ),
              ),
              if (race.isEarlyBirdPeriod && race.earlyBirdFee != null)
                Text(
                  '${l10n.earlyBird} - ${l10n.earlyBirdUntil} ${DateFormat('MM/dd').format(race.earlyBirdDeadline!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'USD \${race.currentFee.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: race.isEarlyBirdPeriod ? Colors.green[700] : Colors.blue[700],
                ),
              ),
              if (race.isEarlyBirdPeriod && race.earlyBirdFee != null)
                Text(
                  '${l10n.regularPrice}: USD \${race.entryFee.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(String title, IconData icon, PaymentMethod method) {
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
    // Check if all participants have required fields
    for (final participant in _participants) {
      if (participant.name.isEmpty || participant.email.isEmpty) {
        return false;
      }
    }
    
    // Check terms agreement
    final marathonService = context.read<MarathonService>();
    final event = marathonService.getEventById(widget.eventId);
    if (event?.termsAndConditions != null && !_agreedToTerms) return false;
    
    return true;
  }

  void _proceedToPayment() {
    setState(() => _currentStep = RegistrationStep.payment);
  }

  void _processPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        _showPaymentResult(true);
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
              Navigator.pop(context);
              Navigator.pop(context);
              if (success) {
                Navigator.pop(context);
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