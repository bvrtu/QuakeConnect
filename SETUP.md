# 🔧 QuakeConnect Kurulum Rehberi

Bu dosya, QuakeConnect projesini yerel ortamınızda çalıştırmak için gerekli adımları içerir.

## ⚠️ ÖNEMLİ: Hassas Dosyalar

Aşağıdaki dosyalar güvenlik nedeniyle git repository'sine dahil edilmemiştir. Bu dosyaları oluşturmanız **ZORUNLUDUR**:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

## 📋 Ön Gereksinimler

1. **Flutter SDK** (3.8.1 veya üzeri)
   ```bash
   flutter --version
   ```

2. **Firebase Hesabı**
   - [Firebase Console](https://console.firebase.google.com/) üzerinden proje oluşturun

3. **Google Cloud Console**
   - Google Maps API key'i için
   - Google Sign-In için OAuth 2.0 client ID'leri

## 🚀 Kurulum Adımları

### 1. Repository'yi Klonlayın

```bash
git clone https://github.com/YOUR_USERNAME/QuakeConnect.git
cd QuakeConnect
```

### 2. Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### 3. Firebase Yapılandırması

#### Android için

1. Firebase Console'a gidin
2. Proje Ayarları > Genel sekmesine gidin
3. "Android uygulamanızı ekleyin" butonuna tıklayın
4. Paket adını girin: `com.example.quakeconnect`
5. `google-services.json` dosyasını indirin
6. Dosyayı `android/app/` klasörüne kopyalayın

**Veya örnek dosyayı kullanın:**
```bash
cp android/app/google-services.json.example android/app/google-services.json
# Sonra dosyayı düzenleyip gerçek değerlerle doldurun
```

#### iOS için

1. Firebase Console'a gidin
2. Proje Ayarları > Genel sekmesine gidin
3. "iOS uygulamanızı ekleyin" butonuna tıklayın
4. Bundle ID'yi girin: `com.example.quakeconnect`
5. `GoogleService-Info.plist` dosyasını indirin
6. Dosyayı `ios/Runner/` klasörüne kopyalayın
7. Xcode'da projeyi açın (`ios/Runner.xcworkspace`)
8. Dosyayı Xcode projesine sürükleyip bırakın (Copy items if needed seçeneğini işaretleyin)

**Veya örnek dosyayı kullanın:**
```bash
cp ios/Runner/GoogleService-Info.plist.example ios/Runner/GoogleService-Info.plist
# Sonra dosyayı düzenleyip gerçek değerlerle doldurun
```

#### Firebase Options Dosyası

**Yöntem 1: FlutterFire CLI (Önerilen)**

```bash
# FlutterFire CLI'yi yükleyin (eğer yoksa)
dart pub global activate flutterfire_cli

# Firebase'e giriş yapın
firebase login

# Firebase projesini yapılandırın
flutterfire configure
```

**Yöntem 2: Manuel Oluşturma**

1. `lib/firebase_options.example.dart` dosyasını kopyalayın:
   ```bash
   cp lib/firebase_options.example.dart lib/firebase_options.dart
   ```

2. Firebase Console'dan aldığınız değerleri `lib/firebase_options.dart` dosyasına doldurun:
   - Android: `apiKey`, `appId`, `messagingSenderId`, `projectId`, `storageBucket`
   - iOS: `apiKey`, `appId`, `messagingSenderId`, `projectId`, `storageBucket`, `iosBundleId`

### 4. Google Maps API Key

#### Google Cloud Console'da

1. [Google Cloud Console](https://console.cloud.google.com/)'a gidin
2. Yeni bir proje oluşturun veya mevcut projeyi seçin
3. "APIs & Services" > "Credentials" sekmesine gidin
4. "Create Credentials" > "API Key" seçin
5. API key'i kopyalayın
6. "API restrictions" bölümünden "Restrict key" seçin
7. Şu API'leri etkinleştirin:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API

#### Android'de Kullanım

`android/app/src/main/AndroidManifest.xml` dosyasını açın ve şu satırı ekleyin/güncelleyin:

```xml
<application>
    ...
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY" />
</application>
```

#### iOS'te Kullanım

**AppDelegate.swift:**

`ios/Runner/AppDelegate.swift` dosyasını açın ve şu satırı ekleyin/güncelleyin:

```swift
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Info.plist:**

`ios/Runner/Info.plist` dosyasına da ekleyin:

```xml
<key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY</string>
```

**Kod İçinde:**

Aşağıdaki dosyalarda da API key'i güncelleyin:
- `lib/screens/profile_screen.dart` (line 2825)
- `lib/screens/onboarding/personal_info_onboarding_screen.dart` (line 54)

### 5. Google Sign-In Yapılandırması

#### Google Cloud Console'da

1. "APIs & Services" > "Credentials" sekmesine gidin
2. "Create Credentials" > "OAuth 2.0 Client ID" seçin
3. Application type: "iOS" seçin
4. Bundle ID: `com.example.quakeconnect` girin
5. Client ID'yi kopyalayın (REVERSED_CLIENT_ID olarak kullanılacak)

#### iOS Yapılandırması

1. `ios/Runner/Info.plist` dosyasını açın
2. `CFBundleURLTypes` bölümüne şunu ekleyin:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>googlechrome</string>
    <string>https</string>
    <string>http</string>
</array>
```

3. `ios/Runner/AppDelegate.swift` dosyasına URL handling ekleyin:

```swift
import GoogleSignIn

override func application(
  _ app: UIApplication,
  open url: URL,
  options: [UIApplication.OpenURLOptionsKey : Any] = [:]
) -> Bool {
  var handled: Bool
  handled = GIDSignIn.sharedInstance.handle(url)
  if handled {
    return true
  }
  return false
}
```

#### Android Yapılandırması

Android için genellikle `google-services.json` dosyası yeterlidir. Ek bir yapılandırma gerekmez.

#### Kod İçinde

`lib/services/auth_service.dart` dosyasında (line 18) `serverClientId` değerini güncelleyin:

```dart
serverClientId: 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com',
```

### 6. Uygulamayı Çalıştırın

```bash
# Android
flutter run

# iOS
flutter run

# Belirli bir cihaz için
flutter devices
flutter run -d <device_id>
```

## ✅ Kontrol Listesi

Kurulum tamamlandıktan sonra şunları kontrol edin:

- [ ] `android/app/google-services.json` dosyası mevcut ve doğru değerlerle doldurulmuş
- [ ] `ios/Runner/GoogleService-Info.plist` dosyası mevcut, doğru değerlerle doldurulmuş ve Xcode projesine eklenmiş
- [ ] `lib/firebase_options.dart` dosyası mevcut ve doğru değerlerle doldurulmuş
- [ ] Google Maps API key'i Android ve iOS'ta yapılandırılmış
- [ ] Google Sign-In iOS'ta yapılandırılmış
- [ ] Uygulama başarıyla çalışıyor
- [ ] Firebase Authentication çalışıyor
- [ ] Google Sign-In çalışıyor
- [ ] Harita görüntüleniyor

## 🐛 Sorun Giderme

### Firebase bağlantı hatası

- Firebase projesinin doğru yapılandırıldığından emin olun
- `google-services.json` ve `GoogleService-Info.plist` dosyalarının doğru konumda olduğunu kontrol edin
- Firebase Console'da proje ayarlarını kontrol edin

### Google Maps görünmüyor

- API key'in doğru yapılandırıldığından emin olun
- Google Cloud Console'da Maps SDK'nın etkinleştirildiğini kontrol edin
- API key kısıtlamalarını kontrol edin

### Google Sign-In çalışmıyor (iOS)

- `Info.plist` dosyasındaki URL scheme'leri kontrol edin
- `AppDelegate.swift` dosyasındaki URL handling'i kontrol edin
- `GoogleService-Info.plist` dosyasındaki `REVERSED_CLIENT_ID` değerini kontrol edin

### Bildirimler çalışmıyor

- Android: Bildirim izinlerini kontrol edin
- iOS: Bildirim izinlerini kontrol edin
- Firebase Cloud Messaging yapılandırmasını kontrol edin

## 📚 Ek Kaynaklar

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

## 💡 İpuçları

- API key'leri asla commit etmeyin
- `.gitignore` dosyasının güncel olduğundan emin olun
- Production'da API key kısıtlamaları kullanın
- Firebase Security Rules'ı yapılandırın
- Google Cloud Console'da kullanım limitlerini ayarlayın

---

**Not**: Bu dosya sadece bir rehberdir. Gerçek yapılandırma adımları projenin gereksinimlerine göre değişebilir.

