// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  email: json['email'] as String,
  role: $enumDecode(_$RoleEnumMap, json['role']),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'email': instance.email,
  'role': _$RoleEnumMap[instance.role]!,
};

const _$RoleEnumMap = {Role.user: 'user', Role.admin: 'admin'};
