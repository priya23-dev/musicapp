import 'package:musicapp/handlers/lrclib_handler.dart';
import 'package:musicapp/providers/music_controller_provider.dart';

class LyricsPageController{
  LrclibHandler handler = LrclibHandler();
  String artist = "";
  String track = "";
  Future<String> onInit() async {
    try {
      var value = await handler.getLyrics(artist,track);
      return value["plainLyrics"];
    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }


}