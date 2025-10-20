import 'dart:io';
import 'package:postgres_pool/postgres_pool.dart';

final connection = PgPool(
  PgEndpoint(
    host: Platform.environment['DATABASE_HOSTNAME']!,
    port: int.parse(Platform.environment['DATABASE_PORT']!),
    database: Platform.environment['DATABASE_NAME']!,
    username: Platform.environment['DATABASE_USERNAME'],
    password: Platform.environment['DATABASE_SECRET'],
    requireSsl: false,
    
  ),
  settings: PgPoolSettings()
    ..maxConnectionAge = const Duration(days: 365 * 1000)
    ..concurrency = 1000,
 
);

