import 'dart:io';
import 'package:postgres/postgres.dart';

var connection = PostgreSQLConnection(
    Platform.environment['DATABASE_HOSTNAME']!,
    int.parse(Platform.environment['DATABASE_PORT']!),
    Platform.environment['DATABASE_NAME']!,
    username: Platform.environment['DATABASE_USERNAME'],
    password: Platform.environment['DATABASE_USER_PASSWORD']);
