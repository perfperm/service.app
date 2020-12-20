class AccountInfo {
  final String accessToken;
  final String personExternalId;
  final String cityExternalId;

  AccountInfo({this.accessToken, this.personExternalId, this.cityExternalId});

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      accessToken: json['access_token'],
      personExternalId: json['person_external_id'],
      cityExternalId: json['city_external_id'],
    );
  }
}