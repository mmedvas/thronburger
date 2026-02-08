// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ثرون برجر';

  @override
  String get roleSelectionTitle => 'مرحباً بك في ثرون برجر';

  @override
  String get roleSelectionSubtitle => 'ماذا تريد أن تفعل؟';

  @override
  String get orderFood => 'اطلب طعام';

  @override
  String get orderFoodDesc => 'تصفح القائمة وقدم طلبك';

  @override
  String get staffLogin => 'تسجيل دخول الموظفين';

  @override
  String get staffLoginDesc => 'الوصول إلى نقطة البيع والإدارة';

  @override
  String get phoneInputTitle => 'أدخل رقم هاتفك';

  @override
  String get phoneInputSubtitle => 'سنرسل لك رمز التحقق';

  @override
  String get phoneHint => 'رقم الهاتف';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get invalidPhone => 'الرجاء إدخال رقم هاتف صحيح';

  @override
  String get otpTitle => 'تحقق من هاتفك';

  @override
  String otpSubtitle(String phone) {
    return 'أدخل الرمز المكون من 6 أرقام المرسل إلى $phone';
  }

  @override
  String get verify => 'تحقق';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendCodeIn(int seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get invalidOtp => 'رمز التحقق غير صحيح';

  @override
  String get otpExpired => 'انتهت صلاحية الرمز. يرجى طلب رمز جديد.';

  @override
  String get nameEntryTitle => 'ما اسمك؟';

  @override
  String get nameEntrySubtitle => 'هذا يساعدنا في تخصيص تجربتك';

  @override
  String get nameHint => 'اسمك';

  @override
  String get continueBtn => 'متابعة';

  @override
  String get skip => 'تخطي';

  @override
  String get home => 'الرئيسية';

  @override
  String get menu => 'القائمة';

  @override
  String get cart => 'السلة';

  @override
  String get orders => 'الطلبات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String welcomeBack(String name) {
    return 'مرحباً بعودتك، $name!';
  }

  @override
  String get browseMenu => 'تصفح قائمتنا';

  @override
  String get viewOrders => 'عرض طلباتك';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get allCategories => 'الكل';

  @override
  String get burgers => 'برجر';

  @override
  String get sides => 'أطباق جانبية';

  @override
  String get drinks => 'مشروبات';

  @override
  String get combos => 'وجبات';

  @override
  String get addToCart => 'أضف للسلة';

  @override
  String get itemAdded => 'تمت الإضافة للسلة';

  @override
  String get viewCart => 'عرض السلة';

  @override
  String get emptyCart => 'سلتك فارغة';

  @override
  String get emptyCartSubtitle => 'أضف بعض الأطباق اللذيذة من قائمتنا';

  @override
  String get browseMenuBtn => 'تصفح القائمة';

  @override
  String get cartTotal => 'المجموع';

  @override
  String get itemNotes => 'تعليمات خاصة';

  @override
  String get itemNotesHint => 'مثال: بدون بصل، صوص إضافي';

  @override
  String get checkout => 'الدفع';

  @override
  String get clearCart => 'إفراغ السلة';

  @override
  String get clearCartConfirm => 'هل أنت متأكد من إفراغ السلة؟';

  @override
  String get clear => 'إفراغ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get checkoutTitle => 'الدفع';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get selectAddress => 'اختر عنوان التوصيل';

  @override
  String get addNewAddress => 'إضافة عنوان جديد';

  @override
  String get noAddresses => 'لا توجد عناوين محفوظة';

  @override
  String get orderNotes => 'ملاحظات الطلب';

  @override
  String get orderNotesHint => 'أي طلبات خاصة لطلبك';

  @override
  String get placeOrder => 'تأكيد الطلب';

  @override
  String get orderTotal => 'إجمالي الطلب';

  @override
  String get addressLabel => 'التسمية';

  @override
  String get addressLabelHint => 'مثال: المنزل، العمل';

  @override
  String get area => 'المنطقة';

  @override
  String get areaHint => 'مثال: وسط المدينة';

  @override
  String get street => 'الشارع';

  @override
  String get streetHint => 'اسم الشارع';

  @override
  String get building => 'المبنى';

  @override
  String get buildingHint => 'اسم/رقم المبنى';

  @override
  String get apartment => 'الشقة';

  @override
  String get apartmentHint => 'رقم الشقة (اختياري)';

  @override
  String get landmark => 'علامة مميزة';

  @override
  String get landmarkHint => 'معلم قريب (اختياري)';

  @override
  String get addressNotes => 'ملاحظات';

  @override
  String get addressNotesHint => 'تعليمات التوصيل (اختياري)';

  @override
  String get setAsDefault => 'تعيين كعنوان افتراضي';

  @override
  String get saveAddress => 'حفظ العنوان';

  @override
  String get deleteAddress => 'حذف العنوان';

  @override
  String get deleteAddressConfirm => 'هل أنت متأكد من حذف هذا العنوان؟';

  @override
  String get delete => 'حذف';

  @override
  String get editAddress => 'تعديل العنوان';

  @override
  String get orderPlaced => 'تم استلام الطلب!';

  @override
  String orderPlacedSubtitle(int orderNumber) {
    return 'تم استلام طلبك رقم #$orderNumber';
  }

  @override
  String get trackOrder => 'تتبع الطلب';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get orderTracking => 'تتبع الطلب';

  @override
  String orderNumber(int number) {
    return 'طلب رقم #$number';
  }

  @override
  String get orderStatus => 'حالة الطلب';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusPreparing => 'جاري التحضير';

  @override
  String get statusReady => 'جاهز';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String estimatedTime(int minutes) {
    return 'الوقت المتوقع: $minutes دقيقة';
  }

  @override
  String get orderHistory => 'سجل الطلبات';

  @override
  String get noOrders => 'لا توجد طلبات بعد';

  @override
  String get noOrdersSubtitle => 'سيظهر سجل طلباتك هنا';

  @override
  String orderDate(String date) {
    return 'تم الطلب في $date';
  }

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get reorder => 'إعادة الطلب';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get name => 'الاسم';

  @override
  String get phone => 'الهاتف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get addresses => 'العناوين المحفوظة';

  @override
  String get manageAddresses => 'إدارة العناوين';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get kurdish => 'الكردية';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get operatingHours => 'ساعات العمل';

  @override
  String get openingTime => '4:00 مساءً - 11:00 مساءً';

  @override
  String get closedMessage => 'نحن مغلقون حالياً';

  @override
  String get closedSubtitle => 'نفتح الساعة 4:00 مساءً. نراكم قريباً!';

  @override
  String get error => 'خطأ';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get done => 'تم';

  @override
  String get ok => 'موافق';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

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
      other: '$count عنصر',
      few: '$count عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
      zero: 'لا توجد عناصر',
    );
    return '$_temp0';
  }

  @override
  String get rateLimitError => 'محاولات كثيرة جداً. يرجى الانتظار بضع دقائق.';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get addressRequired => 'يرجى اختيار عنوان التوصيل';
}
