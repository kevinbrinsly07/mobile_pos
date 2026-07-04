import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String getDisplayMessage(Object? error) {
    if (error == null) return 'An unknown error occurred.';

    final errorStr = error.toString();

    // Check for network connectivity or server reachability issues
    if (error is SocketException ||
        errorStr.contains('SocketException') ||
        errorStr.contains('Failed host lookup') ||
        errorStr.contains('ClientException') ||
        errorStr.contains('AuthRetryableFetchException') ||
        errorStr.contains('OS Error: No address associated with hostname') ||
        errorStr.contains('Network connection lost') ||
        errorStr.contains('Connection timed out') ||
        errorStr.contains('Connection failed')) {
      return 'Connection error. Please check your internet connection and try again.';
    }

    if (error is AuthException) {
      return error.message;
    }

    if (error is PostgrestException) {
      return error.message;
    }

    return errorStr;
  }
}
