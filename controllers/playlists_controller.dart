import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:musicapp/handlers/ihandler_dart.dart';
import 'package:musicapp/models/playlists.dart';

class PlaylistsController{

  var playlistsList = <Playlists>[];
  String serverType = GetStorage().read('ServerType') ?? "Jellyfin";


  late IHandler handler;
  PlaylistsController(){

    handler = GetIt.instance<IHandler>(instanceName: serverType);
  }


  clearList(){
    playlistsList.clear();
  }

  Future<List<Playlists>> onInit() async {
    try {
      // await artistHelper.openBox();
      clearList();

      playlistsList = await handler.returnPlaylists();
      return playlistsList;
    } catch (error) {
      // Handle errors if needed
      rethrow;
    }
  }

  Future<List<Playlists>> getPlaylists()async{
    try {
      // await artistHelper.openBox();
      clearList();

      playlistsList = await handler.returnPlaylists();
      return playlistsList;
    } catch (error) {
      // Handle errors if needed
      rethrow;
    }
  }

}