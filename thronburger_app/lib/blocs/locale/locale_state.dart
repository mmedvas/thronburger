part of 'locale_bloc.dart';

class LocaleState extends Equatable {
  final Locale locale;

  const LocaleState({required this.locale});

  static const defaultLocale = Locale('en');

  bool get isRtl => locale.languageCode == 'ar' || locale.languageCode == 'ku';

  @override
  List<Object?> get props => [locale];

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale: locale ?? this.locale);
  }
}
