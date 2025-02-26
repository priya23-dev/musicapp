import 'package:musicapp/helpers/mappers.dart';
import 'package:musicapp/hive/helpers/songs_hive_helper.dart';
import 'package:musicapp/models/songs.dart';

class IndividualSongController{
  SongsHelper helper = SongsHelper();
  Mappers mapper = Mappers();



  Future<Songs> onInit(String songId)async{
    await helper.openBox();
    var song = helper.returnSongById(songId);
    var mappedSong =  mapper.convertHiveSongToModelSong(song);
    return mappedSong;
  }

}