import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @myPosts.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get myPosts;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @appUsageDeclaration.
  ///
  /// In en, this message translates to:
  /// **'App Usage Declaration'**
  String get appUsageDeclaration;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @usageDeclarationContent.
  ///
  /// In en, this message translates to:
  /// **'This usage declaration aims to clarify your rights and obligations when using this App and to protect the legal rights and interests of both parties. Please read and fully understand all the contents of this declaration before downloading, installing, registering, or using this App. Once you start using this App, you are deemed to have accepted all the terms of this declaration. If you do not agree with this declaration, please do not use this App.'**
  String get usageDeclarationContent;

  /// The number of views on a video
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No views} =1{1 view} other{{count} views}} • {date}'**
  String videoViews(int count, String date);

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get upNext;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 day ago} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 hour ago} other{{count} hours ago}}'**
  String hoursAgo(int count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @dislike.
  ///
  /// In en, this message translates to:
  /// **'Dislike'**
  String get dislike;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @tenThousand.
  ///
  /// In en, this message translates to:
  /// **'w'**
  String get tenThousand;

  /// No description provided for @introduction.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introduction;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @replyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to @{username}'**
  String replyingTo(String username);

  /// No description provided for @sendReply.
  ///
  /// In en, this message translates to:
  /// **'Send a reply'**
  String get sendReply;

  /// No description provided for @postYourComment.
  ///
  /// In en, this message translates to:
  /// **'Post your comment'**
  String get postYourComment;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dontHaveAnAccount;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed: {message}'**
  String loginFailed(String message);

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get enterUsername;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordTooShort;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get enterVerificationCode;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendVerificationCode;

  /// No description provided for @agreement.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the '**
  String get agreement;

  /// No description provided for @userAgreement.
  ///
  /// In en, this message translates to:
  /// **'App Usage Declaration'**
  String get userAgreement;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Last updated: November 15, 2023\nEffective date: November 15, 2023\n\nIntroduction\n\nWelcome to our products and services! We understand the importance of personal information to you and will do our best to protect the security and reliability of your personal information. We are committed to maintaining your trust in us and adhering to the following principles to protect your personal information: consistency of rights and responsibilities, clear purpose, choice and consent, minimum sufficiency, ensuring security, subject participation, openness and transparency, etc.\n\nThis \"Privacy Policy\" mainly explains how we collect, use, store, and share your personal information, as well as how you can access, update, delete, and protect this information. Before using our products (or services), please carefully read and fully understand all the contents of this policy, especially the terms marked in bold. You should read them carefully and start using them after confirming that you fully understand and agree.\n\n1. How we collect and use your personal information\n\nPersonal information refers to various information recorded electronically or in other ways that can identify a specific natural person\'s identity or reflect a specific natural person\'s activities, either alone or in combination with other information.\n\nWhen you use our services, we will follow the principles of legality, legitimacy, and necessity to collect and use your personal information, mainly including:\n\n1.  Account registration and login: When you register for an account, we will collect your phone number or email address, the password and nickname you set. This information is necessary to create an account for you and provide login services.\n\n2.  Content publishing function: When you use content publishing functions such as posting and commenting, we will collect the text, images, videos, and other content you actively upload. Please note that this information may contain your own or other people\'s personal information, please upload it with caution.\n\n3.  Interaction and collection: When you perform operations such as liking, collecting, and following, we will collect your interaction records in order to show you your collection list, follow list, etc.\n\n4.  Customer service and feedback: When you contact us, we may need you to provide necessary personal information to verify your user identity, and may save your communication/call records and content or the contact information you leave so that we can contact you or help you solve problems.\n\n5.  Required to ensure security: In order to improve the security of your use of our services and protect the personal and property safety of you or other users or the public from infringement, we will collect your device information (such as device model, operating system version), log information (such as IP address, service access date and time).\n\n2. How we use cookies and similar technologies\n\nTo ensure the normal operation of the website and to provide you with a more relaxed access experience, we will store small data files called cookies on your computer or mobile device. Cookies usually contain identifiers, site names, and some numbers and characters. With the help of cookies, we can store your preferences and other data, and determine whether registered users are logged in.\n\nYou can manage or delete cookies according to your own preferences. Most browsers provide users with the function of clearing browser cache data. You can perform corresponding data clearing operations in the browser settings function. However, if you do this, you may need to personally change user settings every time you visit our website, and the corresponding information you have previously recorded will also be deleted.\n\n3. How we share, transfer, and publicly disclose your personal information\n\n1.  Sharing: We will not share your personal information with any company, organization, or individual, except in the following cases:\n    *   Sharing with explicit consent: After obtaining your explicit consent, we will share your personal information with other parties.\n    *   Sharing in legal situations: We may share your personal information externally in accordance with laws and regulations, the needs of litigation and dispute resolution, or as required by administrative and judicial organs in accordance with the law.\n\n2.  Transfer: We will not transfer your personal information to any company, organization, or individual, except in the following cases:\n    *   Transfer with explicit consent.\n    *   In the case of mergers, acquisitions, or bankruptcy and liquidation, if personal information transfer is involved, we will require the new company or organization holding your personal information to continue to be bound by this policy, otherwise we will require the company, organization, and individual to re-seek your authorization and consent.\n\n3.  Public disclosure: We will only publicly disclose your personal information in the following cases:\n    *   After obtaining your explicit consent.\n    *   Disclosure based on law: We may publicly disclose your personal information in cases of law, legal process, litigation, or mandatory requirements of government authorities.\n\n4. How we protect the security of your personal information\n\nWe have used industry-standard security protection measures to protect the personal information you provide to prevent data from being accessed, publicly disclosed, used, modified, damaged, or lost without authorization. We will take all reasonably practicable measures to protect your personal information.\n\nThe Internet environment is not 100% secure, and we will do our best to ensure or guarantee the security of any information you send us. If our physical, technical, or management protection facilities are damaged, resulting in unauthorized access, public disclosure, tampering, or destruction of information, resulting in damage to your legitimate rights and interests, we will bear corresponding legal responsibilities.\n\n5. Your rights\n\nIn accordance with relevant Chinese laws, regulations, and standards, as well as the common practices of other countries and regions, we guarantee that you will exercise the following rights over your personal information:\n\n*   Access your personal information\n*   Correct your personal information\n*   Delete your personal information\n*   Change the scope of your authorized consent\n*   Cancel your account\n\nYou can exercise these rights through the relevant function pages in our products or by contacting our customer service.\n\n6. How this policy is updated\n\nOur privacy policy may change. Without your explicit consent, we will not restrict your rights under this privacy policy. We will post any changes to this policy on this page. For major changes, we will also provide a more prominent notice (for example, through a pop-up window).\n\n7. How to contact us\n\nIf you have any questions, comments, or suggestions about this privacy policy, please contact us through [your contact email or customer service channel].'**
  String get privacyPolicyContent;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please log in'**
  String get registrationSuccessful;

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent'**
  String get codeSent;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @usernameOrPasswordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username or password cannot be empty'**
  String get usernameOrPasswordCannotBeEmpty;

  /// No description provided for @invalidUsernameOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidUsernameOrPassword;

  /// No description provided for @loginFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailedTitle;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get enterPassword;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content...'**
  String get content;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @replies.
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get replies;

  /// No description provided for @selectPicturesFromAlbum.
  ///
  /// In en, this message translates to:
  /// **'Select pictures from album'**
  String get selectPicturesFromAlbum;

  /// No description provided for @selectVideoFromAlbum.
  ///
  /// In en, this message translates to:
  /// **'Select video from album (one at a time)'**
  String get selectVideoFromAlbum;

  /// No description provided for @fileLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'File limit exceeded! You can still select {remainingSpace} more files.'**
  String fileLimitExceeded(int remainingSpace);

  /// No description provided for @viewAllReplies.
  ///
  /// In en, this message translates to:
  /// **'View all {count} replies'**
  String viewAllReplies(int count);

  /// No description provided for @addAComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addAComment;

  /// No description provided for @beTheFirstToComment.
  ///
  /// In en, this message translates to:
  /// **'Be the first to comment!'**
  String get beTheFirstToComment;

  /// No description provided for @commentDetails.
  ///
  /// In en, this message translates to:
  /// **'Comment Details ({count})'**
  String commentDetails(int count);
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
