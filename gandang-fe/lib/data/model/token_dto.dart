class TokenDto {
  final String social_token;
  final String? firebase_token;

  TokenDto(this.social_token, [this.firebase_token]);

  Map<String, dynamic> toJson(){
    return {
      'social_token': social_token,
      'firebase_token': firebase_token
    };
  }

  factory TokenDto.fromJson(Map<String, dynamic> json){
    return TokenDto(json['social_token'], json['firebase_token']);
  }
}
