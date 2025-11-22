// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get myProfile => '我的';

  @override
  String get myPosts => '我的帖子';

  @override
  String get myFavorites => '我的收藏';

  @override
  String get language => '语言';

  @override
  String get editProfile => '编辑资料';

  @override
  String get appUsageDeclaration => 'App使用声明';

  @override
  String get logout => '退出登录';

  @override
  String get close => '关闭';

  @override
  String get logoutConfirmation => '您确定要退出登录吗？';

  @override
  String get cancel => '取消';

  @override
  String get confirmLogout => '确认退出';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get usageDeclarationContent =>
      '本使用声明旨在明确你使用本 App 时的权利与义务，保护双方合法权益。请你在下载、安装、注册或使用本 App 前，仔细阅读并充分理解本声明全部内容，一旦你开始使用本 App，即视为你已接受本声明的所有条款。若你不同意本声明，请勿使用本 App。';

  @override
  String videoViews(int count, String date) {
    return '$count 次观看 • $date';
  }

  @override
  String get upNext => '即将播放';

  @override
  String daysAgo(int count) {
    return '$count 天前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 小时前';
  }

  @override
  String get justNow => '刚刚';

  @override
  String get dislike => '不喜欢';

  @override
  String get favorite => '收藏';

  @override
  String get share => '分享';

  @override
  String get tenThousand => '万';

  @override
  String get introduction => '简介';

  @override
  String get comments => '评论';

  @override
  String get home => '首页';

  @override
  String get community => '社区';

  @override
  String get profile => '我的';

  @override
  String replyingTo(String username) {
    return '回复 @$username';
  }

  @override
  String get sendReply => '发送回复';

  @override
  String get postYourComment => '发表你的评论';

  @override
  String get easy => '简单';

  @override
  String get medium => '中度';

  @override
  String get hard => '困难';

  @override
  String get login => '登录';

  @override
  String get email => '电子邮件';

  @override
  String get password => '密码';

  @override
  String get dontHaveAnAccount => '还没有帐户？ 注册';

  @override
  String loginFailed(String message) {
    return '登录失败：$message';
  }

  @override
  String get register => '注册';

  @override
  String get username => '用户名';

  @override
  String get enterUsername => '请输入用户名';

  @override
  String get enterValidEmail => '请输入有效的邮箱地址';

  @override
  String get passwordTooShort => '密码长度不能少于6位';

  @override
  String get verificationCode => '验证码';

  @override
  String get enterVerificationCode => '请输入验证码';

  @override
  String get sendVerificationCode => '发送验证码';

  @override
  String get agreement => '我已阅读并同意 ';

  @override
  String get userAgreement => '《App使用声明》';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get registrationSuccessful => '注册成功! 请登录';

  @override
  String get codeSent => '验证码已发送';

  @override
  String get invalidEmail => '请输入有效的邮箱地址';

  @override
  String get usernameOrPasswordCannotBeEmpty => '用户名或密码不能为空';

  @override
  String get invalidUsernameOrPassword => '用户名或密码错误';

  @override
  String get loginFailedTitle => '登录失败';

  @override
  String get ok => '好的';

  @override
  String get enterPassword => '请输入密码';
}
