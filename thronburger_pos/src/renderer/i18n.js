'use strict';

// Full UI translations for English / German / Turkish. Every visible string
// resolves through TB.t(key). Missing keys fall back to English, then the key.

TB.dict = {
  en: {
    appName: 'Thronburger POS',
    // nav
    pos: 'POS', orders: 'Orders', reports: 'Reports', menu: 'Menu',
    staff: 'Staff', settings: 'Settings', logout: 'Logout',
    // login
    enterPin: 'Enter your PIN', wrongPin: 'Wrong PIN', staffLogin: 'Staff Login',
    // categories
    cat_all: 'All', cat_beef: 'Beef', cat_smash: 'Smash', cat_chicken: 'Chicken',
    cat_hotdog: 'Hot Dogs', cat_fingers: 'Fingers', cat_drinks: 'Drinks',
    // pos
    orderType: 'Order type', dinein: 'Dine-in', takeaway: 'Takeaway', delivery: 'Delivery',
    tableNo: 'Table no.', customerPhone: 'Customer / Phone', customerName: 'Customer name', discount: 'Discount',
    subtotal: 'Subtotal', total: 'Total', completePrint: 'Complete & Print',
    choosePayment: 'Choose payment', cash: 'Cash', card: 'Card',
    cartEmpty: 'Cart is empty — tap items to add', note: 'Note',
    notePlaceholder: 'e.g. extra cheese', remove: 'Remove',
    customize: 'Customize', removeIngredients: 'Ingredients (uncheck to remove)', no: 'No',
    orderSaved: 'Order #{n} saved', printFailed: 'Saved, but printing failed',
    // orders
    orderHistory: 'Order History', orderNo: 'Order', type: 'Type', table: 'Table',
    time: 'Time', cashier: 'Cashier', reprintReceipt: 'Reprint Receipt',
    reprintKitchen: 'Reprint Kitchen', void: 'Void', voided: 'Voided',
    selectOrderHint: 'Select an order to see details', noOrders: 'No orders yet',
    payment: 'Payment', items: 'Items', adminPinRequired: 'Admin PIN required',
    enterAdminPin: 'Enter admin PIN to void', orderVoided: 'Order voided', reprinted: 'Sent to printer',
    // reports
    revenue: 'Revenue', orderCount: 'Orders', avgOrder: 'Avg order', itemsSold: 'Items sold',
    topItems: 'Top items', revByCategory: 'Revenue by category', ordersByType: 'Orders by type',
    revByHour: 'Revenue by hour', revPerCashier: 'Revenue per cashier', cashVsCard: 'Cash vs card',
    today: 'Today', from: 'From', to: 'To', apply: 'Apply',
    zReport: 'Z-Report', generateZReport: 'Generate Z-Report',
    zReportConfirm: 'Generate a Z-Report for all sales since the last one? It will be saved and printed.',
    pastZReports: 'Past Z-Reports', reprint: 'Reprint', generated: 'Generated',
    cashiersToday: 'Cashiers see today only', zSaved: 'Z-Report saved & printed',
    // menu
    menuMgmt: 'Menu Management', addItem: 'Add item', name: 'Name', category: 'Category',
    price: 'Price', tag: 'Tag', deactivate: 'Deactivate', activate: 'Activate',
    resetMenu: 'Reset to default menu',
    resetMenuConfirm: 'This replaces the whole menu with the default Thronburger menu. Continue?',
    item: 'Item', actions: 'Actions', active: 'Active', inactive: 'Inactive', itemAdded: 'Item added',
    photo: 'Photo', addPhoto: 'Add photo', changePhoto: 'Change photo', removePhoto: 'Remove photo',
    ingredients: 'Ingredients', ingredientsHint: 'These can be removed per order on the POS.',
    addIngredientHint: 'Type an ingredient, press Enter', manageCategories: 'Categories',
    deleteCategory: 'Delete category', categoryName: 'Category name',
    extras: 'Extras', addExtras: 'Add extras', extrasHint: 'Paid add-ons — the cashier can add these per order; the price is added to the item.',
    // staff
    staffMgmt: 'Staff Management', addStaff: 'Add staff', pin: 'PIN', role: 'Role',
    admin: 'Admin', cashier_role: 'Cashier', changePin: 'Change PIN', newPin: 'New PIN',
    pinMustBe4: 'PIN must be exactly 4 digits', staffAdded: 'Staff added',
    // settings
    settingsTitle: 'Settings', cashierPrinter: 'Cashier printer', kitchenPrinter: 'Kitchen printer',
    testPrint: 'Test print', defaultLanguage: 'Default language', printerSettings: 'Printer settings',
    systemDefault: 'System default printer', saved: 'Saved', testSent: 'Test page sent',
    // common
    cancel: 'Cancel', confirm: 'Confirm', save: 'Save', add: 'Add', edit: 'Edit',
    close: 'Close', back: 'Back', none: 'None', mustBeAdmin: 'Admins only',
  },

  de: {
    appName: 'Thronburger POS',
    pos: 'Kasse', orders: 'Bestellungen', reports: 'Berichte', menu: 'Menü',
    staff: 'Personal', settings: 'Einstellungen', logout: 'Abmelden',
    enterPin: 'PIN eingeben', wrongPin: 'Falsche PIN', staffLogin: 'Personal-Login',
    cat_all: 'Alle', cat_beef: 'Rind', cat_smash: 'Smash', cat_chicken: 'Hähnchen',
    cat_hotdog: 'Hot Dogs', cat_fingers: 'Fingers', cat_drinks: 'Getränke',
    orderType: 'Bestellart', dinein: 'Vor Ort', takeaway: 'Zum Mitnehmen', delivery: 'Lieferung',
    tableNo: 'Tisch-Nr.', customerPhone: 'Kunde / Telefon', customerName: 'Kundenname', discount: 'Rabatt',
    subtotal: 'Zwischensumme', total: 'Gesamt', completePrint: 'Abschließen & Drucken',
    choosePayment: 'Zahlung wählen', cash: 'Bar', card: 'Karte',
    cartEmpty: 'Warenkorb leer — Artikel antippen', note: 'Notiz',
    notePlaceholder: 'z. B. extra Käse', remove: 'Entfernen',
    customize: 'Anpassen', removeIngredients: 'Zutaten (zum Entfernen abwählen)', no: 'Ohne',
    orderSaved: 'Bestellung #{n} gespeichert', printFailed: 'Gespeichert, aber Druck fehlgeschlagen',
    orderHistory: 'Bestellverlauf', orderNo: 'Bestellung', type: 'Art', table: 'Tisch',
    time: 'Zeit', cashier: 'Kassierer', reprintReceipt: 'Beleg erneut drucken',
    reprintKitchen: 'Küchenbon erneut', void: 'Stornieren', voided: 'Storniert',
    selectOrderHint: 'Bestellung für Details wählen', noOrders: 'Noch keine Bestellungen',
    payment: 'Zahlung', items: 'Artikel', adminPinRequired: 'Admin-PIN erforderlich',
    enterAdminPin: 'Admin-PIN zum Stornieren', orderVoided: 'Bestellung storniert', reprinted: 'An Drucker gesendet',
    revenue: 'Umsatz', orderCount: 'Bestellungen', avgOrder: 'Ø Bestellung', itemsSold: 'Verkaufte Artikel',
    topItems: 'Top-Artikel', revByCategory: 'Umsatz nach Kategorie', ordersByType: 'Bestellungen nach Art',
    revByHour: 'Umsatz nach Stunde', revPerCashier: 'Umsatz je Kassierer', cashVsCard: 'Bar vs. Karte',
    today: 'Heute', from: 'Von', to: 'Bis', apply: 'Anwenden',
    zReport: 'Z-Bericht', generateZReport: 'Z-Bericht erstellen',
    zReportConfirm: 'Z-Bericht für alle Verkäufe seit dem letzten erstellen? Wird gespeichert und gedruckt.',
    pastZReports: 'Frühere Z-Berichte', reprint: 'Erneut drucken', generated: 'Erstellt',
    cashiersToday: 'Kassierer sehen nur heute', zSaved: 'Z-Bericht gespeichert & gedruckt',
    menuMgmt: 'Menüverwaltung', addItem: 'Artikel hinzufügen', name: 'Name', category: 'Kategorie',
    price: 'Preis', tag: 'Tag', deactivate: 'Deaktivieren', activate: 'Aktivieren',
    resetMenu: 'Auf Standardmenü zurücksetzen',
    resetMenuConfirm: 'Ersetzt das gesamte Menü durch das Standard-Thronburger-Menü. Fortfahren?',
    item: 'Artikel', actions: 'Aktionen', active: 'Aktiv', inactive: 'Inaktiv', itemAdded: 'Artikel hinzugefügt',
    photo: 'Foto', addPhoto: 'Foto hinzufügen', changePhoto: 'Foto ändern', removePhoto: 'Foto entfernen',
    ingredients: 'Zutaten', ingredientsHint: 'Diese können pro Bestellung an der Kasse entfernt werden.',
    addIngredientHint: 'Zutat eingeben, Enter drücken', manageCategories: 'Kategorien',
    deleteCategory: 'Kategorie löschen', categoryName: 'Kategoriename',
    extras: 'Extras', addExtras: 'Extras hinzufügen', extrasHint: 'Kostenpflichtige Zusätze — der Kassierer kann diese pro Bestellung hinzufügen; der Preis wird addiert.',
    staffMgmt: 'Personalverwaltung', addStaff: 'Personal hinzufügen', pin: 'PIN', role: 'Rolle',
    admin: 'Admin', cashier_role: 'Kassierer', changePin: 'PIN ändern', newPin: 'Neue PIN',
    pinMustBe4: 'PIN muss genau 4 Ziffern haben', staffAdded: 'Personal hinzugefügt',
    settingsTitle: 'Einstellungen', cashierPrinter: 'Kassendrucker', kitchenPrinter: 'Küchendrucker',
    testPrint: 'Testdruck', defaultLanguage: 'Standardsprache', printerSettings: 'Druckereinstellungen',
    systemDefault: 'Standarddrucker des Systems', saved: 'Gespeichert', testSent: 'Testseite gesendet',
    cancel: 'Abbrechen', confirm: 'Bestätigen', save: 'Speichern', add: 'Hinzufügen', edit: 'Bearbeiten',
    close: 'Schließen', back: 'Zurück', none: 'Keine', mustBeAdmin: 'Nur für Admins',
  },

  tr: {
    appName: 'Thronburger POS',
    pos: 'Satış', orders: 'Siparişler', reports: 'Raporlar', menu: 'Menü',
    staff: 'Personel', settings: 'Ayarlar', logout: 'Çıkış',
    enterPin: 'PIN girin', wrongPin: 'Yanlış PIN', staffLogin: 'Personel Girişi',
    cat_all: 'Tümü', cat_beef: 'Dana', cat_smash: 'Smash', cat_chicken: 'Tavuk',
    cat_hotdog: 'Sosisli', cat_fingers: 'Fingers', cat_drinks: 'İçecekler',
    orderType: 'Sipariş türü', dinein: 'Masada', takeaway: 'Paket', delivery: 'Kurye',
    tableNo: 'Masa no.', customerPhone: 'Müşteri / Telefon', customerName: 'Müşteri adı', discount: 'İndirim',
    subtotal: 'Ara toplam', total: 'Toplam', completePrint: 'Tamamla & Yazdır',
    choosePayment: 'Ödeme seçin', cash: 'Nakit', card: 'Kart',
    cartEmpty: 'Sepet boş — ürünlere dokunun', note: 'Not',
    notePlaceholder: 'örn. ekstra peynir', remove: 'Kaldır',
    customize: 'Özelleştir', removeIngredients: 'Malzemeler (çıkarmak için işareti kaldır)', no: 'Yok',
    orderSaved: 'Sipariş #{n} kaydedildi', printFailed: 'Kaydedildi, ancak yazdırma başarısız',
    orderHistory: 'Sipariş Geçmişi', orderNo: 'Sipariş', type: 'Tür', table: 'Masa',
    time: 'Saat', cashier: 'Kasiyer', reprintReceipt: 'Fişi tekrar yazdır',
    reprintKitchen: 'Mutfak fişi tekrar', void: 'İptal et', voided: 'İptal edildi',
    selectOrderHint: 'Detay için sipariş seçin', noOrders: 'Henüz sipariş yok',
    payment: 'Ödeme', items: 'Ürünler', adminPinRequired: 'Yönetici PIN gerekli',
    enterAdminPin: 'İptal için yönetici PIN girin', orderVoided: 'Sipariş iptal edildi', reprinted: 'Yazıcıya gönderildi',
    revenue: 'Gelir', orderCount: 'Sipariş', avgOrder: 'Ort. sipariş', itemsSold: 'Satılan ürün',
    topItems: 'En çok satanlar', revByCategory: 'Kategoriye göre gelir', ordersByType: 'Türe göre sipariş',
    revByHour: 'Saate göre gelir', revPerCashier: 'Kasiyere göre gelir', cashVsCard: 'Nakit / Kart',
    today: 'Bugün', from: 'Başlangıç', to: 'Bitiş', apply: 'Uygula',
    zReport: 'Z-Raporu', generateZReport: 'Z-Raporu oluştur',
    zReportConfirm: 'Son rapordan bu yana tüm satışlar için Z-Raporu oluşturulsun mu? Kaydedilip yazdırılır.',
    pastZReports: 'Geçmiş Z-Raporları', reprint: 'Tekrar yazdır', generated: 'Oluşturuldu',
    cashiersToday: 'Kasiyerler yalnızca bugünü görür', zSaved: 'Z-Raporu kaydedildi & yazdırıldı',
    menuMgmt: 'Menü Yönetimi', addItem: 'Ürün ekle', name: 'Ad', category: 'Kategori',
    price: 'Fiyat', tag: 'Etiket', deactivate: 'Pasifleştir', activate: 'Aktifleştir',
    resetMenu: 'Varsayılan menüye sıfırla',
    resetMenuConfirm: 'Tüm menü varsayılan Thronburger menüsüyle değiştirilir. Devam?',
    item: 'Ürün', actions: 'İşlemler', active: 'Aktif', inactive: 'Pasif', itemAdded: 'Ürün eklendi',
    photo: 'Fotoğraf', addPhoto: 'Fotoğraf ekle', changePhoto: 'Fotoğraf değiştir', removePhoto: 'Fotoğrafı kaldır',
    ingredients: 'Malzemeler', ingredientsHint: 'Bunlar kasada sipariş başına çıkarılabilir.',
    addIngredientHint: 'Malzeme yazın, Enter’a basın', manageCategories: 'Kategoriler',
    deleteCategory: 'Kategori sil', categoryName: 'Kategori adı',
    extras: 'Ekstralar', addExtras: 'Ekstra ekle', extrasHint: 'Ücretli ekler — kasiyer sipariş başına ekleyebilir; fiyat ürüne eklenir.',
    staffMgmt: 'Personel Yönetimi', addStaff: 'Personel ekle', pin: 'PIN', role: 'Rol',
    admin: 'Yönetici', cashier_role: 'Kasiyer', changePin: 'PIN değiştir', newPin: 'Yeni PIN',
    pinMustBe4: 'PIN tam olarak 4 haneli olmalı', staffAdded: 'Personel eklendi',
    settingsTitle: 'Ayarlar', cashierPrinter: 'Kasa yazıcısı', kitchenPrinter: 'Mutfak yazıcısı',
    testPrint: 'Test yazdır', defaultLanguage: 'Varsayılan dil', printerSettings: 'Yazıcı ayarları',
    systemDefault: 'Sistem varsayılan yazıcısı', saved: 'Kaydedildi', testSent: 'Test sayfası gönderildi',
    cancel: 'Vazgeç', confirm: 'Onayla', save: 'Kaydet', add: 'Ekle', edit: 'Düzenle',
    close: 'Kapat', back: 'Geri', none: 'Yok', mustBeAdmin: 'Sadece yöneticiler',
  },
};

// Translate a key in the current language, with optional {n}-style params.
TB.t = function t(key, params) {
  const lang = TB.state.lang || 'en';
  const table = TB.dict[lang] || TB.dict.en;
  let s = table[key];
  if (s == null) s = TB.dict.en[key];
  if (s == null) s = key;
  if (params) for (const [k, v] of Object.entries(params)) s = s.replace('{' + k + '}', v);
  return s;
};

// Category label: use a built-in translation for the default categories,
// otherwise fall back to the custom label stored in the DB, then the key.
TB.catLabel = function catLabel(key) {
  if (key === 'all') return TB.t('cat_all');
  const tk = 'cat_' + key;
  const has = (TB.dict[TB.state.lang] && TB.dict[TB.state.lang][tk]) || TB.dict.en[tk];
  if (has) return TB.t(tk);
  const cat = (TB.state.categories || []).find((c) => c.key === key);
  return cat ? cat.label : key;
};
