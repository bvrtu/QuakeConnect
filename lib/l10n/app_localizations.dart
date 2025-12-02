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
      'within_km': 'Within 200 km radius',
      'community_updates': 'Community Updates',
      'local_reports': 'Local reports in your area',
      'location_privacy': 'Location & Privacy',
      'location_services': 'Location Services',
      'show_nearby': 'Show nearby earthquakes',
      'notification_permission_denied': 'Notification permission is required',
      'location_permission_denied': 'Location permission is required',
      'location_services_disabled': 'Please enable location services on your device',
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
      'present_option': 'Present',
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
      'comment_sent': 'Comment sent',
      'repost_added': 'Repost added to your updates',
      'post_shared_external': 'Post shared',
      'no_updates_yet': 'No updates yet. Be the first to share!',
      'cancel': 'Cancel',
      'confirm': 'Confirm',

      'profile_title': 'Profile',
      'edit_profile': 'Edit Profile',
      'profile_updated': 'Profile updated',
      'profile_photo_updated': 'Profile photo updated',
      'avatar_color_updated': 'Avatar color updated',
      'no_image_selected': 'No image selected',
      'save_changes_title': 'Save changes?',
      'save_changes_prompt': 'Your profile information will be updated. Do you want to continue?',
      'emergency_contacts': 'Emergency Contacts',
      'call': 'Call',
      'notifications_title': 'Notifications',
      'no_notifications_title': 'No notifications',
      'no_notifications_subtitle': "You're all caught up. We'll keep you posted.",
      'major_earthquake_alert': 'Major Earthquake Alert',
      'earthquake_detected': 'Earthquake Detected',
      'from_your_location': 'from your location',
      'earthquake_in': 'earthquake in',
      'away_suffix': 'away',
      'deep_suffix': 'deep',
      'distance_unknown': 'Distance unknown',
      'your_location': 'Your Location',
      'you_are_here': 'You are here',
      'thread': 'Thread',
      'no_replies_yet': 'No replies yet. Start the conversation.',
      'reply': 'Reply...',
      'replying_to': 'Replying to',
      'show_replies': 'Show {count} replies',
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
      'other_specify': 'Other (please specify)',
      // Auth
      'login': 'Login',
      'register': 'Register',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'welcome_back': 'Welcome back',
      'create_account': 'Create your account',
      'dont_have_account': "Don't have an account? ",
      'already_have_account': 'Already have an account? ',
      'email_required': 'Email is required',
      'password_required': 'Password is required',
      'confirm_password_required': 'Please confirm your password',
      'name_required': 'Name is required',
      'username_required': 'Username is required',
      'invalid_email': 'Invalid email',
      'password_too_short': 'Password must be at least 6 characters',
      'passwords_do_not_match': 'Passwords do not match',
      'username_must_start_with_at': 'Username must start with @',
      'username_too_short': 'Username must be at least 4 characters',
      'username_taken': 'Username is already taken',
      'enter_email_for_password_reset': 'Please enter your email first',
      'password_reset_email_sent': 'Password reset email sent',
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
      'within_km': '200 km yarıçap içinde',
      'community_updates': 'Topluluk Güncellemeleri',
      'local_reports': 'Bölgenizdeki yerel paylaşımlar',
      'location_privacy': 'Konum ve Gizlilik',
      'location_services': 'Konum Servisleri',
      'show_nearby': 'Yakındaki depremleri göster',
      'notification_permission_denied': 'Bildirim izni gerekli',
      'location_permission_denied': 'Konum izni gerekli',
      'location_services_disabled': 'Lütfen cihazınızda konum servislerini açın',
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
      'present_option': 'Var',
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
      'comment_sent': 'Yorum gönderildi',
      'repost_added': 'Repost eklendi',
      'post_shared_external': 'Gönderi paylaşıldı',
      'no_updates_yet': 'Henüz güncelleme yok. İlk paylaşımı yap!',
      'cancel': 'İptal',
      'confirm': 'Onayla',

      'profile_title': 'Profil',
      'edit_profile': 'Profili Düzenle',
      'profile_updated': 'Profil güncellendi',
      'profile_photo_updated': 'Profil fotoğrafı güncellendi',
      'avatar_color_updated': 'Avatar rengi güncellendi',
      'no_image_selected': 'Herhangi bir görsel seçilmedi',
      'save_changes_title': 'Değişiklikleri kaydet?',
      'save_changes_prompt': 'Profil bilgilerin güncellenecek. Devam etmek istiyor musun?',
      'emergency_contacts': 'Acil Durum Kişileri',
      'call': 'Ara',
      'notifications_title': 'Bildirimler',
      'no_notifications_title': 'Bildirim yok',
      'no_notifications_subtitle': 'Şimdilik yeni bir bildirim yok. Gelişmeleri sana bildireceğiz.',
      'major_earthquake_alert': 'Büyük Deprem Uyarısı',
      'earthquake_detected': 'Deprem Tespit Edildi',
      'from_your_location': 'konumunuzdan',
      'earthquake_in': 'deprem',
      'away_suffix': 'uzakta',
      'deep_suffix': 'derinlik',
      'distance_unknown': 'Mesafe bilinmiyor',
      'your_location': 'Konumunuz',
      'you_are_here': 'Buradayasınız',
      'thread': 'Sohbet',
      'no_replies_yet': 'Henüz yanıt yok. İlk yorumu yapın.',
      'reply': 'Yanıtla...',
      'replying_to': 'Yanıtlanan',
      'show_replies': '{count} yanıt göster',
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
      'other_specify': 'Diğer (lütfen belirtin)',
      // Auth
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'password': 'Şifre',
      'confirm_password': 'Şifreyi Onayla',
      'forgot_password': 'Şifremi Unuttum?',
      'welcome_back': 'Tekrar hoş geldiniz',
      'create_account': 'Hesabınızı oluşturun',
      'dont_have_account': 'Hesabınız yok mu? ',
      'already_have_account': 'Zaten hesabınız var mı? ',
      'email_required': 'E-posta gereklidir',
      'password_required': 'Şifre gereklidir',
      'confirm_password_required': 'Lütfen şifrenizi onaylayın',
      'name_required': 'İsim gereklidir',
      'username_required': 'Kullanıcı adı gereklidir',
      'invalid_email': 'Geçersiz e-posta',
      'password_too_short': 'Şifre en az 6 karakter olmalıdır',
      'passwords_do_not_match': 'Şifreler eşleşmiyor',
      'username_must_start_with_at': 'Kullanıcı adı @ ile başlamalıdır',
      'username_too_short': 'Kullanıcı adı en az 4 karakter olmalıdır',
      'username_taken': 'Kullanıcı adı zaten alınmış',
      'enter_email_for_password_reset': 'Lütfen önce e-postanızı girin',
      'password_reset_email_sent': 'Şifre sıfırlama e-postası gönderildi',
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
  String get notificationPermissionDenied => _t('notification_permission_denied');
  String get locationPermissionDenied => _t('location_permission_denied');
  String get locationServicesDisabled => _t('location_services_disabled');
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
  String get commentSent => _t('comment_sent');
  String get repostAdded => _t('repost_added');
  String get postSharedExternal => _t('post_shared_external');
  String get noUpdatesYet => _t('no_updates_yet');
  String get cancel => _t('cancel');
  String get confirm => _t('confirm');

  String get profileTitle => _t('profile_title');
  String get editProfile => _t('edit_profile');
  String get profileUpdated => _t('profile_updated');
  String get profilePhotoUpdated => _t('profile_photo_updated');
  String get avatarColorUpdated => _t('avatar_color_updated');
  String get noImageSelected => _t('no_image_selected');
  String get saveChangesTitle => _t('save_changes_title');
  String get saveChangesPrompt => _t('save_changes_prompt');
  String get emergencyContacts => _t('emergency_contacts');
  String get call => _t('call');
  String get notificationsTitle => _t('notifications_title');
  String get noNotificationsTitle => _t('no_notifications_title');
  String get noNotificationsSubtitle => _t('no_notifications_subtitle');
  String get majorEarthquakeAlert => _t('major_earthquake_alert');
  String get earthquakeDetected => _t('earthquake_detected');
  String get fromYourLocation => _t('from_your_location');
  String get earthquakeIn => _t('earthquake_in');
  String get awaySuffix => _t('away_suffix');
  String get deepSuffix => _t('deep_suffix');
  String get distanceUnknown => _t('distance_unknown');
  String get yourLocation => _t('your_location');
  String get youAreHere => _t('you_are_here');
  String get thread => _t('thread');
  String get noRepliesYet => _t('no_replies_yet');
  String get reply => _t('reply');
  String get replyingTo => _t('replying_to');
  String showReplies(int count) => _t('show_replies').replaceAll('{count}', count.toString());
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
  String get otherSpecify => _t('other_specify');
  // Auth
  String get login => _t('login');
  String get register => _t('register');
  String get password => _t('password');
  String get confirmPassword => _t('confirm_password');
  String get forgotPassword => _t('forgot_password');
  String get welcomeBack => _t('welcome_back');
  String get createAccount => _t('create_account');
  String get dontHaveAccount => _t('dont_have_account');
  String get alreadyHaveAccount => _t('already_have_account');
  String get emailRequired => _t('email_required');
  String get passwordRequired => _t('password_required');
  String get confirmPasswordRequired => _t('confirm_password_required');
  String get nameRequired => _t('name_required');
  String get usernameRequired => _t('username_required');
  String get invalidEmail => _t('invalid_email');
  String get passwordTooShort => _t('password_too_short');
  String get passwordsDoNotMatch => _t('passwords_do_not_match');
  String get usernameMustStartWithAt => _t('username_must_start_with_at');
  String get usernameTooShort => _t('username_too_short');
  String get usernameTaken => _t('username_taken');
  String get enterEmailForPasswordReset => _t('enter_email_for_password_reset');
  String get passwordResetEmailSent => _t('password_reset_email_sent');
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
  String get presentOption => _t('present_option');
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


