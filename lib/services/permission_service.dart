import 'package:photo_manager/photo_manager.dart';

abstract class IPermissionService {
  Future<PermissionState> requestPermissions();
  Future<PermissionState> getPermissionState();
  Future<void> presentLimitedPicker();
  bool isAuthorized(PermissionState state);
  bool isLimited(PermissionState state);
}

class PhotoManagerPermissionService implements IPermissionService {
  @override
  Future<PermissionState> requestPermissions() async {
    return PhotoManager.requestPermissionExtend();
  }

  @override
  Future<PermissionState> getPermissionState() async {
    // requestPermissionExtend returns current state if already prompted
    return PhotoManager.requestPermissionExtend();
  }

  @override
  Future<void> presentLimitedPicker() async {
    await PhotoManager.presentLimited();
  }

  @override
  bool isAuthorized(PermissionState state) {
    return state.isAuth && state != PermissionState.limited;
  }

  @override
  bool isLimited(PermissionState state) {
    return state == PermissionState.limited;
  }
}
