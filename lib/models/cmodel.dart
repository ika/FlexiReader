// Feed Cache

class CModel {
  int? _id;
  String? _title;
  String? _link;
  String? _desc;
  String? _imageurl;
  int? _pdate;
  int? _feedid;
  int? _time;

  CModel(this._title, this._link, this._desc, this._imageurl, this._pdate,
      this._feedid, this._time);

  CModel.map(dynamic obj) {
    _id = obj['id'];
    _title = obj['title'];
    _link = obj['link'];
    _desc = obj['desc'];
    _imageurl = obj['imageurl'];
    _pdate = obj['pdate'];
    _feedid = obj['feedid'];
    _time = obj['time'];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['link'] = _link;
    map['desc'] = _desc;
    map['imageurl'] = _imageurl;
    map['pdate'] = _pdate;
    map['feedid'] = _feedid;
    map['time'] = _time;

    return map;
  }

  CModel.fromMap(dynamic map) {
    _id = map['id'];
    _title = map['title'];
    _link = map['link'];
    _desc = map['desc'];
    _imageurl = map['imageurl'];
    _pdate = map['pdate'];
    _feedid = map['feedid'];
    _time = map['time'];
  }
}
