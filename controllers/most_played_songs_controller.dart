import 'package:get_storage/get_storage.dart';
import 'package:musicapp/helpers/mappers.dart';
import 'package:musicapp/hive/helpers/songs_hive_helper.dart';
import 'package:musicapp/models/songs.dart';

class MostPlayedSongsController{
  var songs = <Songs>[];

  final int currentArtistIndex = 0;
  String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
  SongsHelper  songsHelper = SongsHelper();
  Mappers mapper = Mappers();
  Future<List<Songs>> onInit() async {
    try {
      songs = await fetchSongs();
      return songs;
    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }

  _getMostPlayedSongsFromBox()async{
    await songsHelper.openBox();
    return await songsHelper.returnMostPlayedSongs();
  }

  Future<List<Songs>> fetchSongs() async{
    var songsRaw = await _getMostPlayedSongsFromBox();
    var songsList = await mapper.mapListSongsFromRaw(songsRaw);
    //  songsList.shuffle();
    return songsList;
  }
}