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
      'nav_discover': 'Discover',
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
      'age_required': 'Age is required',
      'invalid_age': 'Please enter a valid age',
      'height_cm': 'Height (cm)',
      'height_required': 'Height is required',
      'invalid_height': 'Please enter a valid height',
      'weight_kg': 'Weight (kg)',
      'weight_required': 'Weight is required',
      'invalid_weight': 'Please enter a valid weight',
      'disability_status': 'Disability Status',
      'none_option': 'None',
      'present_option': 'Present',
      'emergency_tip': 'Emergency contacts will be notified when you mark yourself as safe or when you need help.',
      'add_contact_tip': 'Add at least one emergency contact so you can reach them instantly.',
      'contacts_will_be_notified': '{count} emergency contacts will be notified',
      'no_emergency_contacts': 'Add at least one emergency contact to use this feature.',
      'no_contacts_saved': 'No emergency contacts yet',
      'tap_to_add_contact': 'Save trusted people you can reach instantly.',
      'go_to_profile_change_pp': 'Go to your profile to change your profile picture',
      'followed_user': 'Followed {name}',
      'unfollowed_user': 'Unfollowed {name}',

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
      'mark_safe_prompt': 'We will notify {count} emergency contacts that you are safe. Do you want to continue?',
      'your_safety_status': 'Your Safety Status',
      'let_others_know': "Let others know you're safe",
      'view_all': 'View All',
      'community_updates_title': 'Community Updates',
      'following_updates_title': 'Updates from Following',
      'popular_posts': 'Popular Posts',
      'posts': 'Posts',
      'discover_title': 'Discover',
      'search_users': 'Search Users',
      'search_users_hint': 'Search by name or username...',
      'suggested_users': 'Suggested Users',
      'trending_posts': 'Trending Posts',
      'no_users_found': 'No users found',
      'no_suggestions': 'No suggestions available',
      'safety_status_sent': 'Safety status sent to emergency contacts',
      'safety_status_cleared': 'Safety status cleared',
      'post_shared': 'Your update has been shared with the community',
      'comment_sent': 'Comment sent',
      'repost_added': 'Repost added to your updates',
      'emergency_tools': 'Emergency Tools',
      'earthquake_info': 'Earthquake Info',
      'whistle': 'Whistle',
      'stop': 'Stop',
      'earthquake_info_title': 'Earthquake Information',
      'before_earthquake': 'Before',
      'during_earthquake': 'During',
      'after_earthquake': 'After',
      'home_preparations': 'Home Preparations',
      'emergency_kit': 'Emergency Kit',
      'family_plan': 'Family Plan',
      'do_not_do': 'What Not to Do',
      'if_indoors': 'If Indoors',
      'if_outdoors': 'If Outdoors',
      'if_in_vehicle': 'If in Vehicle',
      'immediately_after': 'Immediately After',
      'communication': 'Communication',
      'safety_check': 'Safety Check',
      'help_and_support': 'Help and Support',
      'home_prep_1': 'Secure heavy furniture (cabinets, bookshelves, TV) to walls',
      'home_prep_2': 'Place shelves and cabinets securely',
      'home_prep_3': 'Place breakable items on lower shelves',
      'home_prep_4': 'Keep beds away from windows and glass',
      'home_prep_5': 'Learn the location of gas and water valves',
      'home_prep_6': 'Prepare an emergency kit',
      'emergency_kit_1': 'Water (at least 3 days worth)',
      'emergency_kit_2': 'Canned food and can opener',
      'emergency_kit_3': 'First aid kit',
      'emergency_kit_4': 'Flashlight and spare batteries',
      'emergency_kit_5': 'Radio (battery-powered)',
      'emergency_kit_6': 'Important documents (copies)',
      'emergency_kit_7': 'Cash',
      'emergency_kit_8': 'Personal medications',
      'emergency_kit_9': 'Phone charger (powerbank)',
      'family_plan_1': 'Set a meeting point with family members',
      'family_plan_2': 'Save emergency contact numbers',
      'family_plan_3': 'Make an evacuation plan',
      'family_plan_4': 'Teach children what to do during an earthquake',
      'family_plan_5': 'Make a plan for pets',
      'do_not_before_1': 'Don\'t place heavy items on high shelves',
      'do_not_before_2': 'Don\'t place gas cylinders on the balcony',
      'do_not_before_3': 'Don\'t stay in old and damaged buildings',
      'do_not_before_4': 'Don\'t delay getting earthquake insurance',
      'indoors_1': 'Stay calm, don\'t panic',
      'indoors_2': 'Get under a sturdy table or desk',
      'indoors_3': 'Protect your head and neck',
      'indoors_4': 'Stay away from windows, glass, and cabinets',
      'indoors_5': 'Don\'t use elevators',
      'indoors_6': 'Don\'t run to stairs',
      'outdoors_1': 'Move to an open area',
      'outdoors_2': 'Stay away from buildings, walls, and power poles',
      'outdoors_3': 'If in a vehicle, stop in an open area',
      'outdoors_4': 'Don\'t stop under bridges or overpasses',
      'outdoors_5': 'Move away from the coast (tsunami risk)',
      'vehicle_1': 'Pull over to a safe place',
      'vehicle_2': 'Don\'t stop under bridges, tunnels, or overpasses',
      'vehicle_3': 'Stay inside the vehicle',
      'vehicle_4': 'Turn on the radio and get information',
      'do_not_during_1': 'Don\'t use elevators',
      'do_not_during_2': 'Don\'t run to stairs',
      'do_not_during_3': 'Don\'t go to the balcony',
      'do_not_during_4': 'Don\'t touch electrical switches',
      'do_not_during_5': 'Don\'t use matches or lighters (gas leak risk)',
      'immediately_after_1': 'Stay calm, take deep breaths',
      'immediately_after_2': 'Check yourself and those around you',
      'immediately_after_3': 'Provide first aid if there are injuries',
      'immediately_after_4': 'Check for gas leaks',
      'immediately_after_5': 'Turn off electrical breakers',
      'immediately_after_6': 'Check surrounding damage',
      'communication_1': 'Call 112 Emergency Call Center',
      'communication_2': 'Use phone only in emergencies',
      'communication_3': 'Prefer sending SMS (less network load)',
      'communication_4': 'Share accurate information on social media',
      'communication_5': 'Don\'t spread false information',
      'safety_check_1': 'Check the building\'s damage status',
      'safety_check_2': 'Exit the building if there is major damage',
      'safety_check_3': 'Be prepared for aftershocks',
      'safety_check_4': 'Call for help if someone is trapped under debris',
      'safety_check_5': 'Take your emergency kit with you',
      'help_support_1': 'Request help from organizations like AFAD and Red Crescent',
      'help_support_2': 'Communicate with your neighbors',
      'help_support_3': 'Support people you can help',
      'help_support_4': 'Get psychological support (if needed)',
      'do_not_after_1': 'Don\'t enter damaged buildings',
      'do_not_after_2': 'Don\'t touch electrical wires',
      'do_not_after_3': 'Don\'t make unnecessary phone calls',
      'do_not_after_4': 'Don\'t panic, stay calm',
      'do_not_after_5': 'Don\'t share false information',
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
      'send_sms': 'Send SMS',
      'delete_contact': 'Delete Contact',
      'manage_contacts': 'Manage Contacts',
      'contact_deleted': 'Contact removed',
      'sms_unavailable': 'Unable to open messaging app',
      'call_unavailable': 'Unable to open dialer',
      'safety_status_message': "Hi, I just marked myself safe on QuakeConnect. My current location: {location}. Time: {time}.",
      'notifications_title': 'Notifications',
      'no_notifications_title': 'No notifications',
      'no_notifications_subtitle': "You're all caught up. We'll keep you posted.",
      'clear_all': 'Clear All',
      'clear_all_notifications': 'Clear all notifications?',
      'clear_all_notifications_prompt': 'This will delete all notifications. This action cannot be undone.',
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
      'edit_contact': 'Edit Contact',
      'relation_required': 'Please specify the relation',
      'invalid_phone_number': 'Enter a valid phone number',
      'contacts_permission_denied': 'Contacts permission is required to pick from your phone.',
      'contact_missing_phone': 'Selected contact does not have a phone number',
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
      'continue_with_google': 'Continue with Google',
      'or': 'OR',
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
      'verify_email': 'Verify Email',
      'verify_email_title': 'Verify Your Email',
      'verify_email_message': 'We\'ve sent a verification link to',
      'verify_email_instructions': 'Instructions:',
      'verify_email_steps': '1. Check your email inbox\n2. Click on the verification link\n3. Return to this screen',
      'email_verified': 'Email Verified!',
      'email_verified_message': 'Your email has been verified successfully. You can now log in.',
      'email_verified_success': 'Your email has been verified! Redirecting to login...',
      'verification_email_sent': 'Verification email sent!',
      'resend_verification_email': 'Resend Verification Email',
      'resending': 'Resending...',
      'check_verification': 'Check Verification',
      'back_to_login': 'Back to Login',
      'email_not_verified': 'Please verify your email before continuing',
      'personal_info_title': 'Personal Information',
      'personal_info_subtitle': 'Help us personalize your experience',
      'profile_setup_title': 'One More Step',
      'profile_setup_subtitle': 'Set up your profile',
      'choose_image': 'Choose Image',
      'choose_color': 'Choose Color',
      'change_profile_picture': 'Change Profile Picture',
      'upload_image_tab': 'Upload Image',
      'upload_photo_instruction': 'Upload your photo',
      'max_file_size_info': 'Max file size: 5MB. Supported: JPG, PNG, GIF',
      'choose_gradient_instruction': 'Choose a gradient color',
      'save_changes_btn': 'Save Changes',
      'continue_': 'Continue',
      'please_specify': 'Please specify',
    },
    'tr': {
      'nav_home': 'Ana Sayfa',
      'nav_map': 'Harita',
      'nav_safety': 'Güvenlik',
      'nav_discover': 'Keşfet',
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
      'age_required': 'Yaş gereklidir',
      'invalid_age': 'Lütfen geçerli bir yaş girin',
      'height_cm': 'Boy (cm)',
      'height_required': 'Boy gereklidir',
      'invalid_height': 'Lütfen geçerli bir boy girin',
      'weight_kg': 'Kilo (kg)',
      'weight_required': 'Kilo gereklidir',
      'invalid_weight': 'Lütfen geçerli bir kilo girin',
      'disability_status': 'Engel Durumu',
      'none_option': 'Yok',
      'present_option': 'Var',
      'emergency_tip': 'Güvenli olduğunuzu işaretlediğinizde veya yardıma ihtiyacınız olduğunda acil durum kişileri bilgilendirilir.',
      'add_contact_tip': 'Hemen ulaşabileceğiniz en az bir acil durum kişisi ekleyin.',
      'contacts_will_be_notified': '{count} acil durum kişisine haber verilecek.',
      'no_emergency_contacts': 'Bu özelliği kullanmak için en az bir acil durum kişisi ekleyin.',
      'no_contacts_saved': 'Henüz acil durum kişisi yok',
      'tap_to_add_contact': 'Hemen ulaşmak için güvendiğiniz kişileri kaydedin.',
      'go_to_profile_change_pp': 'Profil fotoğrafını değiştirmek için profil sayfana git',
      'followed_user': '{name} takip edildi',
      'unfollowed_user': '{name} takipten çıkarıldı',

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
      'mark_safe_prompt': '{count} acil durum kişisine güvende olduğunuzu bildireceğiz. Devam etmek istiyor musunuz?',
      'your_safety_status': 'Güvenlik Durumun',
      'let_others_know': 'Güvende olduğunu herkese bildir',
      'view_all': 'Tümünü Gör',
      'community_updates_title': 'Topluluk Güncellemeleri',
      'following_updates_title': 'Takip Ettiklerinizden Güncellemeler',
      'popular_posts': 'Popüler Gönderiler',
      'posts': 'Gönderiler',
      'discover_title': 'Keşfet',
      'search_users': 'Kullanıcı Ara',
      'search_users_hint': 'İsim veya kullanıcı adı ile ara...',
      'suggested_users': 'Önerilen Kullanıcılar',
      'trending_posts': 'Popüler Gönderiler',
      'no_users_found': 'Kullanıcı bulunamadı',
      'no_suggestions': 'Öneri bulunamadı',
      'safety_status_sent': 'Güvenlik durumu acil kişilere iletildi',
      'safety_status_cleared': 'Güvenlik durumu kaldırıldı',
      'post_shared': 'Güncellemen toplulukla paylaşıldı',
      'comment_sent': 'Yorum gönderildi',
      'repost_added': 'Repost eklendi',
      'emergency_tools': 'Acil Durum Araçları',
      'earthquake_info': 'Deprem Bilgileri',
      'whistle': 'Düdük',
      'stop': 'Durdur',
      'earthquake_info_title': 'Deprem Bilgileri',
      'before_earthquake': 'Öncesi',
      'during_earthquake': 'Sırasında',
      'after_earthquake': 'Sonrası',
      'home_preparations': 'Ev Hazırlıkları',
      'emergency_kit': 'Acil Durum Çantası',
      'family_plan': 'Aile Planı',
      'do_not_do': 'Yapılmaması Gerekenler',
      'if_indoors': 'İçerideyseniz',
      'if_outdoors': 'Dışarıdaysanız',
      'if_in_vehicle': 'Araçtaysanız',
      'immediately_after': 'Hemen Sonra',
      'communication': 'İletişim',
      'safety_check': 'Güvenlik Kontrolü',
      'help_and_support': 'Yardım ve Destek',
      'home_prep_1': 'Ağır eşyaları (dolap, kitaplık, TV) duvara sabitleyin',
      'home_prep_2': 'Rafları ve dolapları güvenli şekilde yerleştirin',
      'home_prep_3': 'Kırılabilir eşyaları alt raflara koyun',
      'home_prep_4': 'Yatakları pencere ve camlardan uzak tutun',
      'home_prep_5': 'Gaz ve su vanalarının yerini öğrenin',
      'home_prep_6': 'Acil durum çantası hazırlayın',
      'emergency_kit_1': 'Su (en az 3 günlük)',
      'emergency_kit_2': 'Konserve yiyecekler ve açacak',
      'emergency_kit_3': 'İlk yardım çantası',
      'emergency_kit_4': 'Fener ve yedek piller',
      'emergency_kit_5': 'Radyo (pilli)',
      'emergency_kit_6': 'Önemli belgeler (fotokopi)',
      'emergency_kit_7': 'Nakit para',
      'emergency_kit_8': 'Kişisel ilaçlar',
      'emergency_kit_9': 'Telefon şarj cihazı (powerbank)',
      'family_plan_1': 'Aile üyeleriyle buluşma noktası belirleyin',
      'family_plan_2': 'Acil durum iletişim numaralarını kaydedin',
      'family_plan_3': 'Evden çıkış planı yapın',
      'family_plan_4': 'Çocuklara deprem sırasında ne yapmaları gerektiğini öğretin',
      'family_plan_5': 'Evcil hayvanlar için plan yapın',
      'do_not_before_1': 'Ağır eşyaları yüksek raflara koymayın',
      'do_not_before_2': 'Gaz tüplerini balkona koymayın',
      'do_not_before_3': 'Eski ve hasarlı binalarda kalmayın',
      'do_not_before_4': 'Deprem sigortası yaptırmayı ertelemeyin',
      'indoors_1': 'Sakin olun, panik yapmayın',
      'indoors_2': 'Sağlam bir masa veya sıranın altına girin',
      'indoors_3': 'Başınızı ve boynunuzu koruyun',
      'indoors_4': 'Pencere, cam, dolaplardan uzak durun',
      'indoors_5': 'Asansör kullanmayın',
      'indoors_6': 'Merdivenlere koşmayın',
      'outdoors_1': 'Açık alana çıkın',
      'outdoors_2': 'Binalardan, duvarlardan, elektrik direklerinden uzak durun',
      'outdoors_3': 'Araç içindeyseniz, açık alanda durun',
      'outdoors_4': 'Köprü, üst geçit altında durmayın',
      'outdoors_5': 'Deniz kenarından uzaklaşın (tsunami riski)',
      'vehicle_1': 'Aracı güvenli bir yere çekin',
      'vehicle_2': 'Köprü, tünel, üst geçit altında durmayın',
      'vehicle_3': 'Araç içinde kalın',
      'vehicle_4': 'Radyoyu açın ve bilgi alın',
      'do_not_during_1': 'Asansör kullanmayın',
      'do_not_during_2': 'Merdivenlere koşmayın',
      'do_not_during_3': 'Balkona çıkmayın',
      'do_not_during_4': 'Elektrik düğmelerine dokunmayın',
      'do_not_during_5': 'Kibrit, çakmak kullanmayın (gaz kaçağı riski)',
      'immediately_after_1': 'Sakin olun, derin nefes alın',
      'immediately_after_2': 'Kendinizi ve çevrenizdekileri kontrol edin',
      'immediately_after_3': 'Yaralı varsa ilk yardım yapın',
      'immediately_after_4': 'Gaz kaçağı olup olmadığını kontrol edin',
      'immediately_after_5': 'Elektrik sigortalarını kapatın',
      'immediately_after_6': 'Çevredeki hasarları kontrol edin',
      'communication_1': '112 Acil Çağrı Merkezi\'ni arayın',
      'communication_2': 'Sadece acil durumlarda telefon kullanın',
      'communication_3': 'SMS göndermeyi tercih edin (daha az ağ yükü)',
      'communication_4': 'Sosyal medyada doğru bilgi paylaşın',
      'communication_5': 'Yanlış bilgi yaymayın',
      'safety_check_1': 'Binanın hasar durumunu kontrol edin',
      'safety_check_2': 'Büyük hasar varsa binadan çıkın',
      'safety_check_3': 'Artçı sarsıntılara hazırlıklı olun',
      'safety_check_4': 'Yıkıntı altında kalan varsa yardım çağırın',
      'safety_check_5': 'Acil durum çantanızı yanınıza alın',
      'help_support_1': 'AFAD ve Kızılay gibi kuruluşlardan yardım isteyin',
      'help_support_2': 'Komşularınızla iletişim kurun',
      'help_support_3': 'Yardım edebileceğiniz kişilere destek olun',
      'help_support_4': 'Psikolojik destek alın (gerekirse)',
      'do_not_after_1': 'Hasarlı binaya girmeyin',
      'do_not_after_2': 'Elektrik tellerine dokunmayın',
      'do_not_after_3': 'Gereksiz telefon görüşmesi yapmayın',
      'do_not_after_4': 'Panik yapmayın, sakin kalın',
      'do_not_after_5': 'Yanlış bilgi paylaşmayın',
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
      'send_sms': 'SMS Gönder',
      'delete_contact': 'Kişiyi Sil',
      'manage_contacts': 'Kişileri Yönet',
      'contact_deleted': 'Kişi silindi',
      'sms_unavailable': 'Mesaj uygulaması açılamadı',
      'call_unavailable': 'Telefon uygulaması açılamadı',
      'safety_status_message': 'Merhaba, QuakeConnect üzerinden kendimi güvende olarak işaretledim. Konumum: {location}. Zaman: {time}.',
      'notifications_title': 'Bildirimler',
      'no_notifications_title': 'Bildirim yok',
      'no_notifications_subtitle': 'Şimdilik yeni bir bildirim yok. Gelişmeleri sana bildireceğiz.',
      'clear_all': 'Tümünü Temizle',
      'clear_all_notifications': 'Tüm bildirimleri temizle?',
      'clear_all_notifications_prompt': 'Bu işlem tüm bildirimleri silecek. Bu işlem geri alınamaz.',
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
      'edit_contact': 'Kişiyi Düzenle',
      'relation_required': 'Yakınlık bilgisi zorunludur',
      'invalid_phone_number': 'Geçerli bir telefon numarası girin',
      'contacts_permission_denied': 'Rehbere erişim izni gerekli',
      'contact_missing_phone': 'Seçilen kişide telefon numarası yok',
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
      'continue_with_google': 'Google ile Devam Et',
      'or': 'VEYA',
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
      'verify_email': 'E-postayı Doğrula',
      'verify_email_title': 'E-postanızı Doğrulayın',
      'verify_email_message': 'Doğrulama bağlantısını şu adrese gönderdik:',
      'verify_email_instructions': 'Talimatlar:',
      'verify_email_steps': '1. E-posta kutunuzu kontrol edin\n2. Doğrulama bağlantısına tıklayın\n3. Bu ekrana geri dönün',
      'email_verified': 'E-posta Doğrulandı!',
      'email_verified_message': 'E-postanız başarıyla doğrulandı. Artık giriş yapabilirsiniz.',
      'email_verified_success': 'E-postanız doğrulandı! Giriş sayfasına yönlendiriliyorsunuz...',
      'verification_email_sent': 'Doğrulama e-postası gönderildi!',
      'resend_verification_email': 'Doğrulama E-postasını Yeniden Gönder',
      'resending': 'Yeniden gönderiliyor...',
      'check_verification': 'Doğrulamayı Kontrol Et',
      'back_to_login': 'Giriş Sayfasına Dön',
      'email_not_verified': 'Devam etmeden önce lütfen e-postanızı doğrulayın',
      'personal_info_title': 'Kişisel Bilgiler',
      'personal_info_subtitle': 'Deneyiminizi kişiselleştirmemize yardımcı olun',
      'profile_setup_title': 'Son Bir Adım',
      'profile_setup_subtitle': 'Profilinizi ayarlayın',
      'choose_image': 'Resim Seç',
      'choose_color': 'Renk Seç',
      'change_profile_picture': 'Profil Fotoğrafını Değiştir',
      'upload_image_tab': 'Resim Yükle',
      'upload_photo_instruction': 'Fotoğrafınızı yükleyin',
      'max_file_size_info': 'Maks. dosya boyutu: 5MB. Desteklenen: JPG, PNG, GIF',
      'choose_gradient_instruction': 'Bir gradyan rengi seçin',
      'save_changes_btn': 'Değişiklikleri Kaydet',
      'continue_': 'Devam Et',
      'please_specify': 'Lütfen belirtin',
    }
  };

  String _t(String key) => _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;

  // Expose getters for convenience
  String get navHome => _t('nav_home');
  String get navMap => _t('nav_map');
  String get navSafety => _t('nav_safety');
  String get navDiscover => _t('nav_discover');
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
  String get addContactTip => _t('add_contact_tip');
  String get noEmergencyContacts => _t('no_emergency_contacts');
  String get noContactsSaved => _t('no_contacts_saved');
  String get tapToAddContact => _t('tap_to_add_contact');
  String contactsWillBeNotified(int count) =>
      _t('contacts_will_be_notified').replaceAll('{count}', '$count');
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
  String markSafePrompt(int count) =>
      _t('mark_safe_prompt').replaceAll('{count}', '$count');
  String get viewAll => _t('view_all');
  String get communityUpdatesTitle => _t('community_updates_title');
  String get followingUpdatesTitle => _t('following_updates_title');
  String get popularPosts => _t('popular_posts');
  String get posts => _t('posts');
  String get discoverTitle => _t('discover_title');
  String get searchUsers => _t('search_users');
  String get searchUsersHint => _t('search_users_hint');
  String get suggestedUsers => _t('suggested_users');
  String get trendingPosts => _t('trending_posts');
  String get noUsersFound => _t('no_users_found');
  String get noSuggestions => _t('no_suggestions');
  String get safetyStatusSent => _t('safety_status_sent');
  String get safetyStatusCleared => _t('safety_status_cleared');
  String get postShared => _t('post_shared');
  String get commentSent => _t('comment_sent');
  String get repostAdded => _t('repost_added');
  String get postSharedExternal => _t('post_shared_external');
  String get emergencyTools => _t('emergency_tools');
  String get earthquakeInfo => _t('earthquake_info');
  String get whistle => _t('whistle');
  String get stop => _t('stop');
  String get earthquakeInfoTitle => _t('earthquake_info_title');
  String get beforeEarthquake => _t('before_earthquake');
  String get duringEarthquake => _t('during_earthquake');
  String get afterEarthquake => _t('after_earthquake');
  String get homePreparations => _t('home_preparations');
  String get emergencyKit => _t('emergency_kit');
  String get familyPlan => _t('family_plan');
  String get doNotDo => _t('do_not_do');
  String get ifIndoors => _t('if_indoors');
  String get ifOutdoors => _t('if_outdoors');
  String get ifInVehicle => _t('if_in_vehicle');
  String get immediatelyAfter => _t('immediately_after');
  String get communication => _t('communication');
  String get safetyCheck => _t('safety_check');
  String get helpAndSupport => _t('help_and_support');
  String get homePrep1 => _t('home_prep_1');
  String get homePrep2 => _t('home_prep_2');
  String get homePrep3 => _t('home_prep_3');
  String get homePrep4 => _t('home_prep_4');
  String get homePrep5 => _t('home_prep_5');
  String get homePrep6 => _t('home_prep_6');
  String get emergencyKit1 => _t('emergency_kit_1');
  String get emergencyKit2 => _t('emergency_kit_2');
  String get emergencyKit3 => _t('emergency_kit_3');
  String get emergencyKit4 => _t('emergency_kit_4');
  String get emergencyKit5 => _t('emergency_kit_5');
  String get emergencyKit6 => _t('emergency_kit_6');
  String get emergencyKit7 => _t('emergency_kit_7');
  String get emergencyKit8 => _t('emergency_kit_8');
  String get emergencyKit9 => _t('emergency_kit_9');
  String get familyPlan1 => _t('family_plan_1');
  String get familyPlan2 => _t('family_plan_2');
  String get familyPlan3 => _t('family_plan_3');
  String get familyPlan4 => _t('family_plan_4');
  String get familyPlan5 => _t('family_plan_5');
  String get doNotBefore1 => _t('do_not_before_1');
  String get doNotBefore2 => _t('do_not_before_2');
  String get doNotBefore3 => _t('do_not_before_3');
  String get doNotBefore4 => _t('do_not_before_4');
  String get indoors1 => _t('indoors_1');
  String get indoors2 => _t('indoors_2');
  String get indoors3 => _t('indoors_3');
  String get indoors4 => _t('indoors_4');
  String get indoors5 => _t('indoors_5');
  String get indoors6 => _t('indoors_6');
  String get outdoors1 => _t('outdoors_1');
  String get outdoors2 => _t('outdoors_2');
  String get outdoors3 => _t('outdoors_3');
  String get outdoors4 => _t('outdoors_4');
  String get outdoors5 => _t('outdoors_5');
  String get vehicle1 => _t('vehicle_1');
  String get vehicle2 => _t('vehicle_2');
  String get vehicle3 => _t('vehicle_3');
  String get vehicle4 => _t('vehicle_4');
  String get doNotDuring1 => _t('do_not_during_1');
  String get doNotDuring2 => _t('do_not_during_2');
  String get doNotDuring3 => _t('do_not_during_3');
  String get doNotDuring4 => _t('do_not_during_4');
  String get doNotDuring5 => _t('do_not_during_5');
  String get immediatelyAfter1 => _t('immediately_after_1');
  String get immediatelyAfter2 => _t('immediately_after_2');
  String get immediatelyAfter3 => _t('immediately_after_3');
  String get immediatelyAfter4 => _t('immediately_after_4');
  String get immediatelyAfter5 => _t('immediately_after_5');
  String get immediatelyAfter6 => _t('immediately_after_6');
  String get communication1 => _t('communication_1');
  String get communication2 => _t('communication_2');
  String get communication3 => _t('communication_3');
  String get communication4 => _t('communication_4');
  String get communication5 => _t('communication_5');
  String get safetyCheck1 => _t('safety_check_1');
  String get safetyCheck2 => _t('safety_check_2');
  String get safetyCheck3 => _t('safety_check_3');
  String get safetyCheck4 => _t('safety_check_4');
  String get safetyCheck5 => _t('safety_check_5');
  String get helpSupport1 => _t('help_support_1');
  String get helpSupport2 => _t('help_support_2');
  String get helpSupport3 => _t('help_support_3');
  String get helpSupport4 => _t('help_support_4');
  String get doNotAfter1 => _t('do_not_after_1');
  String get doNotAfter2 => _t('do_not_after_2');
  String get doNotAfter3 => _t('do_not_after_3');
  String get doNotAfter4 => _t('do_not_after_4');
  String get doNotAfter5 => _t('do_not_after_5');
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
  String get editContact => _t('edit_contact');
  String get relationRequired => _t('relation_required');
  String get invalidPhoneNumber => _t('invalid_phone_number');
  String get contactsPermissionDenied => _t('contacts_permission_denied');
  String get contactMissingPhone => _t('contact_missing_phone');
  String get sendSms => _t('send_sms');
  String get deleteContact => _t('delete_contact');
  String get manageContacts => _t('manage_contacts');
  String get contactDeleted => _t('contact_deleted');
  String get smsUnavailable => _t('sms_unavailable');
  String get callUnavailable => _t('call_unavailable');
  String safetyStatusMessage(String location, String time) =>
      _t('safety_status_message').replaceAll('{location}', location).replaceAll('{time}', time);
  String get notificationsTitle => _t('notifications_title');
  String get noNotificationsTitle => _t('no_notifications_title');
  String get noNotificationsSubtitle => _t('no_notifications_subtitle');
  String get clearAll => _t('clear_all');
  String get clearAllNotifications => _t('clear_all_notifications');
  String get clearAllNotificationsPrompt => _t('clear_all_notifications_prompt');
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
  String get continueWithGoogle => _t('continue_with_google');
  String get or => _t('or');
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
  String get verifyEmail => _t('verify_email');
  String get verifyEmailTitle => _t('verify_email_title');
  String get verifyEmailMessage => _t('verify_email_message');
  String get verifyEmailInstructions => _t('verify_email_instructions');
  String get verifyEmailSteps => _t('verify_email_steps');
  String get emailVerified => _t('email_verified');
  String get emailVerifiedMessage => _t('email_verified_message');
  String get emailVerifiedSuccess => _t('email_verified_success');
  String get verificationEmailSent => _t('verification_email_sent');
  String get resendVerificationEmail => _t('resend_verification_email');
  String get resending => _t('resending');
  String get checkVerification => _t('check_verification');
  String get backToLogin => _t('back_to_login');
  String get emailNotVerified => _t('email_not_verified');
  String get personalInfoTitle => _t('personal_info_title');
  String get personalInfoSubtitle => _t('personal_info_subtitle');
  String get profileSetupTitle => _t('profile_setup_title');
  String get profileSetupSubtitle => _t('profile_setup_subtitle');
  String get chooseImage => _t('choose_image');
  String get chooseColor => _t('choose_color');
  String get changeProfilePicture => _t('change_profile_picture');
  String get uploadImageTab => _t('upload_image_tab');
  String get uploadPhotoInstruction => _t('upload_photo_instruction');
  String get maxFileSizeInfo => _t('max_file_size_info');
  String get chooseGradientInstruction => _t('choose_gradient_instruction');
  String get saveChangesBtn => _t('save_changes_btn');
  String get continue_ => _t('continue_');
  String get pleaseSpecify => _t('please_specify');
  String get emergencyTip => _t('emergency_tip');
  String get profilePicture => _t('profile_picture');
  String get nameLabel => _t('name_label');
  String get usernameLabel => _t('username_label');
  String get locationLabel => _t('location_label');
  String get emailLabel => _t('email_label');
  String get personalInfo => _t('personal_info');
  String get ageYears => _t('age_years');
  String get ageRequired => _t('age_required');
  String get invalidAge => _t('invalid_age');
  String get heightCm => _t('height_cm');
  String get heightRequired => _t('height_required');
  String get invalidHeight => _t('invalid_height');
  String get weightKg => _t('weight_kg');
  String get weightRequired => _t('weight_required');
  String get invalidWeight => _t('invalid_weight');
  String get disabilityStatus => _t('disability_status');
  String get noneOption => _t('none_option');
  String get presentOption => _t('present_option');
  String get goToProfileChangePp => _t('go_to_profile_change_pp');
  String followedUser(String name) => _t('followed_user').replaceAll('{name}', name);
  String unfollowedUser(String name) => _t('unfollowed_user').replaceAll('{name}', name);
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


