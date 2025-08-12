import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/country_codes.dart';
import '../l10n/app_localizations.dart';

class PhoneNumberField extends StatefulWidget {
  final String? initialValue;
  final String? labelText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const PhoneNumberField({
    super.key,
    this.initialValue,
    this.labelText,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late CountryCode _selectedCountry;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    
    // 解析初始值
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _parseInitialValue(widget.initialValue!);
    } else {
      _selectedCountry = CountryCodes.getDefault();
      _controller = TextEditingController();
    }
  }

  void _parseInitialValue(String phoneNumber) {
    // 嘗試解析已有的電話號碼
    for (final country in CountryCodes.countries) {
      if (phoneNumber.startsWith(country.dialCode)) {
        _selectedCountry = country;
        _controller = TextEditingController(
          text: phoneNumber.substring(country.dialCode.length).trim(),
        );
        return;
      }
    }
    
    // 如果沒有找到匹配的國碼，使用預設
    _selectedCountry = CountryCodes.getDefault();
    _controller = TextEditingController(text: phoneNumber);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final fullNumber = _selectedCountry.dialCode + _controller.text;
    widget.onChanged?.call(fullNumber);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 國碼選擇器
            InkWell(
              onTap: widget.enabled ? _showCountryPicker : null,
              child: Container(
                height: 56, // 與 TextFormField 高度保持一致
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  color: widget.enabled ? Colors.white : Colors.grey[100],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCountry.flag,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedCountry.dialCode,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: widget.enabled ? null : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 電話號碼輸入框
            Expanded(
              child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                enabled: widget.enabled,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15), // 限制長度
                ],
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  hintText: '912345678',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400]!),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                onChanged: (_) => _onPhoneChanged(),
                validator: widget.validator != null 
                  ? (value) => widget.validator!(_selectedCountry.dialCode + (value ?? ''))
                  : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '範例: ${_selectedCountry.dialCode} 912345678',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CountryPickerBottomSheet(
        selectedCountry: _selectedCountry,
        onCountrySelected: (country) {
          setState(() {
            _selectedCountry = country;
          });
          _onPhoneChanged();
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CountryPickerBottomSheet extends StatefulWidget {
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onCountrySelected;

  const _CountryPickerBottomSheet({
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  State<_CountryPickerBottomSheet> createState() => _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<_CountryPickerBottomSheet> {
  String _searchQuery = '';
  late List<CountryCode> _filteredCountries;

  @override
  void initState() {
    super.initState();
    _filteredCountries = CountryCodes.countries;
  }

  void _filterCountries(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredCountries = CountryCodes.countries;
      } else {
        _filteredCountries = CountryCodes.countries.where((country) {
          return country.name.toLowerCase().contains(_searchQuery) ||
                 country.dialCode.contains(_searchQuery) ||
                 country.code.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 標題列
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '選擇國家/地區',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 搜尋框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜尋國家或國碼',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _filterCountries,
            ),
          ),

          // 國家列表
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = country.code == widget.selectedCountry.code;

                return ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(country.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        country.dialCode,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  onTap: () => widget.onCountrySelected(country),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}