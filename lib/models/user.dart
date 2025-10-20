// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:uresaxapp/apis/connection.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:uresaxapp/pages/login_page.dart';
import 'package:uuid/uuid.dart';

class User {
  String? id;
  String? name;
  String? username;
  String? password;
  int? roleId;
  String? roleName;
  DateTime? createdAt;
  List<String>? permissions;
  User(
      {this.id,
      this.name,
      this.username,
      this.password,
      this.roleId,
      this.roleName,
      this.createdAt,
      this.permissions});

  static Future<List<User>> all({
    bool searchMode = false,
    String words = ''
  }) async {
    try {
      var searchContext = '';

      if(words.isNotEmpty && searchMode){
          searchContext = ''' where (username like '%$words%' or name like '%$words%' or "role_name" like '%$words%') ''';
      }else{
        searchContext = '';
      }
      var result = await connection.mappedResultsQuery(
          '''SELECT * FROM public."UserView" $searchContext order by "created_at";''');

      return result.map((e) => User.fromMap(e['']!)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static User? current;

  static Future<User?> findUserById(String id) async {
    try {
      var result = await connection.mappedResultsQuery(
          '''SELECT * FROM public."UserView" WHERE "id" = '$id' ''');
      if (result.isEmpty) return null;
      var user = User.fromMap(result.first['']!);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> create() async {
    try {
      var id = const Uuid().v4();
      password = BCrypt.hashpw(password!, BCrypt.gensalt());

      var results = await connection.runTx((c) async {
        var r1 = await c.mappedResultsQuery(
            ''' select id from public."User" where "roleId" = 3 limit 1''');
        var xid = r1[0]['User']!['id'];

        if (xid != id && isSuperUser) {
          throw 'YA EXISTE UN SUPER USUARIO';
        }
        await c.query(
            '''INSERT INTO "User"(id,name,username,password,"roleId","Permissions") VALUES('$id','$name','$username','$password', $roleId, '${permissions?.toSet()}')''');
        var result = await c.mappedResultsQuery(
            '''SELECT * FROM public."UserView" WHERE "id" = '$id' ''');
        return [result];
      });

      return User.fromMap(results[0].first['']!);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> update() async {
    try {
      var results = await connection.runTx((c) async {
        var r1 = await c.mappedResultsQuery(
            ''' select id from public."User" where "roleId" = 3 limit 1''');
        var xid = r1[0]['User']!['id'];

        if (xid != id && isSuperUser) {
          throw 'YA EXISTE UN SUPER USUARIO';
        }

        await c.query(
            '''UPDATE public."User" SET "Permissions" = '${permissions?.toSet()}', "name" = '$name', "roleId" = $roleId, "username" = '$username' WHERE "id" = '$id';''');
        var result = await c.mappedResultsQuery(
            '''SELECT * FROM public."UserView" WHERE "id" = '$id';''');
        return [result];
      });

      var user = User.fromMap(results[0].first['']!);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete() async {
    try {
      await connection.query('''DELETE FROM public."User" WHERE id = '$id';''');
    } catch (e) {
      rethrow;
    }
  }

  static Future<User?> signIn(String username, String password) async {
    try {
      var result = await connection.mappedResultsQuery(
          '''SELECT * FROM public."UserView" WHERE "username" = '$username' ''');

      if (result.isEmpty) throw 'EL USUARIO NO EXISTE';

      var user = User.fromMap(result.first['']!);

      var isCorrect = BCrypt.checkpw(password, user.password!);

      if (isCorrect) {
        current = user;
        return user;
      } else {
        throw 'LA CONTRASEÑA NO ES CORRECTA';
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> loggout(BuildContext context) async {
    try {
      await SessionManager().destroy();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (ctx) => const LoginPage()),
          (route) => false);
     
    } catch (e) {
      rethrow;
    }
  }

  editPassword(String currentPassword, String newPassword) async {
    try {
      var result = await connection.mappedResultsQuery(
          ''' select * from public."User" where id = '$id' ''');

      var user = User.fromMap(result.first['User']!);

      var isCorrect = BCrypt.checkpw(currentPassword, user.password!);

      var newPass = BCrypt.hashpw(newPassword, BCrypt.gensalt());

      if (isCorrect) {
        await connection.mappedResultsQuery(
            '''update public."User" set password = '$newPass' where id = '$id';''');
      } else {
        throw 'LA CONTRASEÑA NO ES CORRECTA';
      }
    } catch (e) {
      rethrow;
    }
  }

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    int? roleId,
    String? roleName,
    List<String>? permissions,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isAdmin {
    return roleId == 1;
  }

  bool get isEditor {
    return roleId == 2;
  }

  bool get isSuperUser {
    return roleId == 3;
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({'id': id});
    }
    if (name != null) {
      result.addAll({'name': name});
    }
    if (username != null) {
      result.addAll({'username': username});
    }
    if (password != null) {
      result.addAll({'password': password});
    }
    if (roleId != null) {
      result.addAll({'roleId': roleId});
    }
    if (roleName != null) {
      result.addAll({'role_name': roleName});
    }
    if (createdAt != null) {
      result.addAll({'created_at': createdAt!.millisecondsSinceEpoch});
    }

    if (permissions != null) {
      result.addAll({'Permissions': permissions});
    }

    return result;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        id: map['id'],
        name: map['name'],
        username: map['username'],
        password: map['password'],
        roleId: map['roleId']?.toInt(),
        roleName: map['role_name'],
        permissions:
            map['Permissions']?.map((e) => e).toList().cast<String>() ?? [],
        createdAt: map['created_at'] is int
            ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
            : map['created_at']);
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(id: $id, name: $name, username: $username, password: $password, roleId: $roleId, roleName: $roleName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.username == username &&
        other.password == password &&
        other.roleId == roleId &&
        other.roleName == roleName &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        username.hashCode ^
        password.hashCode ^
        roleId.hashCode ^
        roleName.hashCode ^
        createdAt.hashCode;
  }
}
