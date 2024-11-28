class JwtData {
  final String token;

  JwtData(this.token);

  Map<String, dynamic> toJson(){
    return {
      'token': token,
    };
  }

  factory JwtData.fromJson(Map<String, dynamic> json){
    return JwtData(json['token']);
  }
}