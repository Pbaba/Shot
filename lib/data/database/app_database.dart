import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/review_records.dart';
import 'tables/undo_history.dart';
import 'daos/review_dao.dart';
import 'daos/history_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [ReviewedScreenshots, ReviewHistory],
  daos: [ReviewDao, HistoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'shot_app_database',
      native: const DriftNativeOptions(
        shareAcrossIsolates: true,
      ),
    );
  }
}
