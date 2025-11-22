import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'nav_home': 'Home',
      'nav_map': 'Map',
      'nav_safety': 'Safety',
      'nav_profile': 'Profile',
      'nav_settings': 'Settings',

      'settings_title': 'Settings',
      'settings_customize': 'Customize your experience',
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'toggle_dark_theme': 'Toggle dark theme',
      'language': 'Language',
      'app_language': 'App Language',
      'choose_language': 'Choose your preferred language',
      'english': 'English',
      'turkish': 'Türkçe',
      'notification_settings': 'Notification Settings',
      'push_notifications': 'Push Notifications',
      'receive_alerts': 'Receive earthquake alerts',
      'min_magnitude_alert': 'Minimum Magnitude Alert',
      'only_notify_for': 'Only notify for earthquakes of magnitude {mag} or higher',
      'min_magnitude': 'Minimum Magnitude Alert',
      'nearby_alerts': 'Nearby Earthquake Alerts',
      'within_km': 'Within 100 km radius',
      'community_updates': 'Community Updates',
      'local_reports': 'Local reports in your area',
      'location_privacy': 'Location & Privacy',
      'location_services': 'Location Services',
      'show_nearby': 'Show nearby earthquakes',
      'share_safety_status': 'Share Safety Status',
      'let_contacts_see': 'Let contacts see your status',
      'about': 'About',
      'version': 'Version',
      'sign_out': 'Sign Out',
      'profile_picture': 'Profile Picture',
      'name_label': 'Name',
      'username_label': 'Username',
      'location_label': 'Location',
      'email_label': 'Email',
      'personal_info': 'Personal Information',
      'age_years': 'Age (years)',
      'height_cm': 'Height (cm)',
      'weight_kg': 'Weight (kg)',
      'disability_status': 'Disability Status',
      'none_option': 'None',
      'emergency_tip': 'Emergency contacts will be notified when you mark yourself as safe or when you need help.',
      'go_to_profile_change_pp': 'Go to your profile to change your profile picture',

      'home_subtitle': 'Real-time updates from Turkey',
      'search_hint': 'Search location...',
      'filters_all': 'All Quakes',
      'filters_nearby': 'Nearby',
      'filters_major': 'Major (5.0+)',

      'map_title': 'Map',
      'map_normal': 'Normal',
      'map_satellite': 'Satellite',
      'map_terrain': 'Terrain',
      'map_hybrid': 'Hybrid',

      'safety_title': 'Safety & Community',
      'safety_subtitle': 'Share your status and local updates',
      'share_local_info': 'Share Local Information',
      'need_help': 'Help',
      'share_info': 'Info',
      'im_safe': "I'm Safe",
      'mark_as_safe': 'Mark as Safe',
      'mark_safe_title': 'Mark as Safe?',
      'mark_safe_prompt': 'We will notify your emergency contacts that you are safe. Do you want to continue?',
      'your_safety_status': 'Your Safety Status',
      'let_others_know': "Let others know you're safe",
      'view_all': 'View All',
      'community_updates_title': 'Community Updates',
      'safety_status_sent': 'Safety status sent to emergency contacts',
      'safety_status_cleared': 'Safety status cleared',
      'post_shared': 'Your update has been shared with the community',
      'no_updates_yet': 'No updates yet. Be the first to share!',
      'cancel': 'Cancel',
      'confirm': 'Confirm',

      'profile_title': 'Profile',
      'edit_profile': 'Edit Profile',
      'emergency_contacts': 'Emergency Contacts',
      'call': 'Call',
      'notifications_title': 'Notifications',
      'away_suffix': 'away',
      'deep_suffix': 'deep',
      'thread': 'Thread',
      'no_replies_yet': 'No replies yet. Start the conversation.',
      'reply': 'Reply...',
      'replying_to': 'Replying to',
      'save': 'Save',
      'followers': 'Followers',
      'following': 'Following',
      'follow': 'Follow',
      'following_btn': 'Following',
      'import_contacts': 'Import from Contacts',
      'add_manually': 'Add Manually',
      'add': 'Add',
      'contact_added': 'Contact added',
      'add_emergency_contact': 'Add Emergency Contact',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'relation': 'Relation',
      'relation_hint': 'e.g., Spouse, Friend, Family',
      'spouse': 'Spouse',
      'brother': 'Brother',
      'sister': 'Sister',
      'friend': 'Friend',
      'family': 'Family',
    },
    'tr': {
      'nav_home': 'Ana Sayfa',
      'nav_map': 'Harita',
      'nav_safety': 'Güvenlik',
      'nav_profile': 'Profil',
      'nav_settings': 'Ayarlar',

      'settings_title': 'Ayarlar',
      'settings_customize': 'Deneyiminizi özelleştirin',
      'appearance': 'Görünüm',
      'dark_mode': 'Karanlık Mod',
      'toggle_dark_theme': 'Karanlık temayı aç/kapat',
      'language': 'Dil',
      'app_language': 'Uygulama Dili',
      'choose_language': 'Tercih ettiğiniz dili seçin',
      'english': 'English',
      'turkish': 'Türkçe',
      'notification_settings': 'Bildirim Ayarları',
      'push_notifications': 'Bildirimler',
      'receive_alerts': 'Deprem uyarılarını al',
      'min_magnitude_alert': 'Minimum Büyüklük Uyarısı',
      'only_notify_for': '{mag} ve üzeri depremler için bildir',
      'min_magnitude': 'Minimum Büyüklük Uyarısı',
      'nearby_alerts': 'Yakındaki Deprem Uyarıları',
      'within_km': '100 km yarıçap içinde',
      'community_updates': 'Topluluk Güncellemeleri',
      'local_reports': 'Bölgenizdeki yerel paylaşımlar',
      'location_privacy': 'Konum ve Gizlilik',
      'location_services': 'Konum Servisleri',
      'show_nearby': 'Yakındaki depremleri göster',
      'share_safety_status': 'Güvenlik Durumunu Paylaş',
      'let_contacts_see': 'Kişiler durumunu görsün',
      'about': 'Hakkında',
      'version': 'Sürüm',
      'sign_out': 'Çıkış Yap',
      'profile_picture': 'Profil Fotoğrafı',
      'name_label': 'Ad',
      'username_label': 'Kullanıcı Adı',
      'location_label': 'Konum',
      'email_label': 'E-posta',
      'personal_info': 'Kişisel Bilgiler',
      'age_years': 'Yaş (yıl)',
      'height_cm': 'Boy (cm)',
      'weight_kg': 'Kilo (kg)',
      'disability_status': 'Engel Durumu',
      'none_option': 'Yok',
      'emergency_tip': 'Güvenli olduğunuzu işaretlediğinizde veya yardıma ihtiyacınız olduğunda acil durum kişileri bilgilendirilir.',
      'go_to_profile_change_pp': 'Profil fotoğrafını değiştirmek için profil sayfana git',

      'home_subtitle': 'Türkiye’den anlık güncellemeler',
      'search_hint': 'Konum ara...',
      'filters_all': 'Tüm Depremler',
      'filters_nearby': 'Yakındakiler',
      'filters_major': 'Büyük (5.0+)',

      'map_title': 'Harita',
      'map_normal': 'Normal',
      'map_satellite': 'Uydu',
      'map_terrain': 'Arazi',
      'map_hybrid': 'Hibrit',

      'safety_title': 'Güvenlik ve Topluluk',
      'safety_subtitle': 'Durumunu ve yerel gelişmeleri paylaş',
      'share_local_info': 'Yerel Bilgi Paylaş',
      'need_help': 'Yardım',
      'share_info': 'Bilgi',
      'im_safe': 'Güvendeyim',
      'mark_as_safe': 'Güvenli Olarak İşaretle',
      'mark_safe_title': 'Güvenli Olarak İşaretle?',
      'mark_safe_prompt': 'Güvende olduğunuzu acil durum kişilerinize bildireceğiz. Devam etmek istiyor musunuz?',
      'your_safety_status': 'Güvenlik Durumun',
      'let_others_know': 'Güvende olduğunu herkese bildir',
      'view_all': 'Tümünü Gör',
      'community_updates_title': 'Topluluk Güncellemeleri',
      'safety_status_sent': 'Güvenlik durumu acil kişilere iletildi',
      'safety_status_cleared': 'Güvenlik durumu kaldırıldı',
      'post_shared': 'Güncellemen toplulukla paylaşıldı',
      'no_updates_yet': 'Henüz güncelleme yok. İlk paylaşımı yap!',
      'cancel': 'İptal',
      'confirm': 'Onayla',

      'profile_title': 'Profil',
      'edit_profile': 'Profili Düzenle',
      'emergency_contacts': 'Acil Durum Kişileri',
      'call': 'Ara',
      'notifications_title': 'Bildirimler',
      'away_suffix': 'uzakta',
      'deep_suffix': 'derinlik',
      'thread': 'Sohbet',
      'no_replies_yet': 'Henüz yanıt yok. İlk yorumu yapın.',
      'reply': 'Yanıtla...',
      'replying_to': 'Yanıtlanan',
      'save': 'Kaydet',
      'followers': 'Takipçiler',
      'following': 'Takip Edilen',
      'follow': 'Takip Et',
      'following_btn': 'Takip Ediliyor',
      'import_contacts': 'Rehberden İçe Aktar',
      'add_manually': 'Manuel Ekle',
      'add': 'Ekle',
      'contact_added': 'Kişi eklendi',
      'add_emergency_contact': 'Acil Durum Kişisi Ekle',
      'full_name': 'Ad Soyad',
      'phone_number': 'Telefon Numarası',
      'relation': 'İlişki',
      'relation_hint': 'örn. Eş, Arkadaş, Aile',
      'spouse': 'Eş',
      'brother': 'Kardeş',
      'sister': 'Kardeş',
      'friend': 'Arkadaş',
      'family': 'Aile',
    }
  };

  String _t(String key) => _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;

  // Expose getters for convenience
  String get navHome => _t('nav_home');
  String get navMap => _t('nav_map');
  String get navSafety => _t('nav_safety');
  String get navProfile => _t('nav_profile');
  String get navSettings => _t('nav_settings');

  String get settingsTitle => _t('settings_title');
  String get settingsCustomize => _t('settings_customize');
  String get appearance => _t('appearance');
  String get darkMode => _t('dark_mode');
  String get toggleDarkTheme => _t('toggle_dark_theme');
  String get language => _t('language');
  String get appLanguage => _t('app_language');
  String get chooseLanguage => _t('choose_language');
  String get english => _t('english');
  String get turkish => _t('turkish');
  String get notificationSettings => _t('notification_settings');
  String get pushNotifications => _t('push_notifications');
  String get receiveAlerts => _t('receive_alerts');
  String get minMagnitudeAlert => _t('min_magnitude_alert');
  String onlyNotifyFor(String mag) => _t('only_notify_for').replaceAll('{mag}', mag);
  String get nearbyAlerts => _t('nearby_alerts');
  String get withinKm => _t('within_km');
  String get communityUpdates => _t('community_updates');
  String get localReports => _t('local_reports');
  String get locationPrivacy => _t('location_privacy');
  String get locationServices => _t('location_services');
  String get showNearby => _t('show_nearby');
  String get shareSafetyStatus => _t('share_safety_status');
  String get letContactsSee => _t('let_contacts_see');
  String get about => _t('about');
  String get version => _t('version');
  String get signOut => _t('sign_out');

  String get homeSubtitle => _t('home_subtitle');
  String get searchHint => _t('search_hint');
  String get filtersAll => _t('filters_all');
  String get filtersNearby => _t('filters_nearby');
  String get filtersMajor => _t('filters_major');

  String get mapTitle => _t('map_title');
  String get mapNormal => _t('map_normal');
  String get mapSatellite => _t('map_satellite');
  String get mapTerrain => _t('map_terrain');
  String get mapHybrid => _t('map_hybrid');

  String get safetyTitle => _t('safety_title');
  String get safetySubtitle => _t('safety_subtitle');
  String get shareLocalInfo => _t('share_local_info');
  String get needHelp => _t('need_help');
  String get shareInfo => _t('share_info');
  String get imSafe => _t('im_safe');
  String get markAsSafe => _t('mark_as_safe');
  String get markSafeTitle => _t('mark_safe_title');
  String get markSafePrompt => _t('mark_safe_prompt');
  String get viewAll => _t('view_all');
  String get communityUpdatesTitle => _t('community_updates_title');
  String get safetyStatusSent => _t('safety_status_sent');
  String get safetyStatusCleared => _t('safety_status_cleared');
  String get postShared => _t('post_shared');
  String get noUpdatesYet => _t('no_updates_yet');
  String get cancel => _t('cancel');
  String get confirm => _t('confirm');

  String get profileTitle => _t('profile_title');
  String get editProfile => _t('edit_profile');
  String get emergencyContacts => _t('emergency_contacts');
  String get call => _t('call');
  String get notificationsTitle => _t('notifications_title');
  String get awaySuffix => _t('away_suffix');
  String get deepSuffix => _t('deep_suffix');
  String get thread => _t('thread');
  String get noRepliesYet => _t('no_replies_yet');
  String get reply => _t('reply');
  String get replyingTo => _t('replying_to');
  String get save => _t('save');
  String get add => _t('add');
  String get followers => _t('followers');
  String get following => _t('following');
  String get follow => _t('follow');
  String get followingBtn => _t('following_btn');
  String get importContacts => _t('import_contacts');
  String get addManually => _t('add_manually');
  String get contactAdded => _t('contact_added');
  String get addEmergencyContact => _t('add_emergency_contact');
  String get fullName => _t('full_name');
  String get phoneNumber => _t('phone_number');
  String get relation => _t('relation');
  String get relationHint => _t('relation_hint');
  String get spouse => _t('spouse');
  String get brother => _t('brother');
  String get sister => _t('sister');
  String get friend => _t('friend');
  String get family => _t('family');
  String get emergencyTip => _t('emergency_tip');
  String get profilePicture => _t('profile_picture');
  String get nameLabel => _t('name_label');
  String get usernameLabel => _t('username_label');
  String get locationLabel => _t('location_label');
  String get emailLabel => _t('email_label');
  String get personalInfo => _t('personal_info');
  String get ageYears => _t('age_years');
  String get heightCm => _t('height_cm');
  String get weightKg => _t('weight_kg');
  String get disabilityStatus => _t('disability_status');
  String get noneOption => _t('none_option');
  String get goToProfileChangePp => _t('go_to_profile_change_pp');
  String get yourSafetyStatus => _t('your_safety_status');
  String get letOthersKnow => _t('let_others_know');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'tr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}


