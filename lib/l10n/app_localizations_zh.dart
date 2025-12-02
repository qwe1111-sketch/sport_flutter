// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '运动 Flutter';

  @override
  String get upNext => '接下来播放';

  @override
  String videoViews(num count, Object date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次观看',
      zero: '无观看',
    );
    return '$_temp0 • $date';
  }

  @override
  String daysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天前',
      one: '1 天前',
      zero: '今天',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 小时前',
      one: '1 小时前',
      zero: '刚刚',
    );
    return '$_temp0';
  }

  @override
  String get justNow => '刚刚';

  @override
  String get showMore => '显示更多';

  @override
  String get showLess => '显示更少';

  @override
  String get dislike => '不喜欢';

  @override
  String get favorite => '收藏';

  @override
  String get tenThousand => '万';

  @override
  String get home => '首页';

  @override
  String get community => '社区';

  @override
  String get profile => '我的';

  @override
  String get login => '登录';

  @override
  String get invalidUsernameOrPassword => '无效的用户名或密码';

  @override
  String get username => '用户名';

  @override
  String get enterUsername => '请输入用户名';

  @override
  String get password => '密码';

  @override
  String get enterPassword => '请输入密码';

  @override
  String get dontHaveAnAccount => '没有帐户？ 注册';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get myProfile => '我的资料';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get myPosts => '我的帖子';

  @override
  String get myFavorites => '我的收藏';

  @override
  String get language => '语言';

  @override
  String get editProfile => '编辑个人资料';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get logout => '登出';

  @override
  String get logoutConfirmation => '您确定要退出吗？';

  @override
  String get cancel => '取消';

  @override
  String get confirmLogout => '登出';

  @override
  String get easy => '简单';

  @override
  String get medium => '中等';

  @override
  String get hard => '困难';

  @override
  String get invalidEmail => '无效的电子邮件地址';

  @override
  String get register => '注册';

  @override
  String get registrationSuccessful => '注册成功';

  @override
  String get codeSent => '验证码已发送';

  @override
  String get email => '电子邮件';

  @override
  String get enterValidEmail => '请输入有效的电子邮件';

  @override
  String get passwordTooShort => '密码必须至少为 6 个字符';

  @override
  String get verificationCode => '验证码';

  @override
  String get enterVerificationCode => '请输入验证码';

  @override
  String get sendVerificationCode => '发送验证码';

  @override
  String get agreement => '注册即表示您同意我们的';

  @override
  String get createPost => '创建帖子';

  @override
  String get publish => '发布';

  @override
  String get title => '标题';

  @override
  String get content => '内容';

  @override
  String get deletePost => '删除帖子';

  @override
  String get deletePostConfirmation => '您确定要删除此帖子吗？';

  @override
  String get delete => '删除';

  @override
  String get comments => '评论';

  @override
  String get privacyPolicyContent =>
      '本隐私政策阐述了当您使用本服务时，我们关于收集、使用和披露您信息的政策和程序，并告知您所拥有的隐私权以及法律如何保护您。我们使用您的个人数据来提供和改进本服务。使用本服务即表示您同意我们根据本隐私政策收集和使用信息。\n\n**信息收集与使用**\n\n**收集的数据类型**\n*   **个人数据：** 在使用我们的服务时，我们可能会要求您提供某些可用于联系或识别您的个人身份信息。个人身份信息可能包括但不限于：电子邮件地址、用户名和个人资料图片。\n*   **使用数据：** 使用服务时会自动收集使用数据。这可能包括您设备的互联网协议地址（例如 IP 地址）、浏览器类型、浏览器版本、您访问我们服务的页面、您访问的时间和日期、在这些页面上花费的时间、唯一的设备标识符和其他诊断数据。\n*   **用户生成内容：** 我们会收集您在我们服务上创建的内容，包括您上传的视频和图片、您发表的评论、点赞和收藏。\n\n**您个人数据的使用**\n公司可能将个人数据用于以下目的：\n*   提供和维护我们的服务，包括监控我们服务的使用情况。\n*   管理您的帐户：管理您作为服务用户的注册。\n*   与您联系：通过电子邮件就与功能、产品或签约服务相关的更新或信息性通讯与您联系。\n*   为您提供我们提供的其他商品、服务和活动的新闻、特别优惠和一般信息。\n*   管理您的请求：处理和管理您向我们提出的请求。\n\n**共享您的信息**\n我们不会出售您的个人信息。我们可能会与代表我们执行服务（例如托管服务和分析）的第三方服务提供商共享您的信息。\n\n**您个人数据的安全**\n您个人数据的安全对我们很重要，但请记住，没有任何通过互联网传输的方法或电子存储方法是 100% 安全的。虽然我们努力使用商业上可接受的方式来保护您的个人数据，但我们无法保证其绝对安全。\n\n**儿童隐私**\n我们的服务不面向 13 岁以下的任何人。我们不会故意收集 13 岁以下任何人的个人身份信息。如果您是父母或监护人，并且您知道您的孩子向我们提供了个人数据，请与我们联系。\n\n**本隐私政策的变更**\n我们可能会不时更新我们的隐私政策。如有任何更改，我们会通过在此页面上发布新的隐私政策来通知您。';

  @override
  String get introduction => '介绍';

  @override
  String replyingTo(String username) {
    return '回复 $username';
  }

  @override
  String get postYourComment => '发表您的评论';

  @override
  String get beTheFirstToComment => '成为第一个发表评论的人';

  @override
  String viewAllReplies(int count) {
    return '查看全部 $count 条回复';
  }

  @override
  String commentDetails(int count) {
    return '$count 条回复';
  }

  @override
  String get addAComment => '添加评论';

  @override
  String get replies => '回复';

  @override
  String fileLimitExceeded(int count) {
    return '您最多只能选择 $count 个文件。';
  }

  @override
  String get selectPicturesFromAlbum => '从相册选择图片';

  @override
  String get selectVideoFromAlbum => '从相册选择视频';

  @override
  String get sportVideos => '运动视频';

  @override
  String get resetPassword => '重置密码';

  @override
  String get resetYourPassword => '重设您的密码';

  @override
  String get resetPasswordInstruction => '请输入您的邮箱地址，我们会向您发送一个验证码来重置密码。';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmNewPassword => '确认新密码';

  @override
  String get passwordsDoNotMatch => '两次输入的密码不一致';

  @override
  String get confirmReset => '确认重置';

  @override
  String get passwordResetSuccessLogin => '密码已成功重置，请登录';

  @override
  String get usernameAndEmailMismatch => '用户名和电子邮件不匹配';
}
