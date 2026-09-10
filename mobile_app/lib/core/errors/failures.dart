abstract class LusterFailure implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const LusterFailure(this.message, {this.code, this.details});

  @override
  String toString() => 'LusterFailure: $message (${code ?? 'UNKNOWN'})';
}

class CameraFailure extends LusterFailure {
  const CameraFailure(super.message, {super.code, super.details});
}

class StorageFailure extends LusterFailure {
  const StorageFailure(super.message, {super.code, super.details});
}

class RenderFailure extends LusterFailure {
  const RenderFailure(super.message, {super.code, super.details});
}

class UploadFailure extends LusterFailure {
  const UploadFailure(super.message, {super.code, super.details});
}

class NetworkFailure extends LusterFailure {
  const NetworkFailure(super.message, {super.code, super.details});
}

class PermissionFailure extends LusterFailure {
  const PermissionFailure(super.message, {super.code, super.details});
}
