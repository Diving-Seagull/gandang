import 'package:gandang/data/model/star_content.dart';

class StarData {
  final List<StarContent> content;

  StarData(this.content);

  Map<String, dynamic> toJson(){
    return {
      "content": content
    };
  }

  factory StarData.fromJson(Map<String, dynamic> json){
    return StarData(
        json['content']
    );
  }
}