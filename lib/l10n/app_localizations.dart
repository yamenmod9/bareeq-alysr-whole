import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      // App basics
      'appTitle': 'Bareeq Alysr',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'customer': 'Customer',
      'merchant': 'Merchant',
      'admin': 'Admin',
      
      // Menu items
      'dashboard': 'Dashboard',
      'acceptPurchase': 'Accept Purchase',
      'transactions': 'Transactions',
      'repayments': 'Repayments',
      'payment': 'Payment',
      'sendRequest': 'Send Request',
      'requests': 'Requests',
      'purchaseRequests': 'Purchase Requests',
      'settlements': 'Settlements',
      'users': 'Users',
      'customers': 'Customers',
      'merchants': 'Merchants',
      
      // Page titles and subtitles
      'creditRequestsTransactions': 'Credit, requests, and transactions',
      'reviewPendingRequests': 'Review pending purchase requests',
      'searchManageTransactions': 'Search and manage transactions',
      'plansInstallmentSchedule': 'Plans and installment schedule',
      'makePaymentGetReceipt': 'Make a payment and get receipt details',
      'profileSecurityPreferences': 'Profile, security, and preferences',
      'lookupCustomerSendRequest': 'Lookup customer and send purchase request',
      'trackFilterRequests': 'Track and filter purchase requests',
      'viewTransactionDetails': 'View transaction details and status',
      'reviewSettlementsRequest': 'Review settlements and request withdrawal',
      'roleStatusManagement': 'Role and status management',
      'creditCustomerOversight': 'Credit and customer status oversight',
      'merchantPerformanceModeration': 'Merchant performance and moderation',
      'settlementOperationsMonitoring': 'Settlement operations and monitoring',
      'systemKPIsActivity': 'System KPIs and activity',
      'adminDashboard': 'Admin Dashboard',
      'myTransactions': 'My Transactions',
      
      // Dashboard labels
      'availableBalance': 'Available balance',
      'outstanding': 'Outstanding',
      'creditLimit': 'Credit limit',
      'activeTransactions': 'Active transactions',
      'settlementBalance': 'Settlement balance',
      'totalSettled': 'Total settled',
      'requestCount': 'Request count',
      'approvedRequests': 'Approved requests',
      'settlementTotals': 'Settlement totals',
      'availableSettlementBalance': 'Available settlement balance',
      'quickActions': 'Quick actions',
      'sendRequestBtn': 'Send request',
      'viewSettlements': 'View settlements',
      'reviewRequests': 'Review requests',
      'requestApprovalRate': 'Request approval rate',
      'settlementProcessingHealth': 'Settlement processing health',
      'transactionApprovalsInStream': 'Transaction approvals in stream',
      'transactionPendingShare': 'Transaction pending share',
      'salesOverTime7d': 'Sales over time (7d)',
      'waitingForHistory': 'Waiting for transaction history from backend',
      'basedOnLiveTransactions': 'Based on live merchant transactions',
      'platformCommandCenter': 'Platform command center',
      'approvalHealth': 'approval health',
      'systemStatus': 'System status:',
      'operational': 'Operational',
      'reviewNeeded': 'Review needed',
      'upcomingPayments': 'Upcoming Payments',
      'pendingRequests': 'Pending Requests',
      'recentSettlements': 'Recent Settlements',
      
      // Form labels
      'customerCode': 'Customer code',
      'validateCustomer': 'Validate customer',
      'customerLookup': 'Customer lookup',
      'transactionDetails': 'Transaction details',
      'description': 'Description',
      'unitPrice': 'Unit price',
      'quantity': 'Quantity',
      'sendPurchaseRequest': 'Send purchase request',
      'profile': 'Profile',
      'shopName': 'Shop name',
      'businessEmail': 'Business email',
      'businessPhone': 'Business phone',
      'saveProfile': 'Save profile',
      'banking': 'Banking',
      'bankAccountInfo': 'Bank name, account number, IBAN',
      'withdrawalAmount': 'Withdrawal amount',
      'requestWithdrawal': 'Request withdrawal',
      'searchTransactions': 'Search transactions',
      'resetFilters': 'Reset filters',
      'fullName': 'Full Name',
      'email': 'Email',
      'password': 'Password',
      'phone': 'Phone',
      'nationalId': 'National ID',
      'role': 'Role',
      'amount': 'Amount',
      'totalAmount': 'Total Amount',
      
      // Buttons
      'accept': 'Accept',
      'reject': 'Reject',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'view': 'View',
      'submit': 'Submit',
      'close': 'Close',
      'back': 'Back',
      'next': 'Next',
      'search': 'Search',
      'filter': 'Filter',
      'export': 'Export',
      
      // Status labels
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'completed': 'Completed',
      'active': 'Active',
      'inactive': 'Inactive',
      'processing': 'Processing',
      'paid': 'Paid',
      'unpaid': 'Unpaid',
      'status': 'Status',
      
      // Table headers
      'transaction': 'Transaction',
      'transactionId': 'Transaction ID',
      'customerId': 'Customer',
      'merchantId': 'Merchant',
      'remaining': 'Remaining',
      'date': 'Date',
      'total': 'Total',
      
      // Validation messages
      'enterValid8CharCode': 'Enter a valid 8-character customer code',
      'validateCustomerFirst': 'Validate customer first',
      'invalidAmountOrQuantity': 'Invalid amount or quantity',
      'enterValidEmail': 'Enter valid email',
      'fieldRequired': 'This field is required',
      'invalidValue': 'Invalid value',
      
      // Success messages
      'requestSent': 'Request sent',
      'requestAccepted': 'Request accepted',
      'requestRejected': 'Request rejected',
      'withdrawalSubmitted': 'Withdrawal request submitted',
      'profileSaved': 'Profile settings saved',
      'changesSaved': 'Changes saved successfully',
      
      // Empty states
      'noPendingRequests': 'No pending requests',
      'noRequests': 'No requests',
      'noSettlements': 'No settlements yet',
      'noSettlementsYet': 'No settlements yet',
      'noTransactions': 'No transactions found',
      'noRepaymentPlans': 'No repayment plans',
      'noUpcomingPayments': 'No upcoming payments',
      'noDataAvailable': 'No data available',
      
      // Dialog messages
      'acceptRequestQuestion': 'Do you want to accept this request?',
      'rejectRequestQuestion': 'Do you want to reject this request?',
      'acceptRequestTitle': 'Accept request',
      'rejectRequestTitle': 'Reject request',
      'noDescriptionProvided': 'No description provided',
      
      // Installment related
      'installmentPlan': 'Installment Plan',
      'payInFull': 'Pay in Full',
      'months': 'Months',
      'monthlyPayment': 'Monthly payment',
      'numberOfInstallments': 'Number of installments',
      'installmentSchedule': 'Installment Schedule',
      'dueDate': 'Due Date',
      'paidInstallments': 'Paid Installments',
      'remainingInstallments': 'Remaining Installments',
      'installmentAmount': 'Installment Amount',
      'selectInstallmentPlan': 'Select Installment Plan',
      
      // Additional merchant dashboard
      'performanceQuality': 'Performance quality',
      'send': 'Send',
      'totalTransactions': 'Transactions',
      'other': 'Other',
      
      // Repayment details
      'installmentDetails': 'Installment Details',
      'paymentHistory': 'Payment History',
      'nextPayment': 'Next Payment',
      'overduePayment': 'Overdue Payment',
      'payNow': 'Pay Now',
      'viewDetails': 'View Details',
      'installmentNumber': 'Installment #',
      'paidOn': 'Paid on',
      'dueDateLabel': 'Due date',
      'noActiveInstallments': 'No active installments',
      'activeInstallments': 'Active Installments',
      'totalPaid': 'Total Paid',
      'totalRemaining': 'Total Remaining',
      'progress': 'Progress',
      'paymentReminder': 'Payment Reminder',
      'paymentDueMessage': 'Your installment payment is due',
      'markAsPaid': 'Mark as Paid',
      
      // Repayments page specific
      'monthsPlan': 'months plan',
      'totalLabel': 'Total',
      'remainingLabel': 'Remaining',
      'noActiveTransactions': 'No active transactions to pay',
      'paymentForm': 'Payment form',
      'remainingBefore': 'Remaining before',
      'remainingAfterPayment': 'Remaining after payment',
      'summary': 'Summary',
      'paymentSuccessful': 'Payment successful',
      
      // Settings page
      'branchAlerts': 'Branch alerts',
      'branchAlertsDesc': 'Notify when a branch changes status',
      'settlementStatusHint': 'Use real-time settlement status in the Settlements page to confirm payout state before requesting withdrawal.',
      'shopNameRequired': 'Shop name is required',
      'notificationsLabel': 'Notifications',
      'notificationsDesc': 'Enable push notifications',
      'yourCustomerCode': 'Your customer code',
      'tapToCopy': 'Tap to copy',
      'codeCopied': 'Code copied to clipboard',
      'refreshCode': 'Refresh code',
      'refreshCodeQuestion': 'Refresh customer code?',
      'refreshCodeWarning': 'The old code will no longer work and any pending requests will be invalidated.',
      'codeRefreshed': 'Code refreshed',
      'loading': 'Loading...',
      'unavailable': 'Unavailable',
      'regenerateCode': 'Regenerate code',
      'copyCode': 'Copy code',
      'pleaseWait': 'Please wait...',
      'nameRequired': 'Name is required',
      
      // Admin specific
      'userToCustomerRatio': 'User to customer ratio',
      'pendingSettlementsLoad': 'Pending settlements load',
      'operationalStatus': 'Operational status',
      'totalUsers': 'Total users',
      'moderationAlerts': 'Moderation alerts',
      'moderationAlertsDesc': 'Notify on high-risk approvals and rejections',
      'id': 'ID',
      'name': 'Name',
      'today': 'today',
      'days': 'days',
      'notifications': 'Notifications',
      'noNotifications': 'No notifications',
      'clearNotifications': 'Clear all',
    },
    'ar': {
      // App basics
      'appTitle': 'بريق اليسر',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
      'settings': 'الإعدادات',
      'theme': 'المظهر',
      'language': 'اللغة',
      'light': 'فاتح',
      'dark': 'داكن',
      'system': 'حسب النظام',
      'customer': 'عميل',
      'merchant': 'تاجر',
      'admin': 'مشرف',
      
      // Menu items
      'dashboard': 'لوحة المعلومات',
      'acceptPurchase': 'قبول الشراء',
      'transactions': 'المعاملات',
      'repayments': 'الدفعات',
      'payment': 'الدفع',
      'sendRequest': 'إرسال طلب',
      'requests': 'الطلبات',
      'purchaseRequests': 'طلبات الشراء',
      'settlements': 'التسويات',
      'users': 'المستخدمون',
      'customers': 'العملاء',
      'merchants': 'التجار',
      
      // Page titles and subtitles
      'creditRequestsTransactions': 'الائتمان والطلبات والمعاملات',
      'reviewPendingRequests': 'مراجعة طلبات الشراء المعلقة',
      'searchManageTransactions': 'البحث وإدارة المعاملات',
      'plansInstallmentSchedule': 'الخطط وجدول الأقساط',
      'makePaymentGetReceipt': 'إجراء الدفع والحصول على تفاصيل الإيصال',
      'profileSecurityPreferences': 'الملف الشخصي والأمان والتفضيلات',
      'lookupCustomerSendRequest': 'البحث عن العميل وإرسال طلب الشراء',
      'trackFilterRequests': 'تتبع وتصفية طلبات الشراء',
      'viewTransactionDetails': 'عرض تفاصيل المعاملة والحالة',
      'reviewSettlementsRequest': 'مراجعة التسويات وطلب السحب',
      'roleStatusManagement': 'إدارة الدور والحالة',
      'creditCustomerOversight': 'الإشراف على الائتمان وحالة العميل',
      'merchantPerformanceModeration': 'أداء التاجر والإشراف',
      'settlementOperationsMonitoring': 'عمليات التسوية والمراقبة',
      'systemKPIsActivity': 'مؤشرات الأداء والنشاط',
      'adminDashboard': 'لوحة الإدارة',
      'myTransactions': 'معاملاتي',
      
      // Dashboard labels
      'availableBalance': 'الرصيد المتاح',
      'outstanding': 'المستحق',
      'creditLimit': 'حد الائتمان',
      'activeTransactions': 'المعاملات النشطة',
      'settlementBalance': 'رصيد التسوية',
      'totalSettled': 'إجمالي المسوى',
      'requestCount': 'عدد الطلبات',
      'approvedRequests': 'الطلبات المعتمدة',
      'settlementTotals': 'إجمالي التسويات',
      'availableSettlementBalance': 'رصيد التسوية المتاح',
      'quickActions': 'إجراءات سريعة',
      'sendRequestBtn': 'إرسال طلب',
      'viewSettlements': 'عرض التسويات',
      'reviewRequests': 'مراجعة الطلبات',
      'requestApprovalRate': 'معدل الموافقة على الطلبات',
      'settlementProcessingHealth': 'صحة معالجة التسويات',
      'transactionApprovalsInStream': 'موافقات المعاملات الجارية',
      'transactionPendingShare': 'حصة المعاملات المعلقة',
      'salesOverTime7d': 'المبيعات عبر الوقت (7 أيام)',
      'waitingForHistory': 'في انتظار سجل المعاملات من الخادم',
      'basedOnLiveTransactions': 'بناءً على معاملات التاجر المباشرة',
      'platformCommandCenter': 'مركز التحكم بالمنصة',
      'approvalHealth': 'صحة الموافقات',
      'systemStatus': 'حالة النظام:',
      'operational': 'قيد التشغيل',
      'reviewNeeded': 'يحتاج للمراجعة',
      'upcomingPayments': 'الدفعات القادمة',
      'pendingRequests': 'الطلبات المعلقة',
      'recentSettlements': 'التسويات الأخيرة',
      
      // Form labels
      'customerCode': 'كود العميل',
      'validateCustomer': 'التحقق من العميل',
      'customerLookup': 'البحث عن العميل',
      'transactionDetails': 'تفاصيل المعاملة',
      'description': 'الوصف',
      'unitPrice': 'سعر الوحدة',
      'quantity': 'الكمية',
      'sendPurchaseRequest': 'إرسال طلب شراء',
      'profile': 'الملف الشخصي',
      'shopName': 'اسم المتجر',
      'businessEmail': 'البريد التجاري',
      'businessPhone': 'الهاتف التجاري',
      'saveProfile': 'حفظ الملف الشخصي',
      'banking': 'المعلومات المصرفية',
      'bankAccountInfo': 'اسم البنك ورقم الحساب والآيبان',
      'withdrawalAmount': 'مبلغ السحب',
      'requestWithdrawal': 'طلب سحب',
      'searchTransactions': 'البحث في المعاملات',
      'resetFilters': 'إعادة تعيين الفلاتر',
      'fullName': 'الاسم الكامل',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'phone': 'رقم الهاتف',
      'nationalId': 'رقم الهوية',
      'role': 'الدور',
      'amount': 'المبلغ',
      'totalAmount': 'المبلغ الإجمالي',
      
      // Buttons
      'accept': 'قبول',
      'reject': 'رفض',
      'confirm': 'تأكيد',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'view': 'عرض',
      'submit': 'إرسال',
      'close': 'إغلاق',
      'back': 'رجوع',
      'next': 'التالي',
      'search': 'بحث',
      'filter': 'تصفية',
      'export': 'تصدير',
      
      // Status labels
      'pending': 'معلق',
      'approved': 'معتمد',
      'rejected': 'مرفوض',
      'completed': 'مكتمل',
      'active': 'نشط',
      'inactive': 'غير نشط',
      'processing': 'قيد المعالجة',
      'paid': 'مدفوع',
      'unpaid': 'غير مدفوع',
      'status': 'الحالة',
      
      // Table headers
      'transaction': 'المعاملة',
      'transactionId': 'رقم المعاملة',
      'customerId': 'العميل',
      'merchantId': 'التاجر',
      'remaining': 'المتبقي',
      'date': 'التاريخ',
      'total': 'الإجمالي',
      
      // Validation messages
      'enterValid8CharCode': 'أدخل كود عميل صالح مكون من 8 أحرف',
      'validateCustomerFirst': 'تحقق من العميل أولاً',
      'invalidAmountOrQuantity': 'مبلغ أو كمية غير صالحة',
      'enterValidEmail': 'أدخل بريد إلكتروني صالح',
      'fieldRequired': 'هذا الحقل مطلوب',
      'invalidValue': 'قيمة غير صالحة',
      
      // Success messages
      'requestSent': 'تم إرسال الطلب',
      'requestAccepted': 'تم قبول الطلب',
      'requestRejected': 'تم رفض الطلب',
      'withdrawalSubmitted': 'تم تقديم طلب السحب',
      'profileSaved': 'تم حفظ إعدادات الملف الشخصي',
      'changesSaved': 'تم حفظ التغييرات بنجاح',
      
      // Empty states
      'noPendingRequests': 'لا توجد طلبات معلقة',
      'noRequests': 'لا توجد طلبات',
      'noSettlements': 'لا توجد تسويات بعد',
      'noSettlementsYet': 'لا توجد تسويات بعد',
      'noTransactions': 'لم يتم العثور على معاملات',
      'noRepaymentPlans': 'لا توجد خطط سداد',
      'noUpcomingPayments': 'لا توجد دفعات قادمة',
      'noDataAvailable': 'لا توجد بيانات متاحة',
      
      // Dialog messages
      'acceptRequestQuestion': 'هل تريد قبول هذا الطلب؟',
      'rejectRequestQuestion': 'هل تريد رفض هذا الطلب؟',
      'acceptRequestTitle': 'قبول الطلب',
      'rejectRequestTitle': 'رفض الطلب',
      'noDescriptionProvided': 'لم يتم تقديم وصف',
      
      // Installment related
      'installmentPlan': 'خطة التقسيط',
      'payInFull': 'الدفع الكامل',
      'months': 'أشهر',
      'monthlyPayment': 'الدفعة الشهرية',
      'numberOfInstallments': 'عدد الأقساط',
      'installmentSchedule': 'جدول الأقساط',
      'dueDate': 'تاريخ الاستحقاق',
      'paidInstallments': 'الأقساط المدفوعة',
      'remainingInstallments': 'الأقساط المتبقية',
      'installmentAmount': 'قيمة القسط',
      'selectInstallmentPlan': 'اختر خطة التقسيط',
      
      // Additional merchant dashboard
      'performanceQuality': 'جودة الأداء',
      'send': 'إرسال',
      'totalTransactions': 'المعاملات',
      'other': 'أخرى',
      
      // Repayment details
      'installmentDetails': 'تفاصيل الأقساط',
      'paymentHistory': 'سجل الدفعات',
      'nextPayment': 'الدفعة القادمة',
      'overduePayment': 'دفعة متأخرة',
      'payNow': 'ادفع الآن',
      'viewDetails': 'عرض التفاصيل',
      'installmentNumber': 'القسط رقم',
      'paidOn': 'تم الدفع في',
      'dueDateLabel': 'تاريخ الاستحقاق',
      'noActiveInstallments': 'لا توجد أقساط نشطة',
      'activeInstallments': 'الأقساط النشطة',
      'totalPaid': 'إجمالي المدفوع',
      'totalRemaining': 'إجمالي المتبقي',
      'progress': 'التقدم',
      'paymentReminder': 'تذكير بالدفع',
      'paymentDueMessage': 'موعد دفع القسط قد حان',
      'markAsPaid': 'تحديد كمدفوع',
      
      // Repayments page specific
      'monthsPlan': 'أشهر',
      'totalLabel': 'الإجمالي',
      'remainingLabel': 'المتبقي',
      'noActiveTransactions': 'لا توجد معاملات نشطة للدفع',
      'paymentForm': 'نموذج الدفع',
      'remainingBefore': 'المتبقي قبل الدفع',
      'remainingAfterPayment': 'المتبقي بعد الدفع',
      'summary': 'ملخص',
      'paymentSuccessful': 'تم الدفع بنجاح',
      
      // Settings page
      'branchAlerts': 'تنبيهات الفروع',
      'branchAlertsDesc': 'إشعار عند تغيير حالة فرع',
      'settlementStatusHint': 'استخدم حالة التسوية في الوقت الفعلي في صفحة التسويات للتأكد من حالة الدفع قبل طلب السحب.',
      'shopNameRequired': 'اسم المتجر مطلوب',
      'notificationsLabel': 'الإشعارات',
      'notificationsDesc': 'تفعيل الإشعارات الفورية',
      'yourCustomerCode': 'كود العميل الخاص بك',
      'tapToCopy': 'اضغط للنسخ',
      'codeCopied': 'تم نسخ الكود',
      'refreshCode': 'تحديث الكود',
      'refreshCodeQuestion': 'تحديث كود العميل؟',
      'refreshCodeWarning': 'لن يعمل الكود القديم بعد الآن وسيتم إلغاء جميع الطلبات المعلقة.',
      'codeRefreshed': 'تم تحديث الكود',
      'loading': 'جارٍ التحميل...',
      'unavailable': 'غير متاح',
      'regenerateCode': 'إعادة إنشاء الكود',
      'copyCode': 'نسخ الكود',
      'pleaseWait': 'الرجاء الانتظار...',
      'nameRequired': 'الاسم مطلوب',
      
      // Admin specific
      'userToCustomerRatio': 'نسبة المستخدم إلى العميل',
      'pendingSettlementsLoad': 'حمل التسويات المعلقة',
      'operationalStatus': 'حالة التشغيل',
      'totalUsers': 'إجمالي المستخدمين',
      'moderationAlerts': 'تنبيهات الإشراف',
      'moderationAlertsDesc': 'إشعار عند الموافقات والرفض عالية المخاطر',
      'id': 'المعرف',
      'name': 'الاسم',
      'today': 'اليوم',
      'days': 'أيام',
      'notifications': 'الإشعارات',
      'noNotifications': 'لا توجد إشعارات',
      'clearNotifications': 'مسح الكل',
    },
  };

  String t(String key) {
    final lang = _strings[locale.languageCode] ?? _strings['en']!;
    return lang[key] ?? _strings['en']![key] ?? key;
  }

  static AppLocalizations of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_AppLocalizationsInherited>();
    return inherited!.localizations;
  }
}

class AppLocalizationsProvider extends StatelessWidget {
  const AppLocalizationsProvider({
    super.key,
    required this.localizations,
    required this.child,
  });

  final AppLocalizations localizations;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _AppLocalizationsInherited(localizations: localizations, child: child);
  }
}

class _AppLocalizationsInherited extends InheritedWidget {
  const _AppLocalizationsInherited({
    required this.localizations,
    required super.child,
  });

  final AppLocalizations localizations;

  @override
  bool updateShouldNotify(covariant _AppLocalizationsInherited oldWidget) {
    return oldWidget.localizations.locale != localizations.locale;
  }
}
