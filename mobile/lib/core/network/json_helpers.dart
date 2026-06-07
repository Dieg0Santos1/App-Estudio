DateTime parseDateTime(Object? value) {
  if (value is! String) {
    throw FormatException('Expected ISO date string, got $value.');
  }

  return DateTime.parse(value);
}

DateTime? parseOptionalDateTime(Object? value) {
  if (value == null) {
    return null;
  }

  return parseDateTime(value);
}

List<String> parseStringList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value.whereType<String>().toList(growable: false);
}

Map<String, dynamic> parseJsonMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return const {};
}
