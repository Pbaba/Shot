import 'package:drift/drift.dart';

/// Table storing the atomic action history for LIFO Undo operations.
/// Primary key `id` auto-increments to provide deterministic tie-breaking on shared timestamps.
@DataClassName('ReviewHistoryRecord')
class ReviewHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get assetId => text()();
  TextColumn get previousState => text()();
  TextColumn get newState => text()();
  TextColumn get sessionId => text()();
  IntColumn get actionTimestamp => integer()(); // Epoch milliseconds
}
