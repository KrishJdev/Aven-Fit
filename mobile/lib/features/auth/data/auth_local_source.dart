import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure-storage keys — Android Keystore-backed via
/// flutter_secure_storage (WU-5.1). One namespace, flat keys.
abstract final class AuthStorageKeys {
  static const accessToken = 'avenfit.access_token';
  static const refreshToken = 'avenfit.refresh_token';
  static const userId = 'avenfit.user_id';
  static const displayName = 'avenfit.display_name';
  static const phoneNumber = 'avenfit.phone_number';

  /// The guest identity deliberately survives [AuthLocalSource.clearSession]
  /// — sign-out returns to the *same* anonymous identity so previously
  /// linked local data stays addressable (§6.2, L7).
  static const guestUuid = 'avenfit.guest_uuid';
}

/// Persisted session snapshot (data-layer carrier — the UI sees
/// [AuthState], never secure-storage details).
class StoredAuthSession {
  const StoredAuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    this.displayName,
    this.phoneNumber,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String? displayName;
  final String? phoneNumber;
}

/// Secure token + guest-identity store (WU-5.1, FEATURES.md §6).
///
/// Methods throw on platform failure; the repository decides the
/// fail-safe fallback (L2 — a broken store must never block boot).
class AuthLocalSource {
  AuthLocalSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  /// The stored session, or null when absent/partial — a token pair
  /// without a user id is unusable and treated as signed out.
  Future<StoredAuthSession?> readSession() async {
    final accessToken = await _storage.read(key: AuthStorageKeys.accessToken);
    final refreshToken =
        await _storage.read(key: AuthStorageKeys.refreshToken);
    final userId = await _storage.read(key: AuthStorageKeys.userId);
    if (accessToken == null || refreshToken == null || userId == null) {
      return null;
    }
    return StoredAuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      displayName: await _storage.read(key: AuthStorageKeys.displayName),
      phoneNumber: await _storage.read(key: AuthStorageKeys.phoneNumber),
    );
  }

  Future<void> writeSession(StoredAuthSession session) async {
    await _storage.write(
      key: AuthStorageKeys.accessToken,
      value: session.accessToken,
    );
    await _storage.write(
      key: AuthStorageKeys.refreshToken,
      value: session.refreshToken,
    );
    await _storage.write(key: AuthStorageKeys.userId, value: session.userId);
    if (session.displayName != null) {
      await _storage.write(
        key: AuthStorageKeys.displayName,
        value: session.displayName!,
      );
    }
    if (session.phoneNumber != null) {
      await _storage.write(
        key: AuthStorageKeys.phoneNumber,
        value: session.phoneNumber!,
      );
    }
  }

  /// Clears the token pair + profile fields; the guest UUID survives
  /// (sign-out returns to the same anonymous identity, §6.2).
  Future<void> clearSession() async {
    await _storage.delete(key: AuthStorageKeys.accessToken);
    await _storage.delete(key: AuthStorageKeys.refreshToken);
    await _storage.delete(key: AuthStorageKeys.userId);
    await _storage.delete(key: AuthStorageKeys.displayName);
    await _storage.delete(key: AuthStorageKeys.phoneNumber);
  }

  /// The stable guest identity used to link local data on a later
  /// sign-in (§6.2 — created once, never regenerated).
  Future<String> readOrCreateGuestUuid() async {
    final existing = await _storage.read(key: AuthStorageKeys.guestUuid);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final uuid = generateUuidV4();
    await _storage.write(key: AuthStorageKeys.guestUuid, value: uuid);
    return uuid;
  }
}

/// RFC 4122 v4 UUID without a dependency — client-generated UUIDs are
/// the sync contract's identity unit (J6), so a guest needs one from the
/// very first launch.
String generateUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 4122 variant
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
