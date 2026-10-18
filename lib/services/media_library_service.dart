import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import '../domain/models/screenshot_item.dart';

abstract class IMediaLibraryService {
  Future<List<ScreenshotItem>> fetchScreenshotsPaged({
    required int page,
    required int size,
    String? customDirectoryPath,
  });

  Future<int> getTotalScreenshotCount({String? customDirectoryPath});

  Future<AssetEntity?> obtainForId(String id);

  Future<List<String>> deleteWithIds(List<String> ids);
}

class PhotoManagerMediaLibraryService implements IMediaLibraryService {
  @override
  Future<AssetEntity?> obtainForId(String id) async {
    try {
      return await AssetEntity.fromId(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> deleteWithIds(List<String> ids) async {
    try {
      return await PhotoManager.editor.deleteWithIds(ids);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<int> getTotalScreenshotCount({String? customDirectoryPath}) async {
    final album = await _getScreenshotsAlbum(customDirectoryPath: customDirectoryPath);
    if (album == null) return 0;
    return album.assetCountAsync;
  }

  @override
  Future<List<ScreenshotItem>> fetchScreenshotsPaged({
    required int page,
    required int size,
    String? customDirectoryPath,
  }) async {
    final album = await _getScreenshotsAlbum(customDirectoryPath: customDirectoryPath);
    if (album == null) return [];

    final entities = await album.getAssetListPaged(page: page, size: size);
    return entities.map((e) => ScreenshotItem.fromAssetEntity(e)).toList();
  }

  /// Locates the screenshots collection using Darwin smart albums on iOS
  /// or multi-tier path filtering on Android.
  Future<AssetPathEntity?> _getScreenshotsAlbum({String? customDirectoryPath}) async {
    if (Platform.isIOS || Platform.isMacOS) {
      // Query iOS Screenshots Smart Album
      final darwinFilter = PMDarwinPathFilter(
        type: [PMDarwinAssetCollectionType.smartAlbum],
        subType: [PMDarwinAssetCollectionSubtype.smartAlbumScreenshots],
      );
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        pathFilterOption: PMPathFilter(darwin: darwinFilter),
      );
      return paths.isNotEmpty ? paths.first : null;
    } else if (Platform.isAndroid) {
      // Query Android MediaStore
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );
      if (paths.isEmpty) return null;

      // Tier 1 & 2: Match against screenshot bucket names and paths
      for (final path in paths) {
        final name = path.name.toLowerCase();
        if (name == 'screenshots' ||
            name == 'screen shots' ||
            name == 'capturas de pantalla' ||
            name == 'captures d\'écran' ||
            name == 'bildschirminhalte' ||
            name == '屏幕截图' ||
            name == 'スクリーンショット' ||
            name == '스크린샷') {
          return path;
        }
      }

      // If customDirectoryPath provided, match custom folder
      if (customDirectoryPath != null) {
        for (final path in paths) {
          if (path.name.toLowerCase() == customDirectoryPath.toLowerCase()) {
            return path;
          }
        }
      }

      // Return null if no screenshot album matched (triggers honest empty state)
      return null;
    }

    return null;
  }
}
