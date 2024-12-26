import 'package:flexireader/xml/feed_enclosure.dart';
import 'package:xml/xml.dart' as xml;

// inspired by https://github.com/xqwzts/feedparser

class FeedItem {
  final String? title;
  final String? link;
  final String? description;
  final String? thumbnail;
  final FeedEnclosure? enclosure;
  final String? pubDate;
  final FeedEnclosure? mediaContent;
  final FeedEnclosure? mediaThumbnail;

  FeedItem(
      {this.title,
      this.link,
      this.description,
      this.thumbnail,
      this.enclosure,
      this.pubDate,
      this.mediaContent,
      this.mediaThumbnail});

  factory FeedItem.fromXml(xml.XmlElement node) {
    String extractText(String tagName) {
      var element = node.findElements(tagName).firstWhere(
          (element) => true,
          orElse: () => xml.XmlElement(xml.XmlName('')));
      return element.text.trim().isNotEmpty ? element.text : '';
    }

    String title = extractText('title');
    String link = extractText('link');
    String description = extractText('description');
    String thumbnail = extractText('thumbnail');
    String pubDate = extractText('pubDate');

    var tempEnclosureElement = node.findElements('enclosure').firstWhere(
        (element) => true,
        orElse: () => xml.XmlElement(xml.XmlName('')));
    FeedEnclosure enclosure = FeedEnclosure.fromXml(tempEnclosureElement);

    var mediaContentElement = node.findElements('media:content').firstWhere(
        (element) => true,
        orElse: () => xml.XmlElement(xml.XmlName('')));
    FeedEnclosure mediaContent = FeedEnclosure.fromXml(mediaContentElement);

    var mediaThumbnailElement = node.findElements('media:thumbnail').firstWhere(
        (element) => true,
        orElse: () => xml.XmlElement(xml.XmlName('')));
    FeedEnclosure mediaThumbnail = FeedEnclosure.fromXml(mediaThumbnailElement);

    return FeedItem(
        title: title,
        link: link,
        description: description,
        thumbnail: thumbnail,
        enclosure: enclosure,
        pubDate: pubDate,
        mediaContent: mediaContent,
        mediaThumbnail: mediaThumbnail);
  }

  @override
  String toString() {
    return 'title: $title, link: $link, description: $description, thumbnail: $thumbnail, enclosure: $enclosure, pubDate: $pubDate, mediaContent: $mediaContent, mediaThumbnail: $mediaThumbnail';
  }
}
