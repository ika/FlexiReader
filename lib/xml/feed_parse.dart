import 'package:flexireader/xml/feed.dart';
import 'package:xml/xml.dart' as xml;

// inspired by https://github.com/xqwzts/feedparser

Feed? parseFeed(String feedString) {
  Feed feed = Feed('', '', '');

  if (feedString.isNotEmpty) {
    xml.XmlDocument document = xml.XmlDocument.parse(feedString);
    xml.XmlElement channelElement =
        document.rootElement.findElements('channel').single;
    feed = Feed.fromXml(channelElement);
  }
  return feed;
}
