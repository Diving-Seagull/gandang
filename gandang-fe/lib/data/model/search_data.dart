import 'package:gandang/data/model/search_content.dart';

class SearchData {
  final List<SearchContent> content;

  SearchData(this.content);

  Map<String, dynamic> toJson(){
    return {
      "content": content
    };
  }

  factory SearchData.fromJson(Map<String, dynamic> json){
    return SearchData(
        json['content']
    );
  }
}