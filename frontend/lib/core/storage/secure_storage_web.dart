// Web-specific storage implementation
// This file is only used when dart.library.html is available

import 'dart:html' as html;

class WebStorage {
  static String? read(String key) {
    try {
      return html.window.localStorage[key];
    } catch (e) {
      return null;
    }
  }

  static void write(String key, String value) {
    try {
      html.window.localStorage[key] = value;
    } catch (e) {
      // Ignore errors
    }
  }

  static void delete(String key) {
    try {
      html.window.localStorage.remove(key);
    } catch (e) {
      // Ignore errors
    }
  }

  static void clear() {
    try {
      html.window.localStorage.clear();
    } catch (e) {
      // Ignore errors
    }
  }

  static bool containsKey(String key) {
    try {
      return html.window.localStorage.containsKey(key);
    } catch (e) {
      return false;
    }
  }
}

