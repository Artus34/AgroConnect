class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; 
  final String? profileImageUrl; 


  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.profileImageUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      profileImageUrl: map['profileImageUrl'] as String?, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'profileImageUrl': profileImageUrl,
    };
  }

  
  
  UserModel copyWith({
    String? name,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: this.uid,
      name: name ?? this.name,
      email: this.email,
      role: this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}