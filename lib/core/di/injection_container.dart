import 'package:flutter/foundation.dart';

// Service Locator instance
final sl = ServiceLocator();

class ServiceLocator {
  final Map<Type, dynamic> _services = {};

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T is not registered');
    }
    return service as T;
  }

  void registerSingleton<T>(T service) {
    _services[T] = service;
  }

  void registerLazySingleton<T>(T Function() factory) {
    _services[T] = factory;
  }

  void registerFactory<T>(T Function() factory) {
    _services[T] = factory;
  }

  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  void reset() {
    _services.clear();
  }
}

Future<void> initializeDependencies() async {
  if (kDebugMode) {
    print('Initializing dependencies...');
  }

  // TODO: Register all dependencies here
  // This is a placeholder - we'll implement actual services later

  if (kDebugMode) {
    print('Dependencies initialized successfully');
  }
}
