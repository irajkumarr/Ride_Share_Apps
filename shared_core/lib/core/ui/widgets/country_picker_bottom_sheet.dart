import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/common/extensions/extensions.dart';
import 'package:shared_core/core/ui/widgets/bottom_sheet_layout.dart';
import 'package:shared_core/core/ui/widgets/custom_divider.dart';
import 'package:shared_core/core/ui/widgets/custom_text.dart';
import 'package:shared_core/core/utils/colors.dart';

class CountryModel {
  final String countryCode;
  final String name;
  final String callingCode;
  final String flag;

  CountryModel({
    required this.countryCode,
    required this.name,
    required this.callingCode,
    required this.flag,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      countryCode: json['country_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      callingCode: json['calling_code']?.toString() ?? '',
      flag: json['flag']?.toString() ?? '',
    );
  }
}

class CountryPickerBottomSheet extends StatefulWidget {
  const CountryPickerBottomSheet({super.key});

  static Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColor.background,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      sheetAnimationStyle: const AnimationStyle(duration: Duration(seconds: 2)),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const CountryPickerBottomSheet(),
      ),
    );
  }

  @override
  State<CountryPickerBottomSheet> createState() => _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<CountryPickerBottomSheet> {
  List<CountryModel> _allCountries = [];
  List<CountryModel> _filteredCountries = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadCountries() async {
    final String response = await rootBundle.loadString(
      'assets/countryCodes/countryCodes.json',
    );
    final List<dynamic> data = json.decode(response) as List<dynamic>;
    setState(() {
      _allCountries = data
          .map((json) => CountryModel.fromJson(json as Map<String, dynamic>))
          .toList();
      _filteredCountries = _allCountries;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = _allCountries
          .where((country) => country.name.toLowerCase().contains(query))
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
    // To ensure the bottom sheet does not occupy the entire screen unnecessarily
    // but expands when needed. We constrain height to a reasonable size.
    final screenHeight = context.screenHeight;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight,
        minHeight: screenHeight * 0.5,
      ),
      child: BottomSheetLayout(
        title: '', // Passing empty string as per design requirement (no title visible)
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search Country',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 22,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                  ),
                ),
              ),
            ),

            // Top Divider before list
            const CustomDivider(
              height: 1,
              color: AppColor.borderGrey,
            ),

            // Country List
            _filteredCountries.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: CustomText(
                        'No countries found',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredCountries.length,
                    separatorBuilder: (context, index) => const CustomDivider(
                      height: 1,
                      color: AppColor.borderGrey,
                    ),
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      return InkWell(
                        onTap: () {
                          // Selects the name of the country and pops it
                          Navigator.pop(context, country.name);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                          child: Row(
                            children: [
                              // Flag Image
                              Image.asset(
                                country.flag,
                                width: 28,
                                height: 20,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.flag, size: 20),
                              ),
                              const SizedBox(width: 16),

                              // Country Name
                              Expanded(
                                child: CustomText(
                                  country.name,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.black,
                                ),
                              ),

                              // Calling Code
                              CustomText(
                                country.callingCode,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColor.black,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

/*
// ==========================================
// HOW TO USE THIS COUNTRY PICKER BOTTOM SHEET
// ==========================================

// Example code demonstrating usage of the CountryPickerBottomSheet 
// inside a widget to select a country and print its name:

void _openCountryPicker(BuildContext context) async {
  final selectedCountryName = await CountryPickerBottomSheet.show(context);
  
  if (selectedCountryName != null) {
    // Perform your logic with the selected country name
    debugPrint('User selected: $selectedCountryName');
    
    // E.g., updating state
    // setState(() {
    //   _currentCountry = selectedCountryName;
    // });
  }
}

// In your build method:
// 
// ElevatedButton(
//   onPressed: () => _openCountryPicker(context),
//   child: Text('Select Country'),
// )

*/
