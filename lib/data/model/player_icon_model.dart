import 'package:equatable/equatable.dart';

class PlayerIconModel extends Equatable {
  final int id;
  final String? nameEn;
  final String? nameNd;
  final String? nameSn;
  final String? path;
  final String? factsEn;
  final String? factsNd;
  final String? factsSn;

  const PlayerIconModel({
    required this.id,
    this.nameEn,
    this.nameNd,
    this.nameSn,
    this.path,
    this.factsEn,
    this.factsNd,
    this.factsSn,
  });

  factory PlayerIconModel.fromMap(Map<String, dynamic> map) {
    return PlayerIconModel(
      id: map['id'],
      nameEn: map['name_en'],
      nameNd: map['name_nd'],
      nameSn: map['name_sn'],
      path: map['path'],
      factsEn: map['facts_en'],
      factsNd: map['facts_nd'],
      factsSn: map['facts_sn'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_nd': nameNd,
      'name_sn': nameSn,
      'path': path,
      'facts_en': factsEn,
      'facts_nd': factsNd,
      'facts_sn': factsSn,
    };
  }

  @override
  List<Object?> get props => [
        id,
        nameEn,
        nameNd,
        nameSn,
        path,
        factsEn,
        factsNd,
        factsSn,
      ];
}
