import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_event.dart';
part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const String _localeKey = 'selected_locale';

  static const supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('ku'),
  ];

  LocaleBloc() : super(const LocaleState(locale: Locale('en'))) {
    on<LocaleLoaded>(_onLocaleLoaded);
    on<LocaleChanged>(_onLocaleChanged);
  }

  Future<void> _onLocaleLoaded(
    LocaleLoaded event,
    Emitter<LocaleState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);

    if (localeCode != null) {
      final locale = Locale(localeCode);
      if (supportedLocales.contains(locale)) {
        emit(state.copyWith(locale: locale));
      }
    }
  }

  Future<void> _onLocaleChanged(
    LocaleChanged event,
    Emitter<LocaleState> emit,
  ) async {
    if (supportedLocales.contains(event.locale)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, event.locale.languageCode);
      emit(state.copyWith(locale: event.locale));
    }
  }
}
