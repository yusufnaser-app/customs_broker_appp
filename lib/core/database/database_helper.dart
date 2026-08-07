import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }
  
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'customs_broker.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // جدول المستخدمين
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // جدول العملاء
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        tax_number TEXT,
        commercial_register TEXT,
        balance REAL NOT NULL DEFAULT 0,
        notes TEXT,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // جدول التجار (المستوردين)
    await db.execute('''
      CREATE TABLE traders (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        tax_number TEXT,
        commercial_register TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // جدول الموردين
    await db.execute('''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        country TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // جدول الإقرارات الجمركية
    await db.execute('''
      CREATE TABLE declarations (
        id TEXT PRIMARY KEY,
        declaration_number TEXT NOT NULL,
        statement_number TEXT,
        statement_date TEXT,
        statement_type TEXT,
        customs_center TEXT,
        client_id TEXT NOT NULL,
        trader_id TEXT,
        supplier_id TEXT,
        origin_country TEXT,
        export_country TEXT,
        transport_method TEXT,
        container_number TEXT,
        invoice_number TEXT,
        invoice_date TEXT,
        invoice_value_usd REAL NOT NULL,
        currency TEXT NOT NULL DEFAULT 'USD',
        exchange_rate REAL NOT NULL,
        items_count INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'draft',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id),
        FOREIGN KEY (trader_id) REFERENCES traders(id),
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
      )
    ''');
    
    // جدول أصناف الإقرار
    await db.execute('''
      CREATE TABLE declaration_items (
        id TEXT PRIMARY KEY,
        declaration_id TEXT NOT NULL,
        hs_code TEXT NOT NULL,
        item_name TEXT NOT NULL,
        description TEXT,
        quantity REAL NOT NULL,
        weight REAL,
        unit TEXT NOT NULL,
        value REAL NOT NULL,
        origin_country TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (declaration_id) REFERENCES declarations(id) ON DELETE CASCADE
      )
    ''');
    
    // جدول النسخ التاريخية للإقرارات
    await db.execute('''
      CREATE TABLE declaration_snapshots (
        id TEXT PRIMARY KEY,
        declaration_id TEXT NOT NULL,
        exchange_rate REAL NOT NULL,
        fees_breakdown TEXT NOT NULL,
        total_fees REAL NOT NULL,
        snapshot_date TEXT NOT NULL,
        FOREIGN KEY (declaration_id) REFERENCES declarations(id)
      )
    ''');
    
    // جدول التعرفة الجمركية
    await db.execute('''
      CREATE TABLE tariff (
        id TEXT PRIMARY KEY,
        hs_code TEXT NOT NULL UNIQUE,
        item_name TEXT NOT NULL,
        description TEXT,
        chapter TEXT,
        unit TEXT,
        restrictions TEXT,
        permits TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // جدول الرسوم النسبية
    await db.execute('''
      CREATE TABLE relative_fees (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        rate REAL NOT NULL,
        calculation_base TEXT NOT NULL,
        execution_order INTEGER NOT NULL,
        effective_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
    
    // جدول الرسوم الثابتة
    await db.execute('''
      CREATE TABLE fixed_fees (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        effective_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
    
    // جدول أسعار الصرف
    await db.execute('''
      CREATE TABLE exchange_rates (
        id TEXT PRIMARY KEY,
        currency_from TEXT NOT NULL,
        currency_to TEXT NOT NULL,
        rate REAL NOT NULL,
        effective_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    
    // جدول فواتير الأتعاب
    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        invoice_number TEXT NOT NULL,
        client_id TEXT NOT NULL,
        declaration_id TEXT,
        fees_amount REAL NOT NULL DEFAULT 0,
        expenses_amount REAL NOT NULL DEFAULT 0,
        total_amount REAL NOT NULL,
        payment_status TEXT NOT NULL DEFAULT 'unpaid',
        due_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id),
        FOREIGN KEY (declaration_id) REFERENCES declarations(id)
      )
    ''');
    
    // جدول المدفوعات
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        invoice_id TEXT,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        reference_number TEXT,
        payment_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id),
        FOREIGN KEY (invoice_id) REFERENCES invoices(id)
      )
    ''');
    
    // جدول الصندوق
    await db.execute('''
      CREATE TABLE fund_transactions (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        reference_type TEXT,
        reference_id TEXT,
        transaction_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    
    // جدول المصروفات
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        payment_method TEXT,
        expense_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    
    // جدول الإيرادات
    await db.execute('''
      CREATE TABLE revenues (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        source TEXT,
        revenue_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    
    // جدول الحسابات البنكية
    await db.execute('''
      CREATE TABLE bank_accounts (
        id TEXT PRIMARY KEY,
        bank_name TEXT NOT NULL,
        account_number TEXT NOT NULL,
        account_name TEXT NOT NULL,
        currency TEXT NOT NULL DEFAULT 'YER',
        balance REAL NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // جدول المعاملات البنكية
    await db.execute('''
      CREATE TABLE bank_transactions (
        id TEXT PRIMARY KEY,
        bank_account_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        reference_number TEXT,
        transaction_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (bank_account_id) REFERENCES bank_accounts(id)
      )
    ''');
    
    // جدول المستندات
    await db.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        declaration_id TEXT NOT NULL,
        document_type TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_extension TEXT,
        file_size INTEGER,
        notes TEXT,
        uploaded_at TEXT NOT NULL,
        FOREIGN KEY (declaration_id) REFERENCES declarations(id) ON DELETE CASCADE
      )
    ''');
    
    // جدول الاشتراكات
    await db.execute('''
      CREATE TABLE subscriptions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        plan_type TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
    
    // جدول الإشعارات
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        reference_type TEXT,
        reference_id TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    
    // إدخال البيانات الافتراضية
    await _insertDefaultData(db);
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // للتحديثات المستقبلية
  }
  
  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // مستخدم افتراضي (مدير)
    await db.insert('users', {
      'id': 'admin-001',
      'username': 'admin',
      'password': 'admin123',
      'full_name': 'مدير النظام',
      'role': 'super_admin',
      'email': 'admin@customs.app',
      'phone': '775477377',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    
    // رسوم نسبية افتراضية
    final defaultRelativeFees = [
      {'code': 'ST', 'name': 'ضريبة المبيعات', 'rate': 5.0, 'base': 'invoice_value', 'order': 1},
      {'code': 'VAT', 'name': 'ضريبة القيمة المضافة', 'rate': 5.0, 'base': 'after_st', 'order': 2},
      {'code': 'PT', 'name': 'ضريبة أرباح تجارية', 'rate': 2.5, 'base': 'invoice_value', 'order': 3},
      {'code': 'TEF', 'name': 'رسم تنمية الصادرات', 'rate': 1.0, 'base': 'invoice_value', 'order': 4},
      {'code': '04', 'name': 'رسم إضافي 4%', 'rate': 4.0, 'base': 'invoice_value', 'order': 5},
    ];
    
    for (final fee in defaultRelativeFees) {
      await db.insert('relative_fees', {
        'id': 'fee-${fee['code']}',
        'code': fee['code'],
        'name': fee['name'],
        'rate': fee['rate'],
        'calculation_base': fee['base'],
        'execution_order': fee['order'],
        'effective_date': '2024-01-01',
        'is_active': 1,
        'created_at': now,
      });
    }
    
    // رسوم ثابتة افتراضية
    final defaultFixedFees = [
      {'code': 'SEAL', 'name': 'رسوم السيل', 'amount': 5000},
      {'code': 'SPECS', 'name': 'رسوم هيئة المواصفات والمقاييس', 'amount': 10000},
      {'code': 'TRANSPORT', 'name': 'رسوم هيئة تنظيم شؤون النقل البري', 'amount': 7500},
      {'code': 'MESSAGES', 'name': 'رسوم الرسائل', 'amount': 3000},
      {'code': 'EXTRA', 'name': 'الأجور الإضافية', 'amount': 5000},
    ];
    
    for (final fee in defaultFixedFees) {
      await db.insert('fixed_fees', {
        'id': 'fix-${fee['code']}',
        'code': fee['code'],
        'name': fee['name'],
        'amount': fee['amount'],
        'description': '',
        'effective_date': '2024-01-01',
        'is_active': 1,
        'created_at': now,
      });
    }
    
    // سعر صرف افتراضي
    await db.insert('exchange_rates', {
      'id': 'rate-001',
      'currency_from': 'USD',
      'currency_to': 'YER',
      'rate': 1250.0,
      'effective_date': '2024-01-01',
      'created_at': now,
    });
  }
}
