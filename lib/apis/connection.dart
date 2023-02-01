import 'dart:io';
//import 'package:postgres/postgres.dart';
import 'package:postgres_pool/postgres_pool.dart';


 final connection = PgPool(
    PgEndpoint(
      host: Platform.environment['DATABASE_HOSTNAME']!,
      port: int.parse(Platform.environment['DATABASE_PORT']!),
      database: Platform.environment['DATABASE_NAME']!,
      username: Platform.environment['DATABASE_USERNAME'],
      password: Platform.environment['DATABASE_USER_PASSWORD'],
    ),
    settings: PgPoolSettings()
      ..maxConnectionAge = const Duration(days: 365 * 1000)
      ..concurrency = 1000,
      
  );


/*var connection = PostgreSQLConnection(
    Platform.environment['DATABASE_HOSTNAME']!,
    int.parse(Platform.environment['DATABASE_PORT']!),
    Platform.environment['DATABASE_NAME']!,
    username: Platform.environment['DATABASE_USERNAME'],
    password: Platform.environment['DATABASE_USER_PASSWORD'],timeoutInSeconds: 80);*/
