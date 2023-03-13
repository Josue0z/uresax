import 'dart:convert';

import 'package:uresaxapp/apis/connection.dart';

class Retention {
  int? id;
  String? name;
  int? rate;
  Retention({
    this.id,
    this.name,
    this.rate,
  });

  static Future<List<Retention>> all() async {
    try {
      var result = await connection
          .mappedResultsQuery('''SELECT * FROM public."Retention"''');

      return result.map((e) => Retention.fromMap(e['Retention']!)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Retention copyWith({
    int? id,
    String? name,
    int? rate,
  }) {
    return Retention(
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

  factory Retention.fromMap(Map<String, dynamic> map) {
    return Retention(
      id: map['id']?.toInt(),
      name: map['name'],
      rate: int.parse(map['rate']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Retention.fromJson(String source) =>
      Retention.fromMap(json.decode(source));

  @override
  String toString() => 'Retention(id: $id, name: $name, rate: $rate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Retention &&
        other.id == id &&
        other.name == name &&
        other.rate == rate;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ rate.hashCode;
}
