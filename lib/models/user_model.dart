class UserModel {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? photoURL;
  final String? location;
  final int? age;
  final int? heightCm;
  final int? weightKg;
  final List<String> disabilities;
  final String? disabilityOther;
  final int gradientIndex; // For avatar gradient
  final int followers;
  final int following;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.photoURL,
    this.location,
    this.age,
    this.heightCm,
    this.weightKg,
    List<String>? disabilities,
    this.disabilityOther,
    this.gradientIndex = 0,
    this.followers = 0,
    this.following = 0,
    required this.createdAt,
    this.updatedAt,
  }) : disabilities = disabilities ?? [];

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'displayName': displayName,
      'photoURL': photoURL,
      'location': location,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'disabilities': disabilities,
      'disabilityOther': disabilityOther,
      'gradientIndex': gradientIndex,
      'followers': followers,
      'following': following,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      displayName: map['displayName'] as String,
      photoURL: map['photoURL'] as String?,
      location: map['location'] as String?,
      age: map['age'] as int?,
      heightCm: map['heightCm'] as int?,
      weightKg: map['weightKg'] as int?,
      disabilities: (map['disabilities'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      disabilityOther: map['disabilityOther'] as String?,
      gradientIndex: map['gradientIndex'] as int? ?? 0,
      followers: map['followers'] as int? ?? 0,
      following: map['following'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
    );
  }

  // Create from Firebase Auth User
  factory UserModel.fromFirebaseAuth(String uid, String email, String? displayName, String? photoURL) {
    final username = email.split('@')[0]; // Default username from email
    return UserModel(
      id: uid,
      email: email,
      username: '@$username',
      displayName: displayName ?? username,
      photoURL: photoURL,
      createdAt: DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? photoURL,
    String? location,
    int? age,
    int? heightCm,
    int? weightKg,
    List<String>? disabilities,
    String? disabilityOther,
    int? gradientIndex,
    int? followers,
    int? following,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      location: location ?? this.location,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      disabilities: disabilities ?? this.disabilities,
      disabilityOther: disabilityOther ?? this.disabilityOther,
      gradientIndex: gradientIndex ?? this.gradientIndex,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

