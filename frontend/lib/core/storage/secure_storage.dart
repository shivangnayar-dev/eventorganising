import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import for web
import 'secure_storage_stub.dart'
    if (dart.library.html) 'secure_storage_web.dart' as web_storage;

/// Shared storage instance with web localStorage fallback for HTTP contexts
/// On web HTTP (non-secure), uses localStorage directly (FlutterSecureStorage requires HTTPS)
/// On web HTTPS (secure), uses FlutterSecureStorage
/// On mobile, uses FlutterSecureStorage for secure storage
class SecureStorage {
  SecureStorage._();
  
  static final SecureStorage instance = SecureStorage._();
  
  FlutterSecureStorage? _secureStorage;
  bool _useLocalStorage = false;
  bool _initialized = false;
  
  // Initialize storage - try FlutterSecureStorage first, fall back to localStorage on error
  Future<void> _initStorage() async {
    if (_initialized) return;
    _initialized = true;
    
    if (!kIsWeb) {
      // On mobile, always use FlutterSecureStorage
      _secureStorage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
      return;
    }
    
    // On web, try FlutterSecureStorage first
    try {
      _secureStorage = FlutterSecureStorage(
        webOptions: const WebOptions(
          useSessionStorage: false,
        ),
      );
      // Try a test operation to see if it works (this will throw if not in secure context)
      await _secureStorage!.write(key: '__test__', value: 'test');
      await _secureStorage!.delete(key: '__test__');
      // If we get here, FlutterSecureStorage works (HTTPS)
      _useLocalStorage = false;
    } catch (e) {
      // FlutterSecureStorage failed (likely HTTP context), use localStorage
      _useLocalStorage = true;
      _secureStorage = null;
    }
  }
  
  Future<String?> read(String key) async {
    await _initStorage();
    if (_useLocalStorage) {
      try {
        return web_storage.WebStorage.read(key);
      } catch (e) {
        return null;
      }
    }
    if (_secureStorage != null) {
      try {
        return await _secureStorage!.read(key: key);
      } catch (e) {
        // If secure storage fails at runtime, fall back to localStorage
        if (kIsWeb) {
          _useLocalStorage = true;
          _secureStorage = null;
          return web_storage.WebStorage.read(key);
        }
        rethrow;
      }
    }
    return null;
  }
  
  Future<void> write(String key, String value) async {
    await _initStorage();
    if (_useLocalStorage) {
      try {
        web_storage.WebStorage.write(key, value);
        return;
      } catch (e) {
        // Ignore errors
        return;
      }
    }
    if (_secureStorage != null) {
      try {
        await _secureStorage!.write(key: key, value: value);
        return;
      } catch (e) {
        // If secure storage fails at runtime, fall back to localStorage
        if (kIsWeb) {
          _useLocalStorage = true;
          _secureStorage = null;
          web_storage.WebStorage.write(key, value);
          return;
        }
        rethrow;
      }
    }
  }
  
  Future<void> delete(String key) async {
    await _initStorage();
    if (_useLocalStorage) {
      try {
        web_storage.WebStorage.delete(key);
        return;
      } catch (e) {
        return;
      }
    }
    if (_secureStorage != null) {
      try {
        await _secureStorage!.delete(key: key);
        return;
      } catch (e) {
        if (kIsWeb) {
          _useLocalStorage = true;
          _secureStorage = null;
          web_storage.WebStorage.delete(key);
          return;
        }
        rethrow;
      }
    }
  }
  
  Future<Map<String, String>> readAll() async {
    await _initStorage();
    if (_useLocalStorage) {
      try {
        // localStorage doesn't have readAll, iterate through all keys
        final Map<String, String> result = {};
        // We can't easily iterate localStorage keys in Dart, so return empty
        // This is only used for debugging anyway
        return result;
      } catch (e) {
        return {};
      }
    }
    if (_secureStorage != null) {
      try {
        return await _secureStorage!.readAll();
      } catch (e) {
        if (kIsWeb) {
          _useLocalStorage = true;
          _secureStorage = null;
          return {};
        }
        rethrow;
      }
    }
    return {};
  }
  
  Future<void> deleteAll() async {
    await _initStorage();
    if (_useLocalStorage) {
      try {
        web_storage.WebStorage.clear();
        return;
      } catch (e) {
        return;
      }
    }
    if (_secureStorage != null) {
      try {
        await _secureStorage!.deleteAll();
        return;
      } catch (e) {
        if (kIsWeb) {
          _useLocalStorage = true;
          _secureStorage = null;
          web_storage.WebStorage.clear();
          return;
        }
        rethrow;
      }
    }
  }
  
  Future<bool> containsKey(String key) async {
    await _initStorage();
    if (_useLocalStorage) {
      try {
        return web_storage.WebStorage.containsKey(key);
      } catch (e) {
        return false;
      }
    }
    if (_secureStorage != null) {
      try {
        return await _secureStorage!.containsKey(key: key);
      } catch (e) {
        if (kIsWeb) {
          _useLocalStorage = true;
          _secureStorage = null;
          return web_storage.WebStorage.containsKey(key);
        }
        return false;
      }
    }
    return false;
  }
}

