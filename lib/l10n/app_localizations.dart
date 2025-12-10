import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'NEON FLIP'**
  String get title;

  /// No description provided for @combat.
  ///
  /// In en, this message translates to:
  /// **'COMBAT'**
  String get combat;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'ONLINE 1VS1'**
  String get online;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'ALBUM'**
  String get album;

  /// No description provided for @deck_full.
  ///
  /// In en, this message translates to:
  /// **'The bench is full!'**
  String get deck_full;

  /// No description provided for @start_game.
  ///
  /// In en, this message translates to:
  /// **'START GAME'**
  String get start_game;

  /// No description provided for @my_collection.
  ///
  /// In en, this message translates to:
  /// **'My Collection'**
  String get my_collection;

  /// No description provided for @key_copied.
  ///
  /// In en, this message translates to:
  /// **'Key copied!'**
  String get key_copied;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'CONNECT'**
  String get connect;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @instructions_deck.
  ///
  /// In en, this message translates to:
  /// **'Swipe DOWN to pick, SIDE to discard'**
  String get instructions_deck;

  /// No description provided for @your_access_key.
  ///
  /// In en, this message translates to:
  /// **'Your Access Key:'**
  String get your_access_key;

  /// No description provided for @enter_key.
  ///
  /// In en, this message translates to:
  /// **'Enter Key:'**
  String get enter_key;

  /// No description provided for @create_game.
  ///
  /// In en, this message translates to:
  /// **'CREATE GAME'**
  String get create_game;

  /// No description provided for @search_game.
  ///
  /// In en, this message translates to:
  /// **'SEARCH GAME'**
  String get search_game;

  /// No description provided for @waiting_opponent.
  ///
  /// In en, this message translates to:
  /// **'Waiting for opponent...'**
  String get waiting_opponent;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @getting_ip.
  ///
  /// In en, this message translates to:
  /// **'Getting IP...'**
  String get getting_ip;

  /// No description provided for @ip_error.
  ///
  /// In en, this message translates to:
  /// **'Could not get IP. Connect to WiFi.'**
  String get ip_error;

  /// No description provided for @connected_starting.
  ///
  /// In en, this message translates to:
  /// **'Connected! Starting...'**
  String get connected_starting;

  /// No description provided for @connection_error.
  ///
  /// In en, this message translates to:
  /// **'Connection error or disconnected.'**
  String get connection_error;

  /// No description provided for @invalid_key.
  ///
  /// In en, this message translates to:
  /// **'Invalid key or host not found.'**
  String get invalid_key;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'POWER'**
  String get power;

  /// No description provided for @ultimate_edition.
  ///
  /// In en, this message translates to:
  /// **'ULTIMATE EDITION'**
  String get ultimate_edition;

  /// No description provided for @your_turn.
  ///
  /// In en, this message translates to:
  /// **'YOUR TURN!'**
  String get your_turn;

  /// No description provided for @summoning.
  ///
  /// In en, this message translates to:
  /// **'Summoning'**
  String get summoning;

  /// No description provided for @won_round.
  ///
  /// In en, this message translates to:
  /// **'YOU WON THE ROUND!'**
  String get won_round;

  /// No description provided for @lost_round.
  ///
  /// In en, this message translates to:
  /// **'ROUND LOST...'**
  String get lost_round;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'DRAW'**
  String get draw;

  /// No description provided for @victory.
  ///
  /// In en, this message translates to:
  /// **'VICTORY!'**
  String get victory;

  /// No description provided for @defeat.
  ///
  /// In en, this message translates to:
  /// **'DEFEAT...'**
  String get defeat;

  /// No description provided for @open_pack.
  ///
  /// In en, this message translates to:
  /// **'OPEN PACK'**
  String get open_pack;

  /// No description provided for @return_menu.
  ///
  /// In en, this message translates to:
  /// **'RETURN TO MENU'**
  String get return_menu;

  /// No description provided for @pick_card.
  ///
  /// In en, this message translates to:
  /// **'Pick a card!'**
  String get pick_card;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @no_cards_yet.
  ///
  /// In en, this message translates to:
  /// **'No cards yet.'**
  String get no_cards_yet;

  /// No description provided for @game_over.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get game_over;

  /// No description provided for @epic_pack.
  ///
  /// In en, this message translates to:
  /// **'EPIC PACK'**
  String get epic_pack;

  /// No description provided for @new_cards.
  ///
  /// In en, this message translates to:
  /// **'NEW CARDS!'**
  String get new_cards;

  /// No description provided for @rematch.
  ///
  /// In en, this message translates to:
  /// **'REMATCH'**
  String get rematch;

  /// No description provided for @play_again.
  ///
  /// In en, this message translates to:
  /// **'PLAY AGAIN'**
  String get play_again;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'MENU'**
  String get menu;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
