enum UserRole {
  TURIST,
  REHBER,
}

class AppUser {
  final String id;
  final String email;
  final String name;
  final String surname;
  final UserRole role;
  final Map<String, dynamic> userData;
  final String? profilePhoto;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.role,
    required this.userData,
    this.profilePhoto,
  });

  factory AppUser.fromFirebaseAuth({
    required String uid,
    required String email,
    required Map<String, dynamic> userData,
    required bool isRehber,
  }) {
    // Firebase'deki 'id' alanını kullan (rehber/turist database'indeki gerçek ID)
    final userId = userData['id'] ?? uid;
    
    print('🆔 AppUser.fromFirebaseAuth:');
    print('   Firebase Auth UID: $uid');
    print('   Email: $email');
    print('   Is Rehber: $isRehber');
    
    return AppUser(
      id: userId, // Firebase'deki 'id' alanını kullan
      email: email,
      name: userData['isim'] ?? '',
      surname: userData['soyisim'] ?? '',
      role: isRehber ? UserRole.REHBER : UserRole.TURIST,
      userData: userData,
      profilePhoto: userData['profilfoto'] ?? userData['profilePhoto'],
    );
  }

  bool get isGuide => role == UserRole.REHBER;
  bool get isTourist => role == UserRole.TURIST;

  String get fullName => '$name $surname'.trim();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'surname': surname,
      'role': role.toString(),
      'userData': userData,
      'profilePhoto': profilePhoto,
    };
  }
} 