import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String phone;
  final String name;
  final String? email;
  final String? profileUrl;

  const UserEntity({
    required this.id,
    required this.phone,
    required this.name,
    this.email,
    this.profileUrl,
  });

  UserEntity copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    String? profileUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      profileUrl: profileUrl ?? this.profileUrl,
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      profileUrl: json['profile_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'profile_url': profileUrl,
    };
  }

  factory UserEntity.empty() {
    return const UserEntity(
      id: '',
      phone: '',
      name: '',
      email: null,
      profileUrl: null,
    );
  }

  @override
  List<Object?> get props => [id, phone, name, email, profileUrl];
}
