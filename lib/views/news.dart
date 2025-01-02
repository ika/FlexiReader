import 'dart:async';
import 'dart:math';
import 'package:flexireader/db/queries.dart';
import 'package:flexireader/models/fmodel.dart';
import 'package:flexireader/models/jmodel.dart';
import 'package:flexireader/views/feeds.dart';
import 'package:flexireader/xml/feed.dart';
import 'package:flexireader/xml/feed_parse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart';
import 'package:url_launcher/url_launcher.dart';

//import 'package:flutter_charset_detector/flutter_charset_detector.dart';

// https://stackoverflow.com/questions/62889635/rss-xml-parsing

// news.dart

String feedUrl = '';

Feed _feed = Feed('', '', ''); //.initializeFeed();

class NewsPage extends StatefulWidget {
  const NewsPage({super.key, required this.title});

  final String title;

  @override
  NewsPageState createState() => NewsPageState();
}

class NewsPageState extends State<NewsPage> {
  String loadingFeedMsg = 'Loading ...';
  String feedLoadErrorMsg = 'Error Loading feed';
  //static const String feedOpenErrorMsg = 'Error Opening feed';

  late GlobalKey<RefreshIndicatorState> _refreshKey;

  late String _title;

  @override
  initState() {
    super.initState();
    _refreshKey = GlobalKey<RefreshIndicatorState>();
    updateTitle(widget.title);
    getSharedPrefsFeedLink();
  }

  String _removeLeadingChars(String xmlString) {
    //List splitString = xmlString.split('<?xml');
    //String newString = '<?xml' + splitString[1];
    //return xmlString.substring(xmlString.indexOf('?>') + 2).trim();
    //print(str);
    return xmlString;
  }

  Future<Null> getSharedPrefsFeedLink() async {
    await SharedPreferences.getInstance().then((prefs) {
      var encodedData = prefs.getString('jmodelEncodedData');

      if (encodedData != null) {
        final List<JModel> decodedData = JModel.decode(encodedData);

        feedUrl = decodedData.first.link as String;

        if (_validateURL(feedUrl)) {
          updateTitle(loadingFeedMsg);
          load();
        } else {
          throw ('$feedUrl is not valid in getSharedPrefsFeedLink');
        }
      } else {
        // got to feeds
        navigateToFeedsPage();
      }
    });
  }

  updateTitle(title) {
    setState(() {
      _title = title;
    });
  }

  updateFeed(feed) {
    setState(() {
      _feed = feed;
    });
  }

  load() async {
    updateTitle(loadingFeedMsg);

    loadFeed().then((result) {
      if (result.toString().isEmpty) {
        updateTitle(feedLoadErrorMsg);
      } else {
        updateFeed(result);
        updateTitle(_feed.title);
      }
    });
  }

  // RSS feed
  Future<Feed?> loadFeed() async {
    final client = http.Client();
    final response = await client.get(Uri.parse(feedUrl));
    if (response.statusCode == 200) {
      var channel = parseFeed(_removeLeadingChars(response.body));
      client.close();
      return channel;
    } else {
      throw ('Request failed with status: ${response.statusCode}');
    }
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString.trim();
  }

  Future onReturnFromFeeds(dynamic value) async {
    //debugPrint("RETURN FROM FEEDS VALUE $value");

    if (value == null) {
      DBQueries dbQueries = DBQueries();

      int max = await dbQueries.getFeedCount();
      int randomNumber = Random().nextInt(max) + 1;
      //debugPrint(" RANDOM NUMBER $randomNumber");

      List<FModel> randomModelById = await dbQueries.getFeedItemById(randomNumber);
      //debugPrint("RETURN RANDOM BY ID FEEDS VALUE ${randomModelById.first.title}");

      FModel fModel = FModel(id: 0, title: '', link: '', feedid: 0, time: 0);

      if (randomModelById.first.link!.isNotEmpty) {
        fModel = FModel(
            id: randomModelById.first.id,
            title: randomModelById.first.title,
            link: randomModelById.first.link,
            feedid: randomModelById.first.feedid,
            time: randomModelById.first.time);
      } else {
        fModel = FModel(
            id: 0,
            title: "IOL South Africa",
            link: "http://rss.iol.io/iol/news/south-africa",
            feedid: 484946073,
            time: 0);
      }

      feedUrl = fModel.link.toString();

    } else {
      List<JModel> decodedData = JModel.decode(value);
      feedUrl = decodedData.first.link.toString();
    }

    if (_validateURL(feedUrl)) {
      updateTitle(loadingFeedMsg);
      load();
    } else {
      throw ('$feedUrl is not valid in onReturnFromFeeds');
    }
  }

