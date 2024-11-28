class TokenDto {
  final String token;
  final String firebase_token;

  TokenDto(this.token, this.firebase_token);

  Map<String, dynamic> toJson(){
    return {
      'token': token,
      'firebase_token': firebase_token
    };
  }

  factory TokenDto.fromJson(Map<String, dynamic> json){
    return TokenDto(json['token'], json['firebase_token']);
  }
}
