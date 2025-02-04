class AuthLoginModel {
  String? message;
  Tokens? tokens;

  AuthLoginModel({this.message, this.tokens});

  AuthLoginModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    tokens =
    json['tokens'] != null ? Tokens.fromJson(json['tokens']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (tokens != null) {
      data['tokens'] = tokens!.toJson();
    }
    return data;
  }
}

class Tokens {
  String? refresh;
  String? access;

  Tokens({this.refresh, this.access});

  Tokens.fromJson(Map<String, dynamic> json) {
    refresh = json['refresh'];
    access = json['access'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['refresh'] = refresh;
    data['access'] = access;
    return data;
  }
}
