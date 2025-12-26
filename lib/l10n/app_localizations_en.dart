// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sport Flutter';

  @override
  String get upNext => 'Up Next';

  @override
  String videoViews(num count, Object date) {
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
  String daysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String weeksAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
      zero: 'This week',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
      zero: 'Just now',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
      zero: 'Just now',
    );
    return '$_temp0';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String get dislike => 'Dislike';

  @override
  String get favorite => 'Favorite';

  @override
  String get tenThousand => 'w';

  @override
  String get home => 'Home';

  @override
  String get community => 'Community';

  @override
  String get profile => 'Profile';

  @override
  String get login => 'Login';

  @override
  String get invalidUsernameOrPassword => 'Invalid username or password';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Please enter your username';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account? Sign up';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get myProfile => 'My Profile';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get myPosts => 'My Posts';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get language => 'Language';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmLogout => 'Logout';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get ultimate => 'Ultimate';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get register => 'Register';

  @override
  String get registrationSuccessful => 'Registration successful';

  @override
  String get codeSent => 'Verification code sent';

  @override
  String get email => 'Email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get enterVerificationCode => 'Please enter the verification code';

  @override
  String get sendVerificationCode => 'Send Code';

  @override
  String get agreement => 'By signing up, you agree to our ';

  @override
  String get createPost => 'Create Post';

  @override
  String get publish => 'Publish';

  @override
  String get title => 'Title';

  @override
  String get content => 'Content';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get deletePostConfirmation =>
      'Are you sure you want to delete this post?';

  @override
  String get delete => 'Delete';

  @override
  String get comments => 'Comments';

  @override
  String get privacyPolicyContent =>
      'This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You. We use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy.\n\n**Information Collection and Use**\n\n**Types of Data Collected**\n*   **Personal Data:** While using Our Service, We may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You. Personally identifiable information may include, but is not limited to: Email address, Username, and Profile Picture.\n*   **Usage Data:** Usage Data is collected automatically when using the Service. This may include information such as Your device\'s Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that You visit, the time and date of Your visit, the time spent on those pages, unique device identifiers and other diagnostic data.\n*   **User-Generated Content:** We collect the content you create on our Service, which includes videos and images you upload, comments you post, likes, and favorites.\n\n**Use of Your Personal Data**\nThe Company may use Personal Data for the following purposes:\n*   To provide and maintain our Service, including to monitor the usage of our Service.\n*   To manage Your Account: to manage Your registration as a user of the Service.\n*   To contact You: To contact You by email regarding updates or informative communications related to the functionalities, products or contracted services.\n*   To provide You with news, special offers and general information about other goods, services and events which we offer.\n*   To manage Your requests: To attend and manage Your requests to Us.\n\n**Sharing Your Information**\nWe do not sell your personal information. We may share your information with third-party service providers who perform services on our behalf, such as hosting services and analytics.';

  @override
  String get introduction => 'Introduction';

  @override
  String replyingTo(String username) {
    return 'Replying to $username';
  }

  @override
  String get postYourComment => 'Post your comment';

  @override
  String get beTheFirstToComment => 'Be the first to comment';

  @override
  String viewAllReplies(int count) {
    return 'View all $count replies';
  }

  @override
  String commentDetails(int count) {
    return '$count replies';
  }

  @override
  String get addAComment => 'Add a comment';

  @override
  String get replies => 'Replies';

  @override
  String fileLimitExceeded(int count) {
    return 'You can only select up to $count files.';
  }

  @override
  String get selectPicturesFromAlbum => 'Select pictures from album';

  @override
  String get selectVideoFromAlbum => 'Select video from album';

  @override
  String get sportVideos => 'Sport Videos';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetYourPassword => 'Reset Your Password';

  @override
  String get resetPasswordInstruction =>
      'Please enter your email address. We will send you a verification code to reset your password.';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordsDoNotMatch => 'The two passwords do not match';

  @override
  String get confirmReset => 'Confirm Reset';

  @override
  String get passwordResetSuccessLogin =>
      'Password has been reset. Please log in.';

  @override
  String get usernameAndEmailMismatch => 'Username and email mismatch';

  @override
  String get noRepliesYet => 'No replies yet.';

  @override
  String get invitationCode => 'Invitation Code';

  @override
  String get incorrectInvitationCode => 'Incorrect invitation code';

  @override
  String get pleaseRequestVerificationCodeFirst =>
      'Please request verification code first';

  @override
  String get invalidVerificationCode => 'Invalid verification code.';
}
