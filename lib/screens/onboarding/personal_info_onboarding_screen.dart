import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../l10n/app_localizations.dart';
import '../../data/user_repository.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'profile_setup_onboarding_screen.dart';

class PersonalInfoOnboardingScreen extends StatefulWidget {
  const PersonalInfoOnboardingScreen({super.key});

  @override
  State<PersonalInfoOnboardingScreen> createState() => _PersonalInfoOnboardingScreenState();
}

class _PersonalInfoOnboardingScreenState extends State<PersonalInfoOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _locationController = TextEditingController();
  final _otherController = TextEditingController();
  TextEditingController? _typeAheadController; // TypeAheadField'ın controller'ı için referans (dispose edilmeyecek)
  
  bool _hasDisability = false;
  Set<String> _selectedDisabilities = <String>{};
  bool _isLoading = false;

  final List<Map<String, String>> _disabilityOptions = [
    {'key': 'mobility', 'en': 'Mobility', 'tr': 'Hareket'},
    {'key': 'visual', 'en': 'Visual', 'tr': 'Görme'},
    {'key': 'hearing', 'en': 'Hearing', 'tr': 'İşitme'},
    {'key': 'cognitive', 'en': 'Cognitive', 'tr': 'Bilişsel'},
    {'key': 'other', 'en': 'Other', 'tr': 'Diğer'},
  ];

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _locationController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  Future<List<String>> _searchTurkishLocations(String query) async {
    if (!mounted) return [];
    
    try {
      const apiKey = 'AIzaSyClgydmQ7UOYcLEHdvSBkMJM2kwJvTapGo';
      final encodedQuery = Uri.encodeComponent('$query, Turkey');
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
        'input=$encodedQuery&'
        'components=country:tr&'
        'types=geocode&'
        'language=tr&'
        'key=$apiKey'
      );

      final response = await http.get(url);

      if (!mounted) return [];
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
          debugPrint('Google Places API error: ${data['status']}');
          return [];
        }

        final List<dynamic> predictions = data['predictions'] ?? [];
        final List<String> locations = [];

        for (var prediction in predictions) {
          if (!mounted) break;
          
          final description = prediction['description'] as String?;
          if (description != null) {
            // Format: "İlçe, Şehir, Türkiye" -> "İlçe, Şehir"
            final parts = description.split(', ');
            if (parts.length >= 2) {
              final location = '${parts[0]}, ${parts[1]}';
              if (!locations.contains(location)) {
                locations.add(location);
              }
            } else {
              locations.add(description);
            }
          }
        }

        return locations;
      }
      return [];
    } catch (e) {
      if (mounted) {
        debugPrint('Error searching locations: $e');
      }
      return [];
    }
  }

  String _getDisabilityLabel(String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final option = _disabilityOptions.firstWhere((opt) => opt['key'] == key);
    return locale == 'tr' ? option['tr']! : option['en']!;
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = AuthService.instance.currentUserId;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
        }
        return;
      }

      final userRepo = UserRepository.instance;
      final currentUser = await userRepo.getUser(userId);
      if (currentUser == null) return;

      final age = int.tryParse(_ageController.text.trim());
      final heightCm = int.tryParse(_heightController.text.trim());
      final weightKg = int.tryParse(_weightController.text.trim());
      final location = _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null;
      final disabilities = _hasDisability ? _selectedDisabilities.toList() : <String>[];
      final disabilityOther = _hasDisability && _selectedDisabilities.contains('other')
          ? _otherController.text.trim()
          : null;

      final updatedUser = currentUser.copyWith(
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        location: location,
        disabilities: disabilities,
        disabilityOther: disabilityOther,
      );

      await userRepo.updateUser(updatedUser);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ProfileSetupOnboardingScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Progress indicator
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Title
                Text(
                  t.personalInfoTitle ?? 'Personal Information',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.personalInfoSubtitle ?? 'Help us personalize your experience',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                // Age Field
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: t.ageYears ?? 'Age (years)',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.ageRequired ?? 'Age is required';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 1 || age > 150) {
                      return t.invalidAge ?? 'Please enter a valid age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Height Field
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: t.heightCm ?? 'Height (cm)',
                    prefixIcon: const Icon(Icons.height_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.heightRequired ?? 'Height is required';
                    }
                    final height = int.tryParse(value);
                    if (height == null || height < 50 || height > 300) {
                      return t.invalidHeight ?? 'Please enter a valid height';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Weight Field
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: t.weightKg ?? 'Weight (kg)',
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.weightRequired ?? 'Weight is required';
                    }
                    final weight = int.tryParse(value);
                    if (weight == null || weight < 10 || weight > 500) {
                      return t.invalidWeight ?? 'Please enter a valid weight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Location Field
                TypeAheadField<String>(
                  suggestionsCallback: (pattern) async {
                    if (pattern.length < 2 || !mounted) return [];
                    return await _searchTurkishLocations(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: const Icon(Icons.location_on, size: 20),
                      title: Text(suggestion),
                      dense: true,
                    );
                  },
                  onSelected: (suggestion) {
                    if (!mounted) return;
                    // Update both controllers when a suggestion is selected
                    _locationController.text = suggestion;
                    if (_typeAheadController != null) {
                      _typeAheadController!.text = suggestion;
                      _typeAheadController!.selection = TextSelection.fromPosition(
                        TextPosition(offset: suggestion.length),
                      );
                    }
                    setState(() {});
                  },
                  builder: (context, controller, focusNode) {
                    // Store the controller reference (don't dispose, TypeAheadField manages it)
                    _typeAheadController = controller;
                    
                    // Initialize controller with location value if empty
                    if (controller.text.isEmpty && _locationController.text.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && controller.text != _locationController.text) {
                          controller.text = _locationController.text;
                        }
                      });
                    }
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        if (!mounted) return;
                        _locationController.text = value;
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: t.locationLabel ?? 'Location',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  emptyBuilder: (context) => const SizedBox.shrink(),
                  loadingBuilder: (context) => const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorBuilder: (context, error) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $error', style: TextStyle(color: Colors.red.shade700)),
                  ),
                ),
                const SizedBox(height: 24),
                // Disability Status
                Text(
                  t.disabilityStatus ?? 'Disability Status',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(t.presentOption ?? 'Present'),
                  value: _hasDisability,
                  onChanged: (value) {
                    setState(() {
                      _hasDisability = value;
                      if (!value) {
                        _selectedDisabilities.clear();
                      }
                    });
                  },
                ),
                if (_hasDisability) ...[
                  const SizedBox(height: 12),
                  ..._disabilityOptions.map((option) {
                    final key = option['key']!;
                    return CheckboxListTile(
                      title: Text(_getDisabilityLabel(key)),
                      value: _selectedDisabilities.contains(key),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedDisabilities.add(key);
                          } else {
                            _selectedDisabilities.remove(key);
                          }
                        });
                      },
                    );
                  }),
                  if (_selectedDisabilities.contains('other')) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _otherController,
                      decoration: InputDecoration(
                        labelText: t.pleaseSpecify ?? 'Please specify',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (_selectedDisabilities.contains('other') &&
                            (value == null || value.trim().isEmpty)) {
                          return t.pleaseSpecify ?? 'Please specify';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 32),
                // Continue Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          t.continue_ ?? 'Continue',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

