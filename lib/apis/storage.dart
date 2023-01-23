
import 'package:flutter_session_manager/flutter_session_manager.dart';
class Storage {
  Storage._();

  static final instance = Storage._();

   SessionManager? _storage;

    SessionManager? get storage {
    if (_storage != null) return _storage;
    _storage =  SessionManager();
    return _storage;
  }
}
