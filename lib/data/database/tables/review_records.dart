import 'package:drift/drift.dart';

/// Table storing the persistent review state of screenshot assets.
/// Asset identifiers match PhotoManager IDs (MediaStore _ID or PHAsset localIdentifier).
@DataClassName('ReviewedScreenshotRecord')
class ReviewedScreenshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get assetId => text().unique()();
  TextColumn get reviewState => text()(); // String representation of ReviewState
  IntColumn get reviewedAt => integer()(); // Epoch milliseconds
  TextColumn get sessionId => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {assetId},
  ];
}
