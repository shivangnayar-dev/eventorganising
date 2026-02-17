import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_manager.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../data/sources/admin_remote_source.dart';
import '../../data/sources/auth_remote_source.dart';
import '../../data/sources/booking_remote_source.dart';
import '../../data/sources/service_remote_source.dart';
import '../../domain/entities/service_listing.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/service_repository.dart';
import '../../domain/usecases/admin_usecases.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/booking_usecases.dart';
import '../../domain/usecases/service_usecases.dart';

// THEME
final themeProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) =>
    ThemeController(HiveManager.isDark ? ThemeMode.dark : ThemeMode.light));

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController(ThemeMode mode) : super(mode);

  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    await HiveManager.setThemeMode(next == ThemeMode.dark);
  }
}

// Remote sources
final authRemoteSourceProvider = Provider<AuthRemoteSource>((ref) {
  return AuthRemoteSource();
});

final serviceRemoteSourceProvider = Provider<ServiceRemoteSource>((ref) {
  return ServiceRemoteSource();
});

final bookingRemoteSourceProvider = Provider<BookingRemoteSource>((ref) {
  return BookingRemoteSource();
});

final adminRemoteSourceProvider = Provider<AdminRemoteSource>((ref) {
  return AdminRemoteSource();
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteSourceProvider));
});

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepositoryImpl(ref.read(serviceRemoteSourceProvider));
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(ref.read(bookingRemoteSourceProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.read(adminRemoteSourceProvider));
});

// Use cases
final authUseCasesProvider = Provider<AuthUseCases>((ref) {
  return AuthUseCases(ref.read(authRepositoryProvider));
});

final serviceUseCasesProvider = Provider<ServiceUseCases>((ref) {
  return ServiceUseCases(ref.read(serviceRepositoryProvider));
});

final bookingUseCasesProvider = Provider<BookingUseCases>((ref) {
  return BookingUseCases(ref.read(bookingRepositoryProvider));
});

final adminUseCasesProvider = Provider<AdminUseCases>((ref) {
  return AdminUseCases(ref.read(adminRepositoryProvider));
});

final publicServicesProvider =
    FutureProvider<List<ServiceListingEntity>>((ref) {
  return ref.read(serviceUseCasesProvider).fetchPublicServices();
});
