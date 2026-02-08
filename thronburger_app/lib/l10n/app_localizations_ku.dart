// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get appTitle => 'ثرۆن بەرگەر';

  @override
  String get roleSelectionTitle => 'بەخێربێیت بۆ ثرۆن بەرگەر';

  @override
  String get roleSelectionSubtitle => 'دەتەوێت چی بکەیت؟';

  @override
  String get orderFood => 'خواردن داوا بکە';

  @override
  String get orderFoodDesc => 'لیستەکە بگەڕێ و داواکاری بکە';

  @override
  String get staffLogin => 'چوونەژوورەوەی کارمەندان';

  @override
  String get staffLoginDesc => 'دەستگەیشتن بە سیستەمی فرۆشتن و بەڕێوەبردن';

  @override
  String get phoneInputTitle => 'ژمارەی تەلەفۆنەکەت بنووسە';

  @override
  String get phoneInputSubtitle => 'کۆدی پشتڕاستکردنەوە بۆ دەنێرین';

  @override
  String get phoneHint => 'ژمارەی تەلەفۆن';

  @override
  String get sendCode => 'کۆد بنێرە';

  @override
  String get invalidPhone => 'تکایە ژمارەی تەلەفۆنی دروست بنووسە';

  @override
  String get otpTitle => 'تەلەفۆنەکەت پشتڕاست بکەرەوە';

  @override
  String otpSubtitle(String phone) {
    return 'کۆدی 6 ژمارەیی کە نێردراوە بۆ $phone بنووسە';
  }

  @override
  String get verify => 'پشتڕاستکردنەوە';

  @override
  String get resendCode => 'کۆدەکە دووبارە بنێرەوە';

  @override
  String resendCodeIn(int seconds) {
    return 'دووبارە ناردنەوە لە $seconds چرکەدا';
  }

  @override
  String get invalidOtp => 'کۆدی پشتڕاستکردنەوە هەڵەیە';

  @override
  String get otpExpired => 'کاتی کۆدەکە تەواو بوو. تکایە کۆدی نوێ داوا بکە.';

  @override
  String get nameEntryTitle => 'ناوت چییە؟';

  @override
  String get nameEntrySubtitle =>
      'ئەمە یارمەتیمان دەدات لە کەسیکردنی ئەزموونەکەت';

  @override
  String get nameHint => 'ناوەکەت';

  @override
  String get continueBtn => 'بەردەوام بە';

  @override
  String get skip => 'بازدان';

  @override
  String get home => 'سەرەتا';

  @override
  String get menu => 'لیستە';

  @override
  String get cart => 'سەبەتە';

  @override
  String get orders => 'داواکارییەکان';

  @override
  String get profile => 'پرۆفایل';

  @override
  String welcomeBack(String name) {
    return 'بەخێربێیتەوە، $name!';
  }

  @override
  String get browseMenu => 'لیستەکەمان بگەڕێ';

  @override
  String get viewOrders => 'داواکارییەکانت ببینە';

  @override
  String get quickActions => 'کردارە خێراکان';

  @override
  String get allCategories => 'هەموو';

  @override
  String get burgers => 'بەرگەر';

  @override
  String get sides => 'خواردنی لاوەکی';

  @override
  String get drinks => 'خواردنەوە';

  @override
  String get combos => 'کۆمبۆ';

  @override
  String get addToCart => 'زیادکردن بۆ سەبەتە';

  @override
  String get itemAdded => 'زیادکرا بۆ سەبەتە';

  @override
  String get viewCart => 'سەبەتە ببینە';

  @override
  String get emptyCart => 'سەبەتەکەت بەتاڵە';

  @override
  String get emptyCartSubtitle => 'هەندێک شتی خۆش لە لیستەکەمان زیاد بکە';

  @override
  String get browseMenuBtn => 'لیستە بگەڕێ';

  @override
  String get cartTotal => 'کۆی گشتی';

  @override
  String get itemNotes => 'ڕێنمایی تایبەت';

  @override
  String get itemNotesHint => 'بۆ نموونە: بێ پیاز، سۆسی زیاتر';

  @override
  String get checkout => 'پارەدان';

  @override
  String get clearCart => 'سەبەتە بەتاڵ بکەرەوە';

  @override
  String get clearCartConfirm => 'دڵنیایت لە بەتاڵکردنەوەی سەبەتەکە؟';

  @override
  String get clear => 'بەتاڵکردنەوە';

  @override
  String get cancel => 'پاشگەزبوونەوە';

  @override
  String get checkoutTitle => 'پارەدان';

  @override
  String get deliveryAddress => 'ناونیشانی گەیاندن';

  @override
  String get selectAddress => 'ناونیشانی گەیاندن هەڵبژێرە';

  @override
  String get addNewAddress => 'ناونیشانی نوێ زیاد بکە';

  @override
  String get noAddresses => 'هیچ ناونیشانێک پاشەکەوت نەکراوە';

  @override
  String get orderNotes => 'تێبینییەکانی داواکاری';

  @override
  String get orderNotesHint => 'هەر داواکارییەکی تایبەت بۆ داواکاریەکەت';

  @override
  String get placeOrder => 'داواکاری بکە';

  @override
  String get orderTotal => 'کۆی داواکاری';

  @override
  String get addressLabel => 'ناو';

  @override
  String get addressLabelHint => 'بۆ نموونە: ماڵ، کار';

  @override
  String get area => 'ناوچە';

  @override
  String get areaHint => 'بۆ نموونە: ناوەند';

  @override
  String get street => 'شەقام';

  @override
  String get streetHint => 'ناوی شەقام';

  @override
  String get building => 'بینا';

  @override
  String get buildingHint => 'ناو/ژمارەی بینا';

  @override
  String get apartment => 'شوقە';

  @override
  String get apartmentHint => 'ژمارەی شوقە (هەڵبژاردەیی)';

  @override
  String get landmark => 'نیشانە';

  @override
  String get landmarkHint => 'شوێنی نزیک (هەڵبژاردەیی)';

  @override
  String get addressNotes => 'تێبینی';

  @override
  String get addressNotesHint => 'ڕێنمایی گەیاندن (هەڵبژاردەیی)';

  @override
  String get setAsDefault => 'وەک ناونیشانی بنەڕەتی دابنێ';

  @override
  String get saveAddress => 'ناونیشان پاشەکەوت بکە';

  @override
  String get deleteAddress => 'ناونیشان بسڕەوە';

  @override
  String get deleteAddressConfirm => 'دڵنیایت لە سڕینەوەی ئەم ناونیشانە؟';

  @override
  String get delete => 'سڕینەوە';

  @override
  String get editAddress => 'ناونیشان دەستکاری بکە';

  @override
  String get orderPlaced => 'داواکاری وەرگیرا!';

  @override
  String orderPlacedSubtitle(int orderNumber) {
    return 'داواکاریەکەت ژمارە #$orderNumber وەرگیرا';
  }

  @override
  String get trackOrder => 'شوێن داواکاری بکەوە';

  @override
  String get backToHome => 'گەڕانەوە بۆ سەرەتا';

  @override
  String get orderTracking => 'شوێنکەوتنی داواکاری';

  @override
  String orderNumber(int number) {
    return 'داواکاری ژمارە #$number';
  }

  @override
  String get orderStatus => 'دۆخی داواکاری';

  @override
  String get statusPending => 'چاوەڕوان';

  @override
  String get statusPreparing => 'لە ئامادەکردندایە';

  @override
  String get statusReady => 'ئامادەیە';

  @override
  String get statusCompleted => 'تەواو بوو';

  @override
  String get statusCancelled => 'هەڵوەشێنراوە';

  @override
  String estimatedTime(int minutes) {
    return 'کاتی خەمڵێنراو: $minutes خولەک';
  }

  @override
  String get orderHistory => 'مێژووی داواکارییەکان';

  @override
  String get noOrders => 'هێشتا داواکاریت نییە';

  @override
  String get noOrdersSubtitle => 'مێژووی داواکارییەکانت لێرە دەردەکەوێت';

  @override
  String orderDate(String date) {
    return 'داواکراوە لە $date';
  }

  @override
  String get viewDetails => 'وردەکارییەکان ببینە';

  @override
  String get reorder => 'دووبارە داواکردن';

  @override
  String get profileTitle => 'پرۆفایل';

  @override
  String get personalInfo => 'زانیاری کەسی';

  @override
  String get name => 'ناو';

  @override
  String get phone => 'تەلەفۆن';

  @override
  String get email => 'ئیمەیڵ';

  @override
  String get addresses => 'ناونیشانە پاشەکەوتکراوەکان';

  @override
  String get manageAddresses => 'بەڕێوەبردنی ناونیشانەکان';

  @override
  String get language => 'زمان';

  @override
  String get english => 'ئینگلیزی';

  @override
  String get arabic => 'عەرەبی';

  @override
  String get kurdish => 'کوردی';

  @override
  String get logout => 'چوونەدەرەوە';

  @override
  String get logoutConfirm => 'دڵنیایت لە چوونەدەرەوە؟';

  @override
  String get operatingHours => 'کاتی کارکردن';

  @override
  String get openingTime => '4:00 ئێوارە - 11:00 شەو';

  @override
  String get closedMessage => 'ئێستا داخراوین';

  @override
  String get closedSubtitle =>
      'کاتژمێر 4:00 ئێوارە دەکەینەوە. بەزووی دەتبینینەوە!';

  @override
  String get error => 'هەڵە';

  @override
  String get somethingWentWrong => 'هەڵەیەک ڕوویدا';

  @override
  String get tryAgain => 'دووبارە هەوڵ بدەرەوە';

  @override
  String get noInternet => 'پەیوەندی ئینتەرنێت نییە';

  @override
  String get loading => 'چاوەڕوان بە...';

  @override
  String get save => 'پاشەکەوتکردن';

  @override
  String get edit => 'دەستکاری';

  @override
  String get done => 'تەواو';

  @override
  String get ok => 'باشە';

  @override
  String get yes => 'بەڵێ';

  @override
  String get no => 'نەخێر';

  @override
  String get currency => 'د.ع';

  @override
  String priceFormat(String price) {
    return '$price د.ع';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بەرهەم',
      one: '1 بەرهەم',
      zero: 'هیچ بەرهەمێک نییە',
    );
    return '$_temp0';
  }

  @override
  String get rateLimitError => 'هەوڵدانی زۆر. تکایە چەند خولەکێک چاوەڕوان بە.';

  @override
  String get phoneRequired => 'ژمارەی تەلەفۆن پێویستە';

  @override
  String get nameRequired => 'ناو پێویستە';

  @override
  String get addressRequired => 'تکایە ناونیشانی گەیاندن هەڵبژێرە';
}
