import 'package:musicapp/helpers/mappers.dart';
import 'package:musicapp/hive/helpers/songs_hive_helper.dart';
import 'package:musicapp/models/songs.dart';
import 'package:musicapp/providers/music_controller_provider.dart';

class MostPlayedSongsArtistController{

  var songs = <Songs>[];
  Mappers mapper = Mappers();
  SongsHelper  songsHelper = SongsHelper();
  String? artistName;
  Future<List<Songs>> onInit() async {
    try {
      songs = await fetchSongs();
      return songs;
    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }

  mapSongsToStreamModels(List<Songs> songs){
    return mapper.returnStreamModelsList(songs);
  }

  _getMostPlayedSongsFromBox()async{
    await songsHelper.openBox();
    return await songsHelper.returnMostPlayedSongsArtist(artistName ?? "");
  }

  Future<List<Songs>> fetchSongs() async{
    var songsRaw = await _getMostPlayedSongsFromBox();
    var songsList = await mapper.mapListSongsFromRaw(songsRaw);
    //  songsList.shuffle();
    return songsList;
  }

}