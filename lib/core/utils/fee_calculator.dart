import 'package:sqflite/sqflite.dart';

class FeeBreakdown {
  final double exchangeRate;
  final double invoiceValueUsd;
  final double invoiceValueYer;
  final List<FeeItem> relativeFees;
  final List<FeeItem> fixedFees;
  final double totalRelativeFees;
  final double totalFixedFees;
  final double grandTotal;

  const FeeBreakdown({
    required this.exchangeRate,
    required this.invoiceValueUsd,
    required this.invoiceValueYer,
    required this.relativeFees,
    required this.fixedFees,
    required this.totalRelativeFees,
    required this.totalFixedFees,
    required this.grandTotal,
  });

  Map<String, dynamic> toJson() {
    return {
      'exchangeRate': exchangeRate,
      'invoiceValueUsd': invoiceValueUsd,
      'invoiceValueYer': invoiceValueYer,
      'relativeFees': relativeFees.map((f) => f.toJson()).toList(),
      'fixedFees': fixedFees.map((f) => f.toJson()).toList(),
      'totalRelativeFees': totalRelativeFees,
      'totalFixedFees': totalFixedFees,
      'grandTotal': grandTotal,
    };
  }

  factory FeeBreakdown.fromJson(Map<String, dynamic> json) {
    return FeeBreakdown(
      exchangeRate: json['exchangeRate'] ?? 0,
      invoiceValueUsd: json['invoiceValueUsd'] ?? 0,
      invoiceValueYer: json['invoiceValueYer'] ?? 0,
      relativeFees: (json['relativeFees'] as List?)?.map((f) => FeeItem.fromJson(f)).toList() ?? [],
      fixedFees: (json['fixedFees'] as List?)?.map((f) => FeeItem.fromJson(f)).toList() ?? [],
      totalRelativeFees: json['totalRelativeFees'] ?? 0,
      totalFixedFees: json['totalFixedFees'] ?? 0,
      grandTotal: json['grandTotal'] ?? 0,
    );
  }
}

class FeeItem {
  final String code;
  final String name;
  final double rate;
  final double amount;
  final String? calculationBase;

  const FeeItem({
    required this.code,
    required this.name,
    required this.rate,
    required this.amount,
    this.calculationBase,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'rate': rate,
      'amount': amount,
      'calculationBase': calculationBase,
    };
  }

  factory FeeItem.fromJson(Map<String, dynamic> json) {
    return FeeItem(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
      calculationBase: json['calculationBase'],
    );
  }
}

class FeeCalculator {
  final Database _database;

  FeeCalculator(this._database);

  Future<FeeBreakdown> calculateFees(double invoiceValueUsd) async {
    // جلب أحدث سعر صرف
    final exchangeRates = await _database.query(
      'exchange_rates',
      where: 'currency_from = ? AND currency_to = ?',
      whereArgs: ['USD', 'YER'],
      orderBy: 'effective_date DESC',
      limit: 1,
    );

    double exchangeRate = 1250.0;
    if (exchangeRates.isNotEmpty) {
      exchangeRate = (exchangeRates.first['rate'] as num).toDouble();
    }

    // تحويل قيمة الفاتورة للريال
    final invoiceValueYer = invoiceValueUsd * exchangeRate;

    // جلب الرسوم النسبية المفعلة مرتبة حسب ترتيب التنفيذ
    final relativeFeesData = await _database.query(
      'relative_fees',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'execution_order ASC',
    );

    // جلب الرسوم الثابتة المفعلة
    final fixedFeesData = await _database.query(
      'fixed_fees',
      where: 'is_active = ?',
      whereArgs: [1],
    );

    final List<FeeItem> relativeFees = [];
    double currentBase = invoiceValueYer;
    double totalRelativeFees = 0;

    for (final feeData in relativeFeesData) {
      final rate = (feeData['rate'] as num).toDouble();
      final calculationBase = feeData['calculation_base'] as String?;
      
      double baseAmount;
      if (calculationBase == 'after_st') {
        baseAmount = currentBase;
      } else {
        baseAmount = invoiceValueYer;
      }
      
      final feeAmount = baseAmount * (rate / 100);
      
      relativeFees.add(FeeItem(
        code: feeData['code'] as String,
        name: feeData['name'] as String,
        rate: rate,
        amount: feeAmount,
        calculationBase: calculationBase,
      ));
      
      currentBase += feeAmount;
      totalRelativeFees += feeAmount;
    }

    final List<FeeItem> fixedFees = [];
    double totalFixedFees = 0;

    for (final feeData in fixedFeesData) {
      final amount = (feeData['amount'] as num).toDouble();
      
      fixedFees.add(FeeItem(
        code: feeData['code'] as String,
        name: feeData['name'] as String,
        rate: 0,
        amount: amount,
        calculationBase: 'fixed',
      ));
      
      totalFixedFees += amount;
    }

    final grandTotal = totalRelativeFees + totalFixedFees;

    return FeeBreakdown(
      exchangeRate: exchangeRate,
      invoiceValueUsd: invoiceValueUsd,
      invoiceValueYer: invoiceValueYer,
      relativeFees: relativeFees,
      fixedFees: fixedFees,
      totalRelativeFees: totalRelativeFees,
      totalFixedFees: totalFixedFees,
      grandTotal: grandTotal,
    );
  }

  Future<void> saveSnapshot(String declarationId, FeeBreakdown breakdown) async {
    final now = DateTime.now().toIso8601String();
    
    await _database.insert('declaration_snapshots', {
      'id': 'snap-$declarationId-${DateTime.now().millisecondsSinceEpoch}',
      'declaration_id': declarationId,
      'exchange_rate': breakdown.exchangeRate,
      'fees_breakdown': _mapToJsonString(breakdown.toJson()),
      'total_fees': breakdown.grandTotal,
      'snapshot_date': now,
    });
  }

  String _mapToJsonString(Map<String, dynamic> map) {
    return map.toString();
  }
}
