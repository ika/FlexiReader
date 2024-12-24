class FModel {
  int? id;
  String? title;
  String? link;
  int? feedid;
  int? time;

  FModel({this.id, this.title, this.link, this.feedid, this.time});

  FModel.map(dynamic obj) {
    id = obj['id'];
    title = obj['title'];
    link = obj['link'];
    feedid = obj['feedid'];
    time = obj['time'];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['link'] = link;
    map['feedid'] = feedid;
    map['time'] = time;

    return map;
  }

  FModel.fromMap(dynamic map) {
    id = map['id'];
    title = map['title'];
    link = map['link'];
    feedid = map['feedid'];
    time = map['time'];
  }
}
