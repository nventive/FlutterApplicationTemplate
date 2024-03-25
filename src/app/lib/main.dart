import 'package:app/access/dad_jokes/dad_jokes_repository.dart';
import 'package:app/access/dad_jokes/favorite_dad_jokes_repository.dart';
import 'package:app/app.dart';
import 'package:app/business/dad_jokes/dad_jokes_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() {
  _registerHttpClient();
  _registerRepositories();
  _registerServices();
  runApp(const App());
}

/// Registers the HTTP client.
void _registerHttpClient() {
  GetIt.I.registerSingleton<Dio>(Dio());
}

/// Registers the repositories.
void _registerRepositories() {
  GetIt.I.registerSingleton(
    DadJokesRepository(
      GetIt.I.get<Dio>(),
    ),
  );
  GetIt.I.registerSingleton(FavoriteDadJokesRepository());
}

/// Registers the services.
void _registerServices() {
  GetIt.I.registerSingleton(
    DadJokesService(
      GetIt.I.get<DadJokesRepository>(),
      GetIt.I.get<FavoriteDadJokesRepository>(),
    ),
  );
}
