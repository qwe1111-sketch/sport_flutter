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
  String get share => 'Share';

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
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyContent =>
      'Last updated: November 15, 2023\nEffective date: November 15, 2023\n\nIntroduction\n\nWelcome to our products and services! We understand the importance of personal information to you and will do our best to protect the security and reliability of your personal information. We are committed to maintaining your trust in us and adhering to the following principles to protect your personal information: consistency of rights and responsibilities, clear purpose, choice and consent, minimum sufficiency, ensuring security, subject participation, openness and transparency, etc.\n\nThis \"Privacy Policy\" mainly explains how we collect, use, store, and share your personal information, as well as how you can access, update, delete, and protect this information. Before using our products (or services), please carefully read and fully understand all the contents of this policy, especially the terms marked in bold. You should read them carefully and start using them after confirming that you fully understand and agree.\n\n1. How we collect and use your personal information\n\nPersonal information refers to various information recorded electronically or in other ways that can identify a specific natural person\'s identity or reflect a specific natural person\'s activities, either alone or in combination with other information.\n\nWhen you use our services, we will follow the principles of legality, legitimacy, and necessity to collect and use your personal information, mainly including:\n\n1.  Account registration and login: When you register for an account, we will collect your phone number or email address, the password and nickname you set. This information is necessary to create an account for you and provide login services.\n\n2.  Content publishing function: When you use content publishing functions such as posting and commenting, we will collect the text, images, videos, and other content you actively upload. Please note that this information may contain your own or other people\'s personal information, please upload it with caution.\n\n3.  Interaction and collection: When you perform operations such as liking, collecting, and following, we will collect your interaction records in order to show you your collection list, follow list, etc.\n\n4.  Customer service and feedback: When you contact us, we may need you to provide necessary personal information to verify your user identity, and may save your communication/call records and content or the contact information you leave so that we can contact you or help you solve problems.\n\n5.  Required to ensure security: In order to improve the security of your use of our services and protect the personal and property safety of you or other users or the public from infringement, we will collect your device information (such as device model, operating system version), log information (such as IP address, service access date and time).\n\n2. How we use cookies and similar technologies\n\nTo ensure the normal operation of the website and to provide you with a more relaxed access experience, we will store small data files called cookies on your computer or mobile device. Cookies usually contain identifiers, site names, and some numbers and characters. With the help of cookies, we can store your preferences and other data, and determine whether registered users are logged in.\n\nYou can manage or delete cookies according to your own preferences. Most browsers provide users with the function of clearing browser cache data. You can perform corresponding data clearing operations in the browser settings function. However, if you do this, you may need to personally change user settings every time you visit our website, and the corresponding information you have previously recorded will also be deleted.\n\n3. How we share, transfer, and publicly disclose your personal information\n\n1.  Sharing: We will not share your personal information with any company, organization, or individual, except in the following cases:\n    *   Sharing with explicit consent: After obtaining your explicit consent, we will share your personal information with other parties.\n    *   Sharing in legal situations: We may share your personal information externally in accordance with laws and regulations, the needs of litigation and dispute resolution, or as required by administrative and judicial organs in accordance with the law.\n\n2.  Transfer: We will not transfer your personal information to any company, organization, or individual, except in the following cases:\n    *   Transfer with explicit consent.\n    *   In the case of mergers, acquisitions, or bankruptcy and liquidation, if personal information transfer is involved, we will require the new company or organization holding your personal information to continue to be bound by this policy, otherwise we will require the company, organization, and individual to re-seek your authorization and consent.\n\n3.  Public disclosure: We will only publicly disclose your personal information in the following cases:\n    *   After obtaining your explicit consent.\n    *   Disclosure based on law: We may publicly disclose your personal information in cases of law, legal process, litigation, or mandatory requirements of government authorities.\n\n4. How we protect the security of your personal information\n\nWe have used industry-standard security protection measures to protect the personal information you provide to prevent data from being accessed, publicly disclosed, used, modified, damaged, or lost without authorization. We will take all reasonably practicable measures to protect your personal information.\n\nThe Internet environment is not 100% secure, and we will do our best to ensure or guarantee the security of any information you send us. If our physical, technical, or management protection facilities are damaged, resulting in unauthorized access, public disclosure, tampering, or destruction of information, resulting in damage to your legitimate rights and interests, we will bear corresponding legal responsibilities.\n\n5. Your rights\n\nIn accordance with relevant Chinese laws, regulations, and standards, as well as the common practices of other countries and regions, we guarantee that you will exercise the following rights over your personal information:\n\n*   Access your personal information\n*   Correct your personal information\n*   Delete your personal information\n*   Change the scope of your authorized consent\n*   Cancel your account\n\nYou can exercise these rights through the relevant function pages in our products or by contacting our customer service.\n\n6. How this policy is updated\n\nOur privacy policy may change. Without your explicit consent, we will not restrict your rights under this privacy policy. We will post any changes to this policy on this page. For major changes, we will also provide a more prominent notice (for example, through a pop-up window).\n\n7. How to contact us\n\nIf you have any questions, comments, or suggestions about this privacy policy, please contact us through [your contact email or customer service channel].';

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

  @override
  String get createPost => 'Create Post';

  @override
  String get title => 'Title';

  @override
  String get content => 'Content...';

  @override
  String get publish => 'Publish';

  @override
  String get replies => 'Replies';

  @override
  String get selectPicturesFromAlbum => 'Select pictures from album';

  @override
  String get selectVideoFromAlbum => 'Select video from album (one at a time)';

  @override
  String fileLimitExceeded(int remainingSpace) {
    return 'File limit exceeded! You can still select $remainingSpace more files.';
  }

  @override
  String viewAllReplies(int count) {
    return 'View all $count replies';
  }

  @override
  String get addAComment => 'Add a comment...';

  @override
  String get beTheFirstToComment => 'Be the first to comment!';

  @override
  String commentDetails(int count) {
    return 'Comment Details ($count)';
  }
}
