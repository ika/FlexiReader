import 'package:xml/xml.dart' as xml;

// inspired by https://github.com/xqwzts/feedparser

class FeedEnclosure {
  // url of media file
  final String? url;

  /// Size in bytes
  final String? length;

  /// MIME type
  final String? type;

  FeedEnclosure(this.url, this.length, this.type);

  factory FeedEnclosure.fromXml(xml.XmlElement node) {
    String? url = node.getAttribute('url')?.isNotEmpty == true ? node.getAttribute('url') : '';
    String? length = node.getAttribute('length')?.isNotEmpty == true ? node.getAttribute('length') : '';
    String? type = node.getAttribute('type')?.isNotEmpty == true ? node.getAttribute('type') : '';

    return FeedEnclosure(url, length, type);
  }

  @override
  String toString() {
    return 'url: $url, length: $length, type: $type';
  }
}
