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

    // title
    try {
      tempTitle = node.findElements('title').single.text;
    String title =(tempTitle.trim().isNotEmpty)? tempTitle : '';
    } catch (e) {
      throw ("title exception $e");
    }

    String link = '';
    try {
      link = node.findElements('link').single.text;
    } catch (e) {
      throw ("link exception $e");
    }

    String description = '';
    try {
      description = node.findElements('description').single.text;
    } catch (e) {
      throw ("description exception $e");
    }

    String thumbnail = '';
    try {
      thumbnail = node.findElements('thumbnail').single.text;
    } catch (e) {
      throw ("thumbnail exception $e");
    }

    String pubDate = '';
    try {
      pubDate = node.findElements('pubDate').single.text;
    } catch (e) {
      throw ("pubDate exception $e");
    }

    // item enclosure
    xml.XmlElement? enclosureElement;
    try {
      enclosureElement = node.findElements('enclosure').single;
    } catch (e) {
      throw ("enclosureElement exception $e");
    }

    FeedEnclosure enclosure = FeedEnclosure('', '', '');
    try {
      enclosure = FeedEnclosure.fromXml(enclosureElement);
    } catch (e) {
      throw ("enclosure exception $e");
    }

    // item media:content
    xml.XmlElement? mediaContentElement;
    try {
      mediaContentElement = node.findElements('media:content').first;
    } catch (e) {
      throw ("mediaContentElement exception $e");
    }

    FeedEnclosure mediaContent = FeedEnclosure('', '', '');
    try {
      mediaContent = FeedEnclosure.fromXml(mediaContentElement);
    } catch (e) {
      throw ("mediaContent exception $e");
    }

    // item media:thumbnail
    xml.XmlElement? mediaThumbnailElement;
    try {
      mediaThumbnailElement = node.findElements('media:thumbnail').first;
    } catch (e) {
      throw ('mediaThumbnailElement exception: $e');
    }

    FeedEnclosure mediaThumbnail = FeedEnclosure('', '', '');
    try {
      mediaThumbnail = FeedEnclosure.fromXml(mediaThumbnailElement);
    } catch (e) {
      throw ('mediaThumbnail exception: $e');
    }

    return FeedItem(
        title: title ,
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
    return '''
      title: $title
      link: $link
      description: $description
      thumbnail: $thumbnail
      enclosure: $enclosure
      pubDate: $pubDate
      mediaContent: $mediaContent
      mediaThumbnail: $mediaThumbnail
      ''';
  }
}
