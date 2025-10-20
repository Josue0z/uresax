import 'dart:convert';

import 'package:uresaxapp/apis/connection.dart';

class RetentionTax {
  int? id;
  String? name;
  int? rate;
  RetentionTax({
    this.id,
    this.name,
    this.rate,
  });

  static Future<List<RetentionTax>> all() async {
    try {
      var result = await connection
          .mappedResultsQuery('''SELECT * FROM public."RetentionTax"''');
      return result
          .map((e) => RetentionTax.fromMap(e['RetentionTax']!))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  RetentionTax copyWith({
    int? id,
    String? name,
    int? rate,
  }) {
    return RetentionTax(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({'id': id});
    }
    if (name != null) {
      result.addAll({'name': name});
    }
    if (rate != null) {
      result.addAll({'rate': rate});
    }

    return result;
  }

  factory RetentionTax.fromMap(Map<String, dynamic> map) {
    return RetentionTax(
      id: map['id']?.toInt(),
      name: map['name'],
      rate: map['rate']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory RetentionTax.fromJson(String source) =>
      RetentionTax.fromMap(json.decode(source));

  @override
  String toString() => 'RetentionTax(id: $id, name: $name, rate: $rate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RetentionTax &&
        other.id == id &&
        other.name == name &&
        other.rate == rate;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ rate.hashCode;
}
