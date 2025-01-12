class DenomTopupDataEntity {
  List<DenomTopupDataListEntity> data;

  DenomTopupDataEntity({
    required this.data,
  });

  factory DenomTopupDataEntity.fromJson(Map<String, dynamic> json) => DenomTopupDataEntity(
    data: List<DenomTopupDataListEntity>.from(json["data"].map((x) => DenomTopupDataListEntity.fromJson(x))),
  );
}

class DenomTopupDataListEntity {
  String id;
  int denom;

  DenomTopupDataListEntity({
    required this.id,
    required this.denom,
  });

  factory DenomTopupDataListEntity.fromJson(Map<String, dynamic> json) => DenomTopupDataListEntity(
    id: json["id"],
    denom: json["denom"],
  );
}