// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get myProfile => 'My Profile';

  @override
  String get myPosts => 'My Posts';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get language => 'Language';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get appUsageDeclaration => 'App Usage Declaration';

  @override
  String get logout => 'Logout';

  @override
  String get close => 'Close';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get usageDeclarationContent =>
      'This usage declaration aims to clarify your rights and obligations when using this App and to protect the legal rights and interests of both parties. Please read and fully understand all the contents of this declaration before downloading, installing, registering, or using this App. Once you start using this App, you are deemed to have accepted all the terms of this declaration. If you do not agree with this declaration, please do not use this App.';

  @override
  String videoViews(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count views',
      one: '1 view',
      zero: 'No views',
    );
    return '$_temp0 • $date';
  }

  @override
  String get upNext => 'Up Next';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get dislike => 'Dislike';

  @override
  String get favorite => 'Favorite';

  @override
  String get tenThousand => 'w';

  @override
  String get introduction => 'Introduction';

  @override
  String get comments => 'Comments';

  @override
  String get home => 'Home';

  @override
  String get community => 'Community';

  @override
  String get profile => 'Profile';

  @override
  String replyingTo(String username) {
    return 'Replying to @$username';
  }

  @override
  String get sendReply => 'Send a reply';

  @override
  String get postYourComment => 'Post your comment';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account? Register';

  @override
  String loginFailed(String message) {
    return 'Login Failed: $message';
  }

  @override
  String get register => 'Register';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Please enter a username';

  @override
  String get enterValidEmail => 'Please enter a valid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters long';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get enterVerificationCode => 'Please enter the verification code';

  @override
  String get sendVerificationCode => 'Send Code';

  @override
  String get agreement => 'I have read and agree to the ';

  @override
  String get userAgreement => 'App Usage Declaration';

  @override
  String get registrationSuccessful => 'Registration successful! Please log in';

  @override
  String get codeSent => 'Verification code sent';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get usernameOrPasswordCannotBeEmpty =>
      'Username or password cannot be empty';

  @override
  String get invalidUsernameOrPassword => 'Invalid username or password';

  @override
  String get loginFailedTitle => 'Login Failed';

  @override
  String get ok => 'OK';

  @override
  String get enterPassword => 'Please enter a password';
}