  navigateToFeedsPage() async {
    Route route =
        CupertinoPageRoute(builder: (context) => FeedsPage(title: 'RSS Feeds'));
    Navigator.push(context, route).then(onReturnFromFeeds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          _title,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.list,
              color: Colors.white,
            ),
            onPressed: () {
              navigateToFeedsPage();
            },
          )
        ],
        elevation: 0.0,
      ),
      // ignore: unnecessary_null_comparison
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: () => load(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                ListView.builder(
                  itemCount: _feed.items != null ? _feed.items!.length : 0,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final item = _feed.items![index];
                    return ItemTile(
                        title: item.title as String,
                        imageUrl: getImageUrl(item),
                        desc: _parseHtmlString(item.description as String),
                        webUrl: item.link as String, // web page url
                        pDate: item.pubDate as String,
                        fTitle: _feed.title as String);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ItemTile extends StatelessWidget {
  final String imageUrl, title, desc, pDate, fTitle;
  final String webUrl;

  const ItemTile(
      {super.key,
      required this.imageUrl, // picture url
      required this.title,
      required this.desc,
      required this.webUrl, // web page url
      required this.pDate,
      required this.fTitle}); // content

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _launchInBrowser(webUrl);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        child: Card(
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(15.0),
          // ),
          elevation: 10,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                showImage(context, imageUrl),
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(top: 8),
                  child: Text(
                    utf8convert(title), // Title
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(top: 4),
                  child: Text(
                    utf8convert(desc), // Description
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  margin: const EdgeInsets.only(top: 4),
                  child: Text(
                    pDate.trim(), // Pub date
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _launchInBrowser(String url) async {
  if (url.isNotEmpty) {
    Uri parsedUrl = Uri.parse(url);
    if (!await launchUrl(parsedUrl)) {
      throw 'Could not launch $parsedUrl';
    }
  } else {
    throw 'URL $url is empty';
  }
}

String utf8convert(String stringtext) {
  // Uint8List bytes = stringtext as Uint8List; // bytes with unknown encoding
  // DecodingResult result = CharsetDetector.autoDecode(bytes) as DecodingResult;
  // print("CHARACTER SET $result.charset"); // => e.g. 'SHIFT_JIS'

  return stringtext.trim();
  // StringBuffer sb = new StringBuffer();
  // sb.clear();
  // sb.write(stringtext);
  // return utf8.decode(sb.asUint8List(), allowMalformed: true);
}

// Uint8List bytes = getBytes(); // bytes with unknown encoding
// DecodingResult result = CharsetDetector.autoDecode(bytes);
// print(result.charset); // => e.g. 'SHIFT_JIS'

// final bytes = await rootBundle.load(asset);
//   return CharsetDetector.autoDecode(bytes.buffer.asUint8List());
//return CharsetDetector.autoDecode(bytes.buffer.asUint8List());

bool _validateURL(String feedUrl) {
  return Uri.parse(feedUrl).isAbsolute;
}

showImage(BuildContext context, String imageUrl) {
  //debugPrint("IMAGEURL $imageUrl");
  if (_validateURL(imageUrl)) {
    //final String placeholderImg = 'assets/images/no_image.png';
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error)),
    );
  } else {
    return Container();
  }
}

String getImageUrl(item) {
  // if (item.thumbnail.toString().isNotEmpty) {
  //   return item.thumbnail;
  // }

  // if (item.mediaThumbnail != null) {
  //   if (item.mediaThumbnail.url != null) {
  //     return item.mediaThumbnail.url;
  //   }
  // }

  if (item.enclosure != null) {
    if (item.enclosure.url != null) {
      return item.enclosure.url;
    }
  }

  if (item.description != null) {
    var document = parse(item.description);
    var img = document.querySelector("img");
    if (img != null) {
      return img.attributes["src"] as String;
    }
  }

  if (item.mediaContent != null) {
    if (item.mediaContent.url != null) {
      return item.mediaContent.url;
    }
  }

  // last resort - use feed image
  // if (_feed.image != null) {
  //   if (_feed.image?.url != null) {
  //     return _feed.image?.url as String;
  //   }
  // }

  return ''; //'https://via.placeholder.com/300x150';
}
