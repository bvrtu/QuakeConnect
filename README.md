# 🌍 QuakeConnect

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

**Türkiye için gerçek zamanlı deprem izleme ve topluluk platformu**

[Özellikler](#-özellikler) • [Kurulum](#-kurulum) • [Kullanım](#-kullanım) • [Mimari](#-mimari) • [Katkıda Bulunma](#-katkıda-bulunma)

</div>

---

## 📖 Hakkında

QuakeConnect, Türkiye'deki depremleri gerçek zamanlı olarak izleyen, kullanıcıların güvenlik durumlarını paylaşabileceği ve topluluk desteği alabileceği kapsamlı bir mobil uygulamadır. Kandilli Rasathanesi verilerini kullanarak anlık deprem bilgileri sağlar ve kullanıcıların birbirleriyle iletişim kurmasına olanak tanır.

### 🎯 Ana Amaçlar

- **Gerçek Zamanlı Deprem İzleme**: Kandilli Rasathanesi API'sinden anlık deprem verileri
- **Topluluk Desteği**: Kullanıcıların "I'm Safe", "Need Help" ve bilgi paylaşımı
- **Akıllı Bildirimler**: Kullanıcı tercihlerine göre özelleştirilebilir deprem uyarıları
- **Güvenlik Özellikleri**: Acil durum kontakları ve güvenlik durumu paylaşımı
- **Sosyal Özellikler**: Post paylaşma, beğenme, yorum yapma, takip etme

---

## ✨ Özellikler

### 🌐 Deprem İzleme
- ✅ Gerçek zamanlı deprem listesi (Kandilli Rasathanesi API)
- ✅ Google Maps entegrasyonu ile haritada görüntüleme
- ✅ Mesafe hesaplama (kullanıcı konumuna göre)
- ✅ Filtreleme: Tüm Depremler, Yakındakiler (200km), Büyük Depremler (M≥5.0)
- ✅ Arama özelliği (konum bazlı)
- ✅ Renk kodlu büyüklük göstergeleri

### 🔔 Bildirim Sistemi
- ✅ Push bildirimleri (uygulama açık/kapalı/arka planda)
- ✅ Minimum büyüklük filtresi (kullanıcı ayarlanabilir)
- ✅ Yakındaki uyarılar (200km içinde)
- ✅ Topluluk güncellemeleri (takip edilen kullanıcıların postları)
- ✅ Sosyal etkileşim bildirimleri (beğeni, yorum, repost, yanıt)
- ✅ Arka plan kontrolü (Workmanager ile 15 dakikada bir)

### 👥 Topluluk Özellikleri
- ✅ Post paylaşma (I'm Safe, Need Help, Info)
- ✅ Post beğenme ve repost etme
- ✅ Yorum yapma ve yanıt verme
- ✅ Kullanıcı takip etme/takibi bırakma
- ✅ Popüler postlar algoritması
- ✅ Kullanıcı arama ve keşfetme

### 🛡️ Güvenlik Özellikleri
- ✅ "I'm Safe" durumu paylaşımı
- ✅ Acil durum kontakları yönetimi
- ✅ Güvenlik bilgileri ve ipuçları
- ✅ Profil fotoğrafı ve gradient avatar seçenekleri

### ⚙️ Kullanıcı Özellikleri
- ✅ Email/Password ve Google Sign-In ile kimlik doğrulama
- ✅ Email doğrulama
- ✅ Kullanıcıya özel ayarlar (Firestore'da saklanır)
- ✅ Tema desteği (Light/Dark/System)
- ✅ Çoklu dil desteği (Türkçe/İngilizce)
- ✅ Profil yönetimi (fotoğraf, gradient, bilgiler)

### 📱 Platform Desteği
- ✅ Android (tam destek)
- ✅ iOS (tam destek)
- ✅ Material 3 tasarım
- ✅ Responsive UI

---

## 🚀 Kurulum

### Gereksinimler

- **Flutter**: 3.8.1 veya üzeri
- **Dart**: 3.8.1 veya üzeri
- **Firebase**: Proje yapılandırması gerekli
- **Google Maps API Key**: Harita özellikleri için

### Adım 1: Repository'yi Klonlayın

```bash
git clone https://github.com/YOUR_USERNAME/QuakeConnect.git
cd QuakeConnect
```

### Adım 2: Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### Adım 3: Firebase Yapılandırması

**📖 Detaylı kurulum rehberi için [SETUP.md](SETUP.md) dosyasına bakın.**

Kısa özet:

1. Firebase Console'dan `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını indirin
2. Dosyaları ilgili klasörlere kopyalayın
3. `lib/firebase_options.dart` dosyasını oluşturun:
   ```bash
   flutterfire configure
   ```
   Veya `lib/firebase_options.example.dart` dosyasını kopyalayıp düzenleyin

### Adım 4: Google Maps API Key

#### Android

`android/app/src/main/AndroidManifest.xml` dosyasında:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
```

#### iOS

`ios/Runner/AppDelegate.swift` dosyasında:

```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### Adım 5: Google Sign-In Yapılandırması

#### iOS

1. `ios/Runner/Info.plist` dosyasında URL scheme ekleyin (GoogleService-Info.plist'ten `REVERSED_CLIENT_ID`)
2. `ios/Runner/AppDelegate.swift` dosyasında URL handling ekleyin

Detaylar için `CODE_GUIDE.md` dosyasına bakın.

### Adım 6: Uygulamayı Çalıştırın

```bash
# Android
flutter run

# iOS
flutter run

# Belirli bir cihaz için
flutter devices
flutter run -d <device_id>
```

---

## 📱 Kullanım

### İlk Kullanım

1. **Kayıt Ol**: Email/Password veya Google Sign-In ile hesap oluşturun
2. **Email Doğrulama**: Email adresinizi doğrulayın
3. **Onboarding**: Kişisel bilgilerinizi girin (yaş, boy, kilo, engellilik durumu)
4. **Profil Kurulumu**: Kullanıcı adı seçin ve profil fotoğrafı/gradient seçin

### Ana Özellikler

#### Deprem İzleme
- **Home** sekmesinde son depremleri görüntüleyin
- Filtreleme seçeneklerini kullanın (Tümü, Yakındakiler, Büyükler)
- Bir depreme tıklayarak haritada konumunu görün
- Arama çubuğunu kullanarak belirli konumları arayın

#### Harita
- **Map** sekmesinde tüm depremleri haritada görüntüleyin
- Marker'lara tıklayarak deprem detaylarını görün
- Yakınlaştırma/uzaklaştırma yapın

#### Güvenlik
- **Safety** sekmesinde "I'm Safe" postu oluşturun
- Acil durum kontaklarınızı ekleyin
- Güvenlik bilgilerini okuyun

#### Keşfet
- **Discover** sekmesinde topluluk postlarını görüntüleyin
- Popüler postları keşfedin
- Kullanıcıları arayın ve takip edin
- Post beğenin, yorum yapın, repost edin

#### Profil
- **Profile** sekmesinde profilinizi görüntüleyin
- Postlarınızı görün
- Takipçi/takip edilen listelerini görün
- Profil fotoğrafınızı değiştirin

#### Ayarlar
- **Settings** sekmesinde:
  - Tema değiştirin (Light/Dark/System)
  - Dil değiştirin (Türkçe/İngilizce)
  - Bildirim ayarlarını yapın
  - Minimum deprem büyüklüğünü ayarlayın
  - Konum servislerini açın/kapatın
  - Çıkış yapın

---

## 🏗️ Mimari

### Proje Yapısı

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── data/                        # Repository Pattern - Veri katmanı
│   ├── app_notification_repository.dart
│   ├── comment_repository.dart
│   ├── emergency_contact_repository.dart
│   ├── notification_repository.dart
│   ├── post_repository.dart
│   ├── settings_repository.dart
│   └── user_repository.dart
├── models/                      # Veri modelleri
│   ├── community_post.dart
│   ├── earthquake.dart
│   ├── emergency_contact.dart
│   ├── notification_model.dart
│   └── user_model.dart
├── screens/                     # UI Ekranları
│   ├── auth/                    # Giriş/Kayıt
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── email_verification_screen.dart
│   ├── onboarding/             # İlk kullanım
│   │   ├── app_onboarding_screen.dart
│   │   ├── personal_info_onboarding_screen.dart
│   │   └── profile_setup_onboarding_screen.dart
│   ├── home_screen.dart
│   ├── map_screen.dart
│   ├── safety_screen.dart
│   ├── discover_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   ├── notifications_screen.dart
│   └── post_detail_screen.dart
├── services/                    # Servis katmanı
│   ├── auth_service.dart
│   ├── background_service.dart
│   ├── earthquake_api_service.dart
│   ├── location_service.dart
│   └── notification_service.dart
├── widgets/                     # Yeniden kullanılabilir widget'lar
│   ├── bottom_nav_bar.dart
│   ├── community_post_card.dart
│   ├── earthquake_card.dart
│   └── notification_card.dart
├── theme/                       # Tema ayarları
│   └── app_theme.dart
└── l10n/                        # Lokalizasyon
    ├── app_localizations.dart
    └── formatters.dart
```

### Mimari Pattern'ler

- **Repository Pattern**: Tüm veri işlemleri repository'ler üzerinden
- **Singleton Pattern**: Servisler ve repository'ler singleton
- **Stream-based**: Real-time veri güncellemeleri için Firestore streams
- **ValueNotifier**: Tema ve dil değişiklikleri için reactive state

### Firebase Yapısı

```
users/
  {userId}/
    - Kullanıcı bilgileri
    following/{followedUserId}/
    followers/{followerId}/
    notifications/{notificationId}/
    settings/app_settings/

posts/
  {postId}/
    - Post bilgileri
    likes/{userId}/
    reposts/{userId}/
    comments/{commentId}/
      replies/{replyId}/
```

Detaylı mimari bilgisi için `CODE_GUIDE.md` dosyasına bakın.

---

## 🛠️ Teknolojiler

### Core
- **Flutter**: 3.8.1 - Cross-platform framework
- **Dart**: 3.8.1 - Programlama dili

### Firebase
- **firebase_core**: Firebase entegrasyonu
- **firebase_auth**: Kimlik doğrulama
- **cloud_firestore**: NoSQL veritabanı
- **firebase_storage**: Dosya depolama

### Harita & Konum
- **google_maps_flutter**: Google Maps entegrasyonu
- **geolocator**: Konum servisleri
- **permission_handler**: İzin yönetimi

### Bildirimler
- **flutter_local_notifications**: Yerel bildirimler
- **workmanager**: Arka plan görevleri

### UI & UX
- **image_picker**: Resim seçme
- **image_cropper**: Resim kırpma
- **share_plus**: Paylaşım
- **flutter_typeahead**: Otomatik tamamlama

### Diğer
- **http**: API istekleri
- **shared_preferences**: Yerel ayarlar (eski, artık Firestore kullanılıyor)
- **google_sign_in**: Google Sign-In
- **url_launcher**: URL açma
- **flutter_contacts**: Kişi listesi

---

## 🔐 Güvenlik Notları

### ⚠️ ÖNEMLİ: Hassas Dosyalar

Aşağıdaki dosyalar `.gitignore`'a eklenmiştir ve **ASLA** commit edilmemelidir:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`
- API key'leri içeren dosyalar

### Yapılandırma Dosyaları

Bu dosyalar yerine örnek dosyalar oluşturulabilir:

- `android/app/google-services.json.example`
- `ios/Runner/GoogleService-Info.plist.example`
- `lib/firebase_options.example.dart`

### API Key'leri

API key'leri kod içinde hardcode edilmemelidir. Bunun yerine:

1. Environment variables kullanın
2. Yapılandırma dosyalarından okuyun
3. Build-time injection kullanın

---

## 📚 Dokümantasyon

- **[CODE_GUIDE.md](CODE_GUIDE.md)**: Detaylı kod rehberi ve mimari açıklamaları
- **[API Documentation](#)**: API endpoint'leri (yakında)

---

## 🧪 Test

```bash
# Unit testler
flutter test

# Widget testler
flutter test test/widget_test.dart

# Integration testler
flutter drive --target=test_driver/app.dart
```

---

## 🐛 Bilinen Sorunlar

- iOS'ta arka plan bildirimleri tam olarak garanti edilmez (iOS kısıtlamaları)
- Google Maps API key'i kullanım limitleri aşılırsa harita çalışmayabilir

---


## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen:

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

### Katkı Kuralları

- Kod standartlarına uyun (dart format)
- Test yazın
- Dokümantasyon güncelleyin
- Commit mesajlarını açıklayıcı yazın

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

---

## 👥 Ekip

### Bartu Erdem
- **Email**: [bartuerdem7153@gmail.com](mailto:bartuerdem7153@gmail.com)
- **LinkedIn**: [bartu-erdem](https://www.linkedin.com/in/bartu-erdem/)
- **GitHub**: [@bvrtu](https://github.com/bvrtu)

### Can Özer
- **Email**: [canozer.pirireis@gmail.com](mailto:canozer.pirireis@gmail.com)
- **LinkedIn**: [canozer1](https://www.linkedin.com/in/canozer1/)
- **GitHub**: [@nacrezo](https://github.com/nacrezo)

---

## 🙏 Teşekkürler

- **Kandilli Rasathanesi**: Deprem verileri için
- **Flutter Community**: Harika framework için
- **Firebase**: Backend altyapısı için
- **Tüm Katkıda Bulunanlar**: Projeye destekleri için

---

## 📞 İletişim

Sorularınız veya önerileriniz için:

- **GitHub Issues**: [Issues sayfası](https://github.com/bvrtu/QuakeConnectCop/issues)
- **Bartu Erdem**: [bartuerdem7153@gmail.com](mailto:bartuerdem7153@gmail.com) | [LinkedIn](https://www.linkedin.com/in/bartu-erdem/) | [GitHub](https://github.com/bvrtu)
- **Can Özer**: [canozer.pirireis@gmail.com](mailto:canozer.pirireis@gmail.com) | [LinkedIn](https://www.linkedin.com/in/canozer1/) | [GitHub](https://github.com/nacrezo)

---

<div align="center">

**⭐ Projeyi beğendiyseniz yıldız vermeyi unutmayın! ⭐**

</div>
