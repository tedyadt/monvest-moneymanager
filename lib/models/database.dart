import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:monvest/models/category.dart';
import 'package:monvest/models/transaction.dart';
import 'package:monvest/models/transaction_with_category.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 6, max: 32)();
  TextColumn get content => text().named('body')();
  DateTimeColumn get createdAt => dateTime().nullable()();
}

@DriftDatabase(tables: [Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  //crude category
  Future<List<Category>> getAllCategoriesRepo(int type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
        .get();
  }

  

  Future updateCategoriesRepo(int id, String name) async {
    return await (update(categories)..where((tbl) => tbl.id.equals(id)))
        .write(CategoriesCompanion(name: Value(name)));
  }

  Future deleteCategoriesRepo(int id) async {
    return await (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  //transactions
  Stream<List<TransactionWithCategory>> getTransactionByDate(DateTime date) {
  final start = DateTime(date.year, date.month, date.day);
  final end = start.add(Duration(days: 1));

  final query = (select(transactions).join([
    innerJoin(categories, categories.id.equalsExp(transactions.category_id))
  ])
    ..where(transactions.transaction_date.isBiggerOrEqualValue(start))
    ..where(transactions.transaction_date.isSmallerThanValue(end)));

  return query.watch().map((rows) {
    return rows.map((row) {
      return TransactionWithCategory(
        row.readTable(transactions),
        row.readTable(categories),
      );
    }).toList();
  });
}


  Future updateTransactionRepo(int id, int amount, int categoryid,
      DateTime transactiondate, String description) async {
    return await (update(transactions)..where((tbl) => tbl.id.equals(id)))
        .write(TransactionsCompanion(
      amount: Value(amount),
      name: Value(description),
      category_id: Value(categoryid),
      transaction_date: Value(transactiondate),
      updatedAt: Value(DateTime.now()),
    
    ));

  }

  Future deleteTransactionRepo(int id) async {
    return await (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

  Stream<Map<String, int>> getMonthlySummary(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);

    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ])
      ..where(transactions.transaction_date.isBiggerOrEqualValue(firstDay) &
          transactions.transaction_date.isSmallerOrEqualValue(lastDay)));

    return query.watch().map((rows) {
      int totalIncome = 0;
      int totalOutcome = 0;

      for (var row in rows) {
        final transaction = row.readTable(transactions);
        final category = row.readTable(categories);

        if (category.type == 1) {
          totalIncome += transaction.amount;
        } else if (category.type == 2) {
          totalOutcome += transaction.amount;
        }
      }

      return {
        "income": totalIncome,
        "outcome": totalOutcome,
      };
    });
  }

  

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }
}


