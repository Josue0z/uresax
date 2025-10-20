
extension StringExtension on String {
  String phoneFormat() => replaceAllMapped(
        RegExp(r'(\d{1})(\d{3})(\d{3})(\d{4})'),
        (final Match m) => '${m[1]}-(${m[2]})-(${m[3]})-(${m[4]})',
      );
}
