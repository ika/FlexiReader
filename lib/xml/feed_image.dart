import 'package:xml/xml.dart' as xml;

// inspired by https://github.com/xqwzts/feedparser

class FeedImage {
  final String? url;
  final String? width;
  final String? height;

  FeedImage(this.url, {this.width, this.height});

  factory FeedImage.fromXml(xml.XmlElement node) {
    String? url = node.getAttribute('url')?.isNotEmpty == true ? node.getAttribute('url') : '';
    String? width = node.getAttribute('width')?.isNotEmpty == true ? node.getAttribute('width') : '';
    String? height = node.getAttribute('height')?.isNotEmpty == true ? node.getAttribute('height') : '';

    return FeedImage(url, width: width, height: height);
  }

  @override
  String toString() {
    return 'url: $url, width: $width, height: $height';
  }
}

