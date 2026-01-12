import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tic Tac Toe'**
  String get appTitle;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @chooseGameMode.
  ///
  /// In en, this message translates to:
  /// **'Choose a game mode.'**
  String get chooseGameMode;

  /// No description provided for @localModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Mode'**
  String get localModeTitle;

  /// No description provided for @localModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Play on the same device'**
  String get localModeDescription;

  /// No description provided for @onlineModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Online Play'**
  String get onlineModeTitle;

  /// No description provided for @onlineModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Play with another player online'**
  String get onlineModeDescription;

  /// No description provided for @onlineOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Online Play'**
  String get onlineOptionsTitle;

  /// No description provided for @onlineOptionsChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose an option'**
  String get onlineOptionsChoose;

  /// No description provided for @createRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Room'**
  String get createRoomTitle;

  /// No description provided for @createRoomDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a room for others to join'**
  String get createRoomDescription;

  /// No description provided for @waitingPlayer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a player to connect...'**
  String get waitingPlayer;

  /// No description provided for @serverIpLabel.
  ///
  /// In en, this message translates to:
  /// **'IP:'**
  String get serverIpLabel;

  /// No description provided for @connectRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a Room'**
  String get connectRoomTitle;

  /// No description provided for @serverIpInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Server IP'**
  String get serverIpInputLabel;

  /// No description provided for @serverIpInputHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 192.168.1.100'**
  String get serverIpInputHint;

  /// No description provided for @connectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectButton;

  /// No description provided for @errorCreateServer.
  ///
  /// In en, this message translates to:
  /// **'Error creating server'**
  String get errorCreateServer;

  /// No description provided for @errorEmptyIp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the server IP'**
  String get errorEmptyIp;

  /// No description provided for @errorConnectServer.
  ///
  /// In en, this message translates to:
  /// **'Error connecting to server'**
  String get errorConnectServer;

  /// No description provided for @gameEndTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameEndTitle;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'Final Score'**
  String get finalScore;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @nextRound.
  ///
  /// In en, this message translates to:
  /// **'Next Round'**
  String get nextRound;

  /// No description provided for @playerXWonGame.
  ///
  /// In en, this message translates to:
  /// **'Player X won the game!'**
  String get playerXWonGame;

  /// No description provided for @playerOWonGame.
  ///
  /// In en, this message translates to:
  /// **'Player O won the game!'**
  String get playerOWonGame;

  /// No description provided for @tieGame.
  ///
  /// In en, this message translates to:
  /// **'Tie! No one won.'**
  String get tieGame;

  /// No description provided for @playerWonRound.
  ///
  /// In en, this message translates to:
  /// **'Player {player} won this round!'**
  String playerWonRound(String player);

  /// No description provided for @drawRound.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get drawRound;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @playerTurn.
  ///
  /// In en, this message translates to:
  /// **'Player {player}\'s turn'**
  String playerTurn(String player);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @numberOfRounds.
  ///
  /// In en, this message translates to:
  /// **'Number of Rounds'**
  String get numberOfRounds;

  /// No description provided for @chooseRoundsRange.
  ///
  /// In en, this message translates to:
  /// **'Choose between 1 and 20 rounds'**
  String get chooseRoundsRange;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @yourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your Turn'**
  String get yourTurn;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting...'**
  String get waiting;

  /// No description provided for @waitYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Wait your turn!'**
  String get waitYourTurn;

  /// No description provided for @finalScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Final Score:'**
  String get finalScoreLabel;

  /// No description provided for @playerXScore.
  ///
  /// In en, this message translates to:
  /// **'Player X: {score}'**
  String playerXScore(int score);

  /// No description provided for @playerOScore.
  ///
  /// In en, this message translates to:
  /// **'Player O: {score}'**
  String playerOScore(int score);

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection Lost'**
  String get connectionLost;

  /// No description provided for @connectionLostMessage.
  ///
  /// In en, this message translates to:
  /// **'The connection with the other player was lost.'**
  String get connectionLostMessage;

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get backToMenu;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
