import 'package:photo_manager/photo_manager.dart';
import 'review_state.dart';

/// Clean domain entity representing a screenshot in the review pipeline.
class ScreenshotItem {
  final String id;
  final String? title;
  final String? relativePath;
  final DateTime createDateTime;
  final int width;
  final int height;
  final int size;
  final ReviewState reviewState;
  final AssetEntity? entity;

  const ScreenshotItem({
    required this.id,
    this.title,
    this.relativePath,
    required this.createDateTime,
    required this.width,
    required this.height,
    required this.size,
    this.reviewState = ReviewState.unreviewed,
    this.entity,
  });

  ScreenshotItem copyWith({
    String? id,
    String? title,
    String? relativePath,
    DateTime? createDateTime,
    int? width,
    int? height,
    int? size,
    ReviewState? reviewState,
    AssetEntity? entity,
  }) {
    return ScreenshotItem(
      id: id ?? this.id,
      title: title ?? this.title,
      relativePath: relativePath ?? this.relativePath,
      createDateTime: createDateTime ?? this.createDateTime,
      width: width ?? this.width,
      height: height ?? this.height,
      size: size ?? this.size,
      reviewState: reviewState ?? this.reviewState,
      entity: entity ?? this.entity,
    );
  }

  factory ScreenshotItem.fromAssetEntity(AssetEntity entity, {ReviewState state = ReviewState.unreviewed}) {
    return ScreenshotItem(
      id: entity.id,
      title: entity.title,
      relativePath: entity.relativePath,
      createDateTime: entity.createDateTime,
      width: entity.width,
      height: entity.height,
      size: entity.size.width.toInt(), // fallback size dimension
      reviewState: state,
      entity: entity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenshotItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
