import 'dart:async';
import "dart:collection";
import 'dart:convert';

import 'package:http/http.dart' as http;

class QualityLinks {
  String videoId;

  QualityLinks(this.videoId);

  getQualitiesSync() {
    return getQualitiesAsync();
  }

  Future<SplayTreeMap> getQualitiesAsync() async {
    try {
      var response = await http.get('https://player.vimeo.com/video/' + videoId + '/config');
      var jsonData = jsonDecode(response.body)['request']['files']['progressive'];
      SplayTreeMap videoList =
          SplayTreeMap.fromIterable(jsonData, key: (item) => "${item['quality']} ${item['fps']}", value: (item) => item['url']);
      return videoList;
    } catch (error) {
      print('=====> REQUEST ERROR: $error');
      return null;
    }
  }
}
