# 🌍 QuakeConnect

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)

**Türkiye için gerçek zamanlı deprem izleme ve topluluk platformu**

[Özellikler](#-özellikler) • [Kurulum](#-kurulum) • [Kullanım](#-kullanım)

</div>

---

## 📖 Hakkında

QuakeConnect, Türkiye'deki depremleri gerçek zamanlı olarak izleyen, kullanıcıların güvenlik durumlarını paylaşabileceği ve topluluk desteği alabileceği kapsamlı bir mobil uygulamadır.

---

## ✨ Özellikler

- 🌐 **Gerçek Zamanlı Deprem İzleme**: Kandilli Rasathanesi API'sinden anlık deprem verileri
- 🔔 **Akıllı Bildirimler**: Özelleştirilebilir deprem uyarıları
- 👥 **Topluluk Desteği**: "I'm Safe", "Need Help" ve bilgi paylaşımı
- 🗺️ **Google Maps Entegrasyonu**: Depremleri haritada görüntüleme
- 🔐 **Kimlik Doğrulama**: Email/Password ve Google Sign-In
- 📱 **Cross-Platform**: Android ve iOS desteği

---

## 🚀 Kurulum

### ⚠️ ÖNEMLİ: İlk Kurulum

Bu proje Firebase ve Google Maps API key'leri gerektirir. Bu dosyalar güvenlik nedeniyle git repository'sine dahil edilmemiştir.

**📖 Detaylı kurulum rehberi için [SETUP.md](SETUP.md) dosyasına bakın.**

### Hızlı Başlangıç

1. **Repository'yi klonlayın**
   ```bash
   git clone https://github.com/YOUR_USERNAME/QuakeConnect.git
   cd QuakeConnect
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **Firebase yapılandırması** (ZORUNLU)
   - `android/app/google-services.json` dosyasını oluşturun
   - `ios/Runner/GoogleService-Info.plist` dosyasını oluşturun
   - `lib/firebase_options.dart` dosyasını oluşturun
   
   Detaylar için [SETUP.md](SETUP.md) dosyasına bakın.

4. **Google Maps API Key** (ZORUNLU)
   - Android ve iOS için API key'leri yapılandırın
   - Detaylar için [SETUP.md](SETUP.md) dosyasına bakın.

5. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

---

## 📚 Dokümantasyon

- **[SETUP.md](SETUP.md)**: Detaylı kurulum rehberi ve yapılandırma adımları
- **[CODE_GUIDE.md](CODE_GUIDE.md)**: Kod rehberi ve mimari açıklamaları (varsa)

---

## 🛠️ Teknolojiler

- **Flutter**: 3.8.1
- **Firebase**: Authentication, Firestore, Storage
- **Google Maps**: Harita entegrasyonu
- **Workmanager**: Arka plan görevleri
- **Flutter Local Notifications**: Bildirimler

---

## 🔐 Güvenlik

### Hassas Dosyalar

Aşağıdaki dosyalar `.gitignore`'a eklenmiştir ve **ASLA** commit edilmemelidir:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

### Örnek Dosyalar

Projede örnek dosyalar mevcuttur:
- `android/app/google-services.json.example`
- `ios/Runner/GoogleService-Info.plist.example`
- `lib/firebase_options.example.dart`

Bu dosyaları kopyalayıp gerçek değerlerle doldurun.

---

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen:

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

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

## 📞 İletişim

Sorularınız veya önerileriniz için:

- **GitHub Issues**: [Issues sayfası](https://github.com/bvrtu/QuakeConnect/issues)
- **Bartu Erdem**: [bartuerdem7153@gmail.com](mailto:bartuerdem7153@gmail.com) | [LinkedIn](https://www.linkedin.com/in/bartu-erdem/) | [GitHub](https://github.com/bvrtu)
- **Can Özer**: [canozer.pirireis@gmail.com](mailto:canozer.pirireis@gmail.com) | [LinkedIn](https://www.linkedin.com/in/canozer1/) | [GitHub](https://github.com/nacrezo)

---

<div align="center">

**⭐ Projeyi beğendiyseniz yıldız vermeyi unutmayın! ⭐**

</div>
