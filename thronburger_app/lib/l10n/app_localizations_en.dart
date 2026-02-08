// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Thronburger';

  @override
  String get roleSelectionTitle => 'Welcome to Thronburger';

  @override
  String get roleSelectionSubtitle => 'What would you like to do?';

  @override
  String get orderFood => 'Order Food';

  @override
  String get orderFoodDesc => 'Browse menu & place an order';

  @override
  String get staffLogin => 'Staff Login';

  @override
  String get staffLoginDesc => 'Access POS & admin features';

  @override
  String get phoneInputTitle => 'Enter your phone number';

  @override
  String get phoneInputSubtitle => 'We\'ll send you a verification code';

  @override
  String get phoneHint => 'Phone number';

  @override
  String get sendCode => 'Send Code';

  @override
  String get invalidPhone => 'Please enter a valid phone number';

  @override
  String get otpTitle => 'Verify your phone';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend Code';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get invalidOtp => 'Invalid verification code';

  @override
  String get otpExpired => 'Code expired. Please request a new one.';

  @override
  String get nameEntryTitle => 'What\'s your name?';

  @override
  String get nameEntrySubtitle => 'This helps us personalize your experience';

  @override
  String get nameHint => 'Your name';

  @override
  String get continueBtn => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get home => 'Home';

  @override
  String get menu => 'Menu';

  @override
  String get cart => 'Cart';

  @override
  String get orders => 'Orders';

  @override
  String get profile => 'Profile';

  @override
  String welcomeBack(String name) {
    return 'Welcome back, $name!';
  }

  @override
  String get browseMenu => 'Browse our menu';

  @override
  String get viewOrders => 'View your orders';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get allCategories => 'All';

  @override
  String get burgers => 'Burgers';

  @override
  String get sides => 'Sides';

  @override
  String get drinks => 'Drinks';

  @override
  String get combos => 'Combos';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get itemAdded => 'Added to cart';

  @override
  String get viewCart => 'View Cart';

  @override
  String get emptyCart => 'Your cart is empty';

  @override
  String get emptyCartSubtitle => 'Add some delicious items from our menu';

  @override
  String get browseMenuBtn => 'Browse Menu';

  @override
  String get cartTotal => 'Total';

  @override
  String get itemNotes => 'Special instructions';

  @override
  String get itemNotesHint => 'e.g., No onions, extra sauce';

  @override
  String get checkout => 'Checkout';

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get clearCartConfirm => 'Are you sure you want to clear your cart?';

  @override
  String get clear => 'Clear';

  @override
  String get cancel => 'Cancel';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get selectAddress => 'Select delivery address';

  @override
  String get addNewAddress => 'Add New Address';

  @override
  String get noAddresses => 'No addresses saved';

  @override
  String get orderNotes => 'Order Notes';

  @override
  String get orderNotesHint => 'Any special requests for your order';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get orderTotal => 'Order Total';

  @override
  String get addressLabel => 'Label';

  @override
  String get addressLabelHint => 'e.g., Home, Work';

  @override
  String get area => 'Area';

  @override
  String get areaHint => 'e.g., Downtown';

  @override
  String get street => 'Street';

  @override
  String get streetHint => 'Street name';

  @override
  String get building => 'Building';

  @override
  String get buildingHint => 'Building name/number';

  @override
  String get apartment => 'Apartment';

  @override
  String get apartmentHint => 'Apartment number (optional)';

  @override
  String get landmark => 'Landmark';

  @override
  String get landmarkHint => 'Nearby landmark (optional)';

  @override
  String get addressNotes => 'Notes';

  @override
  String get addressNotesHint => 'Delivery instructions (optional)';

  @override
  String get setAsDefault => 'Set as default address';

  @override
  String get saveAddress => 'Save Address';

  @override
  String get deleteAddress => 'Delete Address';

  @override
  String get deleteAddressConfirm =>
      'Are you sure you want to delete this address?';

  @override
  String get delete => 'Delete';

  @override
  String get editAddress => 'Edit Address';

  @override
  String get orderPlaced => 'Order Placed!';

  @override
  String orderPlacedSubtitle(int orderNumber) {
    return 'Your order #$orderNumber has been received';
  }

  @override
  String get trackOrder => 'Track Order';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get orderTracking => 'Order Tracking';

  @override
  String orderNumber(int number) {
    return 'Order #$number';
  }

  @override
  String get orderStatus => 'Order Status';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String estimatedTime(int minutes) {
    return 'Estimated time: $minutes mins';
  }

  @override
  String get orderHistory => 'Order History';

  @override
  String get noOrders => 'No orders yet';

  @override
  String get noOrdersSubtitle => 'Your order history will appear here';

  @override
  String orderDate(String date) {
    return 'Ordered on $date';
  }

  @override
  String get viewDetails => 'View Details';

  @override
  String get reorder => 'Reorder';

  @override
  String get profileTitle => 'Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get addresses => 'Saved Addresses';

  @override
  String get manageAddresses => 'Manage Addresses';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get kurdish => 'Kurdish';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get operatingHours => 'Operating Hours';

  @override
  String get openingTime => '4:00 PM - 11:00 PM';

  @override
  String get closedMessage => 'We\'re currently closed';

  @override
  String get closedSubtitle => 'We open at 4:00 PM. See you soon!';

  @override
  String get error => 'Error';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get loading => 'Loading...';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get currency => 'IQD';

  @override
  String priceFormat(String price) {
    return '$price IQD';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get rateLimitError => 'Too many attempts. Please wait a few minutes.';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get addressRequired => 'Please select a delivery address';
}
