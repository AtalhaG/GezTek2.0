import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GezTek'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @tours.
  ///
  /// In en, this message translates to:
  /// **'Tours'**
  String get tours;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Password Reset'**
  String get forgotPassword;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @surname.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noData;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @guide.
  ///
  /// In en, this message translates to:
  /// **'GUIDE'**
  String get guide;

  /// No description provided for @tourist.
  ///
  /// In en, this message translates to:
  /// **'TOURIST'**
  String get tourist;

  /// No description provided for @tour.
  ///
  /// In en, this message translates to:
  /// **'Tour'**
  String get tour;

  /// No description provided for @booking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get booking;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get writeReview;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last Seen'**
  String get lastSeen;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @goodbye.
  ///
  /// In en, this message translates to:
  /// **'Goodbye'**
  String get goodbye;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get thankYou;

  /// No description provided for @please.
  ///
  /// In en, this message translates to:
  /// **'Please'**
  String get please;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// No description provided for @valid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get valid;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @deny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @maybe.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get maybe;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom In'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom Out'**
  String get zoomOut;

  /// No description provided for @fullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreen;

  /// No description provided for @exitFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exit Fullscreen'**
  String get exitFullscreen;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// No description provided for @themeChanged.
  ///
  /// In en, this message translates to:
  /// **'Theme changed'**
  String get themeChanged;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully logged out'**
  String get logoutSuccess;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully logged in'**
  String get loginSuccess;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccess;

  /// No description provided for @bookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking successful'**
  String get bookingSuccess;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get messageSent;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted'**
  String get reviewSubmitted;

  /// No description provided for @dataSaved.
  ///
  /// In en, this message translates to:
  /// **'Data saved'**
  String get dataSaved;

  /// No description provided for @dataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Data deleted'**
  String get dataDeleted;

  /// No description provided for @dataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Data updated'**
  String get dataUpdated;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Timeout error'**
  String get timeoutError;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email address'**
  String get userNotFound;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This email address is already in use'**
  String get emailAlreadyExists;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weakPassword;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests'**
  String get tooManyRequests;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Try again later'**
  String get tryAgainLater;

  /// No description provided for @checkYourConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your connection'**
  String get checkYourConnection;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report bug'**
  String get reportBug;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get copyright;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved'**
  String get allRightsReserved;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @poweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by'**
  String get poweredBy;

  /// No description provided for @flutter.
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get flutter;

  /// No description provided for @firebase.
  ///
  /// In en, this message translates to:
  /// **'Firebase'**
  String get firebase;

  /// No description provided for @geztek.
  ///
  /// In en, this message translates to:
  /// **'GezTek'**
  String get geztek;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeMessage;

  /// No description provided for @guidePanel.
  ///
  /// In en, this message translates to:
  /// **'Guide Panel'**
  String get guidePanel;

  /// No description provided for @discoverTours.
  ///
  /// In en, this message translates to:
  /// **'Discover special tours for travelers'**
  String get discoverTours;

  /// No description provided for @questionAnswerPanel.
  ///
  /// In en, this message translates to:
  /// **'Question & Answer Panel'**
  String get questionAnswerPanel;

  /// No description provided for @addTour.
  ///
  /// In en, this message translates to:
  /// **'Add Tour'**
  String get addTour;

  /// No description provided for @guides.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get guides;

  /// No description provided for @destinations.
  ///
  /// In en, this message translates to:
  /// **'Destinations'**
  String get destinations;

  /// No description provided for @experiences.
  ///
  /// In en, this message translates to:
  /// **'Experiences'**
  String get experiences;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get pleaseEnterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @checkEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please check your email and password'**
  String get checkEmailPassword;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password entered'**
  String get wrongPassword;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginError;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email address'**
  String get passwordResetSent;

  /// No description provided for @passwordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Password reset failed'**
  String get passwordResetFailed;

  /// No description provided for @searchGuide.
  ///
  /// In en, this message translates to:
  /// **'Search Guide...'**
  String get searchGuide;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @tcIdentity.
  ///
  /// In en, this message translates to:
  /// **'TC Identity Number'**
  String get tcIdentity;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get licenseNumber;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @selfIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Self Introduction'**
  String get selfIntroduction;

  /// No description provided for @userType.
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userType;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @profileImage.
  ///
  /// In en, this message translates to:
  /// **'Profile Image'**
  String get profileImage;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @tourCategories.
  ///
  /// In en, this message translates to:
  /// **'Tour Categories'**
  String get tourCategories;

  /// No description provided for @serviceCities.
  ///
  /// In en, this message translates to:
  /// **'Service Cities'**
  String get serviceCities;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @showAllCities.
  ///
  /// In en, this message translates to:
  /// **'Show All Cities'**
  String get showAllCities;

  /// No description provided for @showLessCities.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLessCities;

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get registrationError;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @imageUploadError.
  ///
  /// In en, this message translates to:
  /// **'Image upload error'**
  String get imageUploadError;

  /// No description provided for @pleaseSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Please select an image'**
  String get pleaseSelectImage;

  /// No description provided for @pleaseSelectUserType.
  ///
  /// In en, this message translates to:
  /// **'Please select user type'**
  String get pleaseSelectUserType;

  /// No description provided for @pleaseSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select gender'**
  String get pleaseSelectGender;

  /// No description provided for @pleaseSelectTourCategories.
  ///
  /// In en, this message translates to:
  /// **'Please select at least 3 tour categories that interest you.'**
  String get pleaseSelectTourCategories;

  /// No description provided for @pleaseSelectServiceCities.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one city'**
  String get pleaseSelectServiceCities;

  /// No description provided for @pleaseSelectLanguages.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one language'**
  String get pleaseSelectLanguages;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself..'**
  String get aboutMe;

  /// No description provided for @imageSelectionError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while selecting image'**
  String get imageSelectionError;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'Update error'**
  String get updateError;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Please check your email inbox.'**
  String get passwordResetEmailSent;

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email not found...'**
  String get emailNotFound;

  /// No description provided for @tourDetails.
  ///
  /// In en, this message translates to:
  /// **'Tour Details'**
  String get tourDetails;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @meetingLocation.
  ///
  /// In en, this message translates to:
  /// **'Meeting Location'**
  String get meetingLocation;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @maxParticipants.
  ///
  /// In en, this message translates to:
  /// **'Max Participants'**
  String get maxParticipants;

  /// No description provided for @routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routes;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask Question'**
  String get askQuestion;

  /// No description provided for @yourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Write your question...'**
  String get yourQuestion;

  /// No description provided for @sendQuestion.
  ///
  /// In en, this message translates to:
  /// **'Send Question'**
  String get sendQuestion;

  /// No description provided for @noQuestions.
  ///
  /// In en, this message translates to:
  /// **'No questions asked yet'**
  String get noQuestions;

  /// No description provided for @noAnswer.
  ///
  /// In en, this message translates to:
  /// **'Not answered yet'**
  String get noAnswer;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @joinTour.
  ///
  /// In en, this message translates to:
  /// **'Join Tour'**
  String get joinTour;

  /// No description provided for @contactGuide.
  ///
  /// In en, this message translates to:
  /// **'Contact Guide'**
  String get contactGuide;

  /// No description provided for @tourNotFound.
  ///
  /// In en, this message translates to:
  /// **'Tour not found'**
  String get tourNotFound;

  /// No description provided for @questionSent.
  ///
  /// In en, this message translates to:
  /// **'Question sent'**
  String get questionSent;

  /// No description provided for @questionError.
  ///
  /// In en, this message translates to:
  /// **'Error sending question'**
  String get questionError;

  /// No description provided for @pleaseEnterQuestion.
  ///
  /// In en, this message translates to:
  /// **'Please write a question'**
  String get pleaseEnterQuestion;

  /// No description provided for @myMessages.
  ///
  /// In en, this message translates to:
  /// **'My Messages'**
  String get myMessages;

  /// No description provided for @loadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Loading messages...'**
  String get loadingMessages;

  /// No description provided for @errorLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages'**
  String get errorLoadingMessages;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @noMessagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Join tours to communicate with guides'**
  String get noMessagesDescription;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @userLoginNotFound.
  ///
  /// In en, this message translates to:
  /// **'User login not found'**
  String get userLoginNotFound;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeMessage;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'You need to login. Please login again.'**
  String get loginRequired;

  /// No description provided for @messageNotSent.
  ///
  /// In en, this message translates to:
  /// **'❌ Message could not be sent'**
  String get messageNotSent;

  /// No description provided for @errorSendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Error sending message'**
  String get errorSendingMessage;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @myTrips.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTrips;

  /// No description provided for @activeTrips.
  ///
  /// In en, this message translates to:
  /// **'Active Trips'**
  String get activeTrips;

  /// No description provided for @pastTrips.
  ///
  /// In en, this message translates to:
  /// **'Past Trips'**
  String get pastTrips;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @stops.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get stops;

  /// No description provided for @noTrips.
  ///
  /// In en, this message translates to:
  /// **'No trips yet'**
  String get noTrips;

  /// No description provided for @noTripsDescription.
  ///
  /// In en, this message translates to:
  /// **'Join tours to see your trips here'**
  String get noTripsDescription;

  /// No description provided for @guideDetails.
  ///
  /// In en, this message translates to:
  /// **'Guide Details'**
  String get guideDetails;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @verifiedGuide.
  ///
  /// In en, this message translates to:
  /// **'Verified Guide'**
  String get verifiedGuide;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviewsCount;

  /// No description provided for @expertise.
  ///
  /// In en, this message translates to:
  /// **'Expertise'**
  String get expertise;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @addReview.
  ///
  /// In en, this message translates to:
  /// **'Add Review'**
  String get addReview;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get yourRating;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get yourReview;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviews;

  /// No description provided for @noTours.
  ///
  /// In en, this message translates to:
  /// **'No tours yet'**
  String get noTours;

  /// No description provided for @guideNotFound.
  ///
  /// In en, this message translates to:
  /// **'Guide not found'**
  String get guideNotFound;

  /// No description provided for @loadingGuide.
  ///
  /// In en, this message translates to:
  /// **'Loading guide information...'**
  String get loadingGuide;

  /// No description provided for @errorLoadingGuide.
  ///
  /// In en, this message translates to:
  /// **'Error loading guide information'**
  String get errorLoadingGuide;

  /// No description provided for @tourName.
  ///
  /// In en, this message translates to:
  /// **'Tour Name'**
  String get tourName;

  /// No description provided for @addRoute.
  ///
  /// In en, this message translates to:
  /// **'Add Route'**
  String get addRoute;

  /// No description provided for @routeName.
  ///
  /// In en, this message translates to:
  /// **'Route Name'**
  String get routeName;

  /// No description provided for @tourImages.
  ///
  /// In en, this message translates to:
  /// **'Tour Images'**
  String get tourImages;

  /// No description provided for @selectImages.
  ///
  /// In en, this message translates to:
  /// **'Select Images'**
  String get selectImages;

  /// No description provided for @saveTour.
  ///
  /// In en, this message translates to:
  /// **'Save Tour'**
  String get saveTour;

  /// No description provided for @guideRequired.
  ///
  /// In en, this message translates to:
  /// **'Only guides can add tours.'**
  String get guideRequired;

  /// No description provided for @tourSaved.
  ///
  /// In en, this message translates to:
  /// **'Tour saved successfully!'**
  String get tourSaved;

  /// No description provided for @tourSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving tour'**
  String get tourSaveError;

  /// No description provided for @pleaseSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get pleaseSelectCity;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @pleaseSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select a language'**
  String get pleaseSelectLanguage;

  /// No description provided for @pleaseSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDate;

  /// No description provided for @pleaseAddRoutes.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one route'**
  String get pleaseAddRoutes;

  /// No description provided for @pleaseAddImages.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one image'**
  String get pleaseAddImages;

  /// No description provided for @searchTour.
  ///
  /// In en, this message translates to:
  /// **'Search Tour...'**
  String get searchTour;

  /// No description provided for @tourSummary.
  ///
  /// In en, this message translates to:
  /// **'Tour Summary'**
  String get tourSummary;

  /// No description provided for @meetingPlace.
  ///
  /// In en, this message translates to:
  /// **'Meeting Place'**
  String get meetingPlace;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @tourStatistics.
  ///
  /// In en, this message translates to:
  /// **'Tour Statistics'**
  String get tourStatistics;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @thisTour.
  ///
  /// In en, this message translates to:
  /// **'This tour'**
  String get thisTour;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @tourGroup.
  ///
  /// In en, this message translates to:
  /// **'Tour Group'**
  String get tourGroup;

  /// No description provided for @groupParticipatingInTour.
  ///
  /// In en, this message translates to:
  /// **'Group participating in this tour'**
  String get groupParticipatingInTour;

  /// No description provided for @helloSendFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello! Send the first message 👋'**
  String get helloSendFirstMessage;

  /// No description provided for @sendFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Send the first message!'**
  String get sendFirstMessage;

  /// No description provided for @groupInformation.
  ///
  /// In en, this message translates to:
  /// **'Group Information'**
  String get groupInformation;

  /// No description provided for @emojiPickerComingSoon.
  ///
  /// In en, this message translates to:
  /// **'😊 Emoji picker coming soon'**
  String get emojiPickerComingSoon;

  /// No description provided for @fileAttachmentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'📎 File attachment feature coming soon'**
  String get fileAttachmentComingSoon;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @groupID.
  ///
  /// In en, this message translates to:
  /// **'Group ID'**
  String get groupID;

  /// No description provided for @pleaseEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get pleaseEnterFirstName;

  /// No description provided for @pleaseEnterLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get pleaseEnterLastName;

  /// No description provided for @pleaseEnterTCIdentity.
  ///
  /// In en, this message translates to:
  /// **'Please enter your TC identity number'**
  String get pleaseEnterTCIdentity;

  /// No description provided for @tcIdentityMustBe11Digits.
  ///
  /// In en, this message translates to:
  /// **'TC identity number must be 11 digits'**
  String get tcIdentityMustBe11Digits;

  /// No description provided for @pleaseEnterLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your guide license number'**
  String get pleaseEnterLicenseNumber;

  /// No description provided for @licenseNumberMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'License number must be at least 6 digits'**
  String get licenseNumberMustBe6Digits;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @passwordMustBe6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBe6Characters;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseEnterBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter your birth date'**
  String get pleaseEnterBirthDate;

  /// No description provided for @addProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Profile Photo'**
  String get addProfilePhoto;

  /// No description provided for @selfIntroductionText.
  ///
  /// In en, this message translates to:
  /// **'Text that will be used when recommending you to tourists and that tourists visiting your profile will see'**
  String get selfIntroductionText;

  /// No description provided for @pleaseIntroduceYourself.
  ///
  /// In en, this message translates to:
  /// **'Please introduce yourself'**
  String get pleaseIntroduceYourself;

  /// No description provided for @citiesYouCanServe.
  ///
  /// In en, this message translates to:
  /// **'Cities You Can Serve'**
  String get citiesYouCanServe;

  /// No description provided for @showPopularCities.
  ///
  /// In en, this message translates to:
  /// **'Show Popular Cities'**
  String get showPopularCities;

  /// No description provided for @pleaseSelectCitiesYouCanServe.
  ///
  /// In en, this message translates to:
  /// **'Please select cities you can serve.'**
  String get pleaseSelectCitiesYouCanServe;

  /// No description provided for @pleaseSelectAtLeastOneCity.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one city.'**
  String get pleaseSelectAtLeastOneCity;

  /// No description provided for @languagesYouSpeak.
  ///
  /// In en, this message translates to:
  /// **'Languages You Speak'**
  String get languagesYouSpeak;

  /// No description provided for @pleaseSelectLanguagesForTours.
  ///
  /// In en, this message translates to:
  /// **'Please select languages you can conduct tours in.'**
  String get pleaseSelectLanguagesForTours;

  /// No description provided for @pleaseSelectAtLeastOneLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one language.'**
  String get pleaseSelectAtLeastOneLanguage;

  /// No description provided for @pleaseSelectAtLeast3Categories.
  ///
  /// In en, this message translates to:
  /// **'Please select at least 3 tour categories.'**
  String get pleaseSelectAtLeast3Categories;

  /// No description provided for @pleaseGrantPermissions.
  ///
  /// In en, this message translates to:
  /// **'Please grant necessary permissions'**
  String get pleaseGrantPermissions;

  /// No description provided for @userInfoCouldNotBeCreated.
  ///
  /// In en, this message translates to:
  /// **'User information could not be created. Please try again.'**
  String get userInfoCouldNotBeCreated;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to your email address.'**
  String get enterVerificationCode;

  /// No description provided for @verificationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Verification process was cancelled.'**
  String get verificationCancelled;

  /// No description provided for @photoSelectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Photo selected successfully'**
  String get photoSelectedSuccessfully;

  /// No description provided for @errorSelectingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while selecting photo'**
  String get errorSelectingPhoto;

  /// No description provided for @selectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get selectPhoto;

  /// No description provided for @takeWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Take with Camera'**
  String get takeWithCamera;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @weWantToKnowYouBetter.
  ///
  /// In en, this message translates to:
  /// **'We want to get to know you better'**
  String get weWantToKnowYouBetter;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerification;

  /// No description provided for @verificationCodeError.
  ///
  /// In en, this message translates to:
  /// **'Verification code is incorrect!'**
  String get verificationCodeError;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @helloHowAreYou.
  ///
  /// In en, this message translates to:
  /// **'Hello, how are you?'**
  String get helloHowAreYou;

  /// No description provided for @imFineThankYou.
  ///
  /// In en, this message translates to:
  /// **'I\'m fine, thank you! How are you?'**
  String get imFineThankYou;

  /// No description provided for @imFineToo.
  ///
  /// In en, this message translates to:
  /// **'I\'m fine too. I want to get information about the tour.'**
  String get imFineToo;

  /// No description provided for @loadedData.
  ///
  /// In en, this message translates to:
  /// **'Loaded data'**
  String get loadedData;

  /// No description provided for @processedTour.
  ///
  /// In en, this message translates to:
  /// **'Processed tour'**
  String get processedTour;

  /// No description provided for @selectedTour.
  ///
  /// In en, this message translates to:
  /// **'Selected tour'**
  String get selectedTour;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found or null'**
  String get noDataFound;

  /// No description provided for @errorLoadingTours.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while loading tours'**
  String get errorLoadingTours;

  /// No description provided for @loadingGuides.
  ///
  /// In en, this message translates to:
  /// **'Loading guides...'**
  String get loadingGuides;

  /// No description provided for @noGuidesFound.
  ///
  /// In en, this message translates to:
  /// **'No guides found matching filters'**
  String get noGuidesFound;

  /// No description provided for @tryChangingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try changing filters'**
  String get tryChangingFilters;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available yet'**
  String get noDataAvailable;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cityInfoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'City information not available'**
  String get cityInfoNotAvailable;

  /// No description provided for @guidesLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while loading guides'**
  String get guidesLoadingError;

  /// No description provided for @cityInfo.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityInfo;

  /// No description provided for @tarih.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get tarih;

  /// No description provided for @turTipi.
  ///
  /// In en, this message translates to:
  /// **'Tour Type'**
  String get turTipi;

  /// No description provided for @puan.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get puan;

  /// No description provided for @cityInfoSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Service City'**
  String get cityInfoSelect;

  /// No description provided for @turTipiSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Tour Type'**
  String get turTipiSelect;

  /// No description provided for @languageSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageSelect;

  /// No description provided for @minimumPuanSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Minimum Score'**
  String get minimumPuanSelect;

  /// No description provided for @turTarihiSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Tour Date'**
  String get turTarihiSelect;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @tourTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Tour Type'**
  String get tourTypeLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @guidesLoadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Guides loaded successfully'**
  String get guidesLoadedSuccess;

  /// No description provided for @guideLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Guide loading error'**
  String get guideLoadingError;

  /// No description provided for @questionAnswer.
  ///
  /// In en, this message translates to:
  /// **'Question & Answer'**
  String get questionAnswer;

  /// No description provided for @answerQuestion.
  ///
  /// In en, this message translates to:
  /// **'Answer Question'**
  String get answerQuestion;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @noUnansweredQuestions.
  ///
  /// In en, this message translates to:
  /// **'No unanswered questions yet'**
  String get noUnansweredQuestions;

  /// No description provided for @guideLoginNotFound.
  ///
  /// In en, this message translates to:
  /// **'Guide login not found'**
  String get guideLoginNotFound;

  /// No description provided for @errorLoadingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while loading questions'**
  String get errorLoadingQuestions;

  /// No description provided for @answerSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your answer was sent successfully!'**
  String get answerSentSuccessfully;

  /// No description provided for @errorSendingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while sending answer'**
  String get errorSendingAnswer;

  /// No description provided for @unknownTour.
  ///
  /// In en, this message translates to:
  /// **'Unknown Tour'**
  String get unknownTour;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @writeYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Write your answer...'**
  String get writeYourAnswer;

  /// No description provided for @questionsLoadedForGuide.
  ///
  /// In en, this message translates to:
  /// **'Questions loaded for guide'**
  String get questionsLoadedForGuide;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'March 15, 2024 - March 20, 2024'**
  String get dateFormat;

  /// No description provided for @noQuestionsYet.
  ///
  /// In en, this message translates to:
  /// **'No questions asked yet'**
  String get noQuestionsYet;

  /// No description provided for @loginRequiredToAsk.
  ///
  /// In en, this message translates to:
  /// **'You need to login to ask a question'**
  String get loginRequiredToAsk;

  /// No description provided for @loginRequiredToJoin.
  ///
  /// In en, this message translates to:
  /// **'You need to login to join the tour'**
  String get loginRequiredToJoin;

  /// No description provided for @tourJoinError.
  ///
  /// In en, this message translates to:
  /// **'❌ An error occurred while joining the tour. Payment refunded.'**
  String get tourJoinError;

  /// No description provided for @dataFetchError.
  ///
  /// In en, this message translates to:
  /// **'Data could not be fetched (HTTP {statusCode})'**
  String dataFetchError(Object statusCode);

  /// No description provided for @dataLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while loading data: {error}'**
  String dataLoadingError(Object error);

  /// No description provided for @tourIdNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Tour ID not specified'**
  String get tourIdNotSpecified;

  /// No description provided for @beFirstToAsk.
  ///
  /// In en, this message translates to:
  /// **'Be the first to ask a question about this tour!'**
  String get beFirstToAsk;

  /// No description provided for @viewAllQuestions.
  ///
  /// In en, this message translates to:
  /// **'View all questions ({count})'**
  String viewAllQuestions(Object count);

  /// No description provided for @answered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answered;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @guideAnswer.
  ///
  /// In en, this message translates to:
  /// **'Guide Answer'**
  String get guideAnswer;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(Object days);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(Object hours);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @writeQuestionForGuide.
  ///
  /// In en, this message translates to:
  /// **'Write the question you want to ask the guide about this tour:'**
  String get writeQuestionForGuide;

  /// No description provided for @questionExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: Is lunch included in this tour?'**
  String get questionExample;

  /// No description provided for @allQuestions.
  ///
  /// In en, this message translates to:
  /// **'All Questions'**
  String get allQuestions;

  /// No description provided for @newQuestion.
  ///
  /// In en, this message translates to:
  /// **'New Question'**
  String get newQuestion;

  /// No description provided for @tourInformation.
  ///
  /// In en, this message translates to:
  /// **'Tour Information'**
  String get tourInformation;

  /// No description provided for @tourRoutes.
  ///
  /// In en, this message translates to:
  /// **'Tour Routes'**
  String get tourRoutes;

  /// No description provided for @guidesCannotJoinOwnTours.
  ///
  /// In en, this message translates to:
  /// **'As a guide, you cannot join your own tours'**
  String get guidesCannotJoinOwnTours;

  /// No description provided for @helloName.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}!'**
  String helloName(Object name);

  /// Confirmation message for joining a tour
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to join the {tourName} tour?'**
  String confirmJoinTour(Object tourName);

  /// No description provided for @afterJoiningGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'After joining, you will be added to the tour message group'**
  String get afterJoiningGroupMessage;

  /// No description provided for @payAndJoin.
  ///
  /// In en, this message translates to:
  /// **'Pay {price} ₺ & Join'**
  String payAndJoin(Object price);

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processingPayment;

  /// No description provided for @addingToGroupMessages.
  ///
  /// In en, this message translates to:
  /// **'Adding to group messages...'**
  String get addingToGroupMessages;

  /// No description provided for @successfullyJoinedTour.
  ///
  /// In en, this message translates to:
  /// **'🎉 Successfully joined the tour!'**
  String get successfullyJoinedTour;

  /// No description provided for @paymentCompleted.
  ///
  /// In en, this message translates to:
  /// **'✅ Payment completed'**
  String get paymentCompleted;

  /// No description provided for @addedToMessageGroup.
  ///
  /// In en, this message translates to:
  /// **'✅ Added to message group'**
  String get addedToMessageGroup;

  /// No description provided for @messageGroupInfo.
  ///
  /// In en, this message translates to:
  /// **'You can communicate with other participants from the \'Messages\' section in the bottom menu'**
  String get messageGroupInfo;

  /// No description provided for @goToMessages.
  ///
  /// In en, this message translates to:
  /// **'Go to Messages'**
  String get goToMessages;

  /// No description provided for @mapCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Map could not be opened'**
  String get mapCouldNotOpen;

  /// No description provided for @beFirstToReview.
  ///
  /// In en, this message translates to:
  /// **'Be the first to review!'**
  String get beFirstToReview;

  /// No description provided for @aiAssistantTab.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistantTab;

  /// No description provided for @aiAssistantSoon.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant Coming Soon'**
  String get aiAssistantSoon;

  /// No description provided for @aiAssistantDescription.
  ///
  /// In en, this message translates to:
  /// **'You will soon be able to ask questions about your guide to our AI assistant.'**
  String get aiAssistantDescription;

  /// No description provided for @perPerson.
  ///
  /// In en, this message translates to:
  /// **'person'**
  String get perPerson;

  /// No description provided for @enterTourName.
  ///
  /// In en, this message translates to:
  /// **'Enter tour name'**
  String get enterTourName;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// No description provided for @enterDuration.
  ///
  /// In en, this message translates to:
  /// **'Enter tour duration'**
  String get enterDuration;

  /// No description provided for @enterMaxParticipants.
  ///
  /// In en, this message translates to:
  /// **'Enter max participants'**
  String get enterMaxParticipants;

  /// No description provided for @tourType.
  ///
  /// In en, this message translates to:
  /// **'Tour Type'**
  String get tourType;

  /// No description provided for @enterMeetingLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter meeting location'**
  String get enterMeetingLocation;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
