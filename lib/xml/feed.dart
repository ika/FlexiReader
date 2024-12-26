import 'package:flexireader/xml/feed_image.dart';
import 'package:flexireader/xml/feed_item.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml;

// inspired by https://github.com/xqwzts/feedparser

class Feed {
  final String? title;
  final String? link;
  final String? description;
  final String? language;
  final String? pubDate;
  final FeedImage? image;
  final List<FeedItem>? items;

  Feed(
    this.title,
    this.link,
    this.description, {
    this.language,
    this.pubDate,
    this.image,
    this.items,
  });

  factory Feed.fromXml(xml.XmlElement node) {
    String extractText(String tagName) {
      try {
        return node.findElements(tagName).single.text.trim();
      } catch (e) {
        if (kDebugMode) {
          print('Error extracting $tagName: $e');
        }
        return '';
      }
    }

    String title = extractText('title');
    String link = extractText('link');
    String description = extractText('description');
    String language = extractText('language');
    String pubDate = extractText('pubDate');

    FeedImage image = FeedImage('assets/images/no_image.png');
    try {
      var imageElement = node.findElements('image').single;
      image = FeedImage.fromXml(imageElement);
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting image: $e');
      }
    }

    List<FeedItem> items = node
        .findElements('item')
        .map((itemElement) => FeedItem.fromXml(itemElement))
        .toList();

    return Feed(
      title,
      link,
      description,
      image: image,
      language: language,
      pubDate: pubDate,
      items: items,
    );
  }

  @override
  String toString() {
    return 'title: $title, link: $link, description: $description, language: $language, pubDate: $pubDate, image: $image, items: $items';
  }
}
