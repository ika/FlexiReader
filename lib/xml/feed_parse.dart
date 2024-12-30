import 'package:flexireader/xml/feed.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml;

// inspired by https://github.com/xqwzts/feedparser

// Feed? parseFeed(String feedString) {
//   Feed feed = Feed('', '', '');

//   if (feedString.isNotEmpty) {
//     xml.XmlDocument document = xml.XmlDocument.parse(feedString);
//     xml.XmlElement channelElement =
//         document.rootElement.findElements('channel').single;
//     feed = Feed.fromXml(channelElement);
//   }
//   return feed;
// }

Feed? parseFeed(String feedString) {
  Feed feed = Feed('', '', '');

  if (feedString.isEmpty) return feed;


  //debugPrint("FEED STRING $feedString");

  xml.XmlDocument document = xml.XmlDocument.parse(feedString);
  xml.XmlElement channelElement = document.rootElement
      .findElements('channel')
      .firstWhere((element) => true,
          orElse: () => xml.XmlElement(xml.XmlName('')));

  if (channelElement.text.trim() != '') {
    return Feed.fromXml(channelElement);
  }

  return feed;
}
