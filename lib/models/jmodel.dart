import 'dart:convert';

// convert to json for saving in sharedPrefs

class JModel {
  int? id;
  String? title;
  String? link;
  int? feedid;
  int? time;

  JModel({this.id, this.title, this.link, this.feedid, this.time});

  factory JModel.fromJson(Map<String, dynamic> jsonData) {
    return JModel(
        id: jsonData['id'],
        title: jsonData['title'],
        link: jsonData['link'],
        feedid: jsonData['feedid'],
        time: jsonData['time']);
  }

  static Map<String, dynamic> toMap(JModel model) => {
        'id': model.id,
        'title': model.title,
        'link': model.link,
        'feedid': model.feedid,
        'time': model.time
      };

  static String encode(List<JModel> jmodel) => json.encode(
        jmodel
            .map<Map<String, dynamic>>((jmodel) => JModel.toMap(jmodel))
            .toList(),
      );

  static List<JModel> decode(String jmodel) =>
      newMethod(jmodel)
          .map<JModel>((item) => JModel.fromJson(item))
          .toList();

  static List newMethod(String jmodel) => (json.decode(jmodel) as List<dynamic>);
}
