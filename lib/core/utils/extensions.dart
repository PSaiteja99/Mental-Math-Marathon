extension IntExtension on int {
  String get toHms {
    final h = (this ~/ 3600).toString().padLeft(2, '0');
    final m = ((this % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (this % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
