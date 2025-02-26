import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:musicapp/handlers/ihandler_dart.dart';
import 'package:musicapp/helpers/mappers.dart';
import 'package:musicapp/hive/helpers/songs_hive_helper.dart';
import 'package:musicapp/models/playback_history.dart';

class PlaybackHistoryDayListController{
  String serverType = GetStorage().read('ServerType') ?? "Jellyfin";
  String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
  late IHandler handler;
  Mappers mapper = Mappers();
  SongsHelper songsHelper = SongsHelper();
  DateTime? day;
  Future<List<PlaybackHistory>> onInit()async{
    handler = GetIt.instance<IHandler>(instanceName: serverType);
    await songsHelper.openBox();
    if(day == null)return [];

    var datta = await fetchData(day ?? DateTime.now());
    return datta;
  }

  fetchData(DateTime day)async{
    var data = await  handler.getPlaybackForDay(day);
    var mappedData = await mapper.convertRawToPlaybackHistory(data);
    return mappedData;
  }

}