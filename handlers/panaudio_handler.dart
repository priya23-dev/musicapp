import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:musicapp/handlers/ihandler_dart.dart';
import 'package:musicapp/handlers/logger_handler.dart';
import 'package:musicapp/helpers/conversions.dart';
import 'package:musicapp/helpers/mappers.dart';
import 'package:musicapp/hive/classes/artists.dart';
import 'package:musicapp/models/log.dart';
import 'package:musicapp/models/playlists.dart';
import 'package:musicapp/models/songs.dart';
import 'package:musicapp/models/album.dart';
import 'package:musicapp/repos/jellyfin_repo.dart';

class JellyfinHandler implements IHandler {
  JellyfinRepo jellyfinRepo = GetIt.instance<JellyfinRepo>();
  Conversions conversions = Conversions();
  Mappers mapper = Mappers();
  LogHandler logger = LogHandler();

  @override
  updateFavouriteStatus(String itemId, bool current) async {
    await jellyfinRepo.updateFavouriteStatus(itemId, !current);
  }

  @override
  returnArtistBio(String artistName) async {
    return await jellyfinRepo.getArtistBio(artistName);
  }

  @override
  Future<List<Album>> returnLatestAlbums() async {
    var albumsRaw = await jellyfinRepo.getLatestAlbums();
    return await mapper.mapAlbumFromRaw(albumsRaw);
  }

  @override
  Future<List<Artists>> fetchArtists() async {
    var artistRaw = await jellyfinRepo.getArtistData();
    List<Artists> artistList = [];
    for (var artist in artistRaw["Items"]) {
      artistList.add(Artists(
        id: artist["Id"],
        name: artist["Name"],
        favourite: artist["UserData"]["IsFavorite"],
        picture: artist["Id"],
        playCount: 0,
      ));
    }
    return artistList;
  }

  @override
  returnSongs() async {
    return await jellyfinRepo.getSongsDataRaw();
  }

  @override
  Future<List<Playlists>> returnPlaylists() async {
    var playlistsRaw = await jellyfinRepo.getPlaylists();
    List<Playlists> playlistList = [];
    for (var playlistRaw in playlistsRaw["Items"]) {
      playlistList.add(Playlists(
        id: playlistRaw["Id"],
        name: playlistRaw["Name"],
        runtime: conversions.returnTicksToTimestampString(
          playlistRaw["RunTimeTicks"] ?? 0,
        ),
      ));
    }
    return playlistList;
  }

  @override
  uploadArt(String albumId, File image) async {
    try {
      await jellyfinRepo.uploadAlbumArt(albumId, image);
    } catch (e) {
      await logger.addToLog(LogModel(
        logType: "Error",
        logMessage: "Error uploading album art: $e",
        logDateTime: DateTime.now(),
      ));
    }
  }

  @override
  updateFavouriteAlbum(String albumId, bool current) async {
    await jellyfinRepo.updateFavouriteStatus(albumId, !current);
  }

  @override
  updateFavouriteArtist(String artistId, bool current) async {
    await jellyfinRepo.updateFavouriteStatus(artistId, !current);
  }

  @override
  Future<List<Songs>> returnSongsFromPlaylist(String playlistId) async {
    var songsRaw = await jellyfinRepo.getPlaylistSongs(playlistId);
    return await mapper.mapSongFromRaw(songsRaw["Items"]);
  }

  @override
  addSongToPlaylist(String songId, String playlistId) async {
    await jellyfinRepo.addSongToPlaylist(songId, playlistId);
  }

  @override
  deleteSongFromPlaylist(String songId, String playlistId) async {
    await jellyfinRepo.deleteSongFromPlaylist(songId, playlistId);
  }

  @override
  startPlaybackReporting(String songId, String userId) async {
    try {
      await jellyfinRepo.startPlaybackReporting(songId, userId);
    } catch (e) {
      await logger.addToLog(LogModel(
        logType: "Error",
        logMessage: "Error starting playback: $songId",
        logDateTime: DateTime.now(),
      ));
    }
  }

  @override
  updatePlaybackProgress(String songId, String userId, bool paused, int ticks) async {
    try {
      await jellyfinRepo.updatePlaybackProgress(songId, userId, paused, ticks);
    } catch (e) {
      await logger.addToLog(LogModel(
        logType: "Error",
        logMessage: "Error updating playback progress: $e",
        logDateTime: DateTime.now(),
      ));
    }
  }

  @override
  stopPlaybackReporting(String songId, String userId) async {
    try {
      await jellyfinRepo.stopPlaybackReporting(songId, userId);
    } catch (e) {
      await logger.addToLog(LogModel(
        logType: "Error",
        logMessage: "Error stopping playback reporting: $e",
        logDateTime: DateTime.now(),
      ));
    }
  }

  @override
  tryGetArt(String artist, String album) async {
    try {
      return await jellyfinRepo.getArt(artist, album);
    } catch (e) {
      await logger.addToLog(LogModel(
        logType: "Error",
        logMessage: "Error fetching art: $e",
        logDateTime: DateTime.now(),
      ));
      return null;
    }
  }

  @override
  getPlaybackByDays(DateTime inOldDate, DateTime inCurDate) async {
    try {
      return await jellyfinRepo.getPlaybackStatsByDays(inOldDate, inCurDate);
    } catch (e) {
      await logger.addToLog(LogModel(
        logType: "Error",
        logMessage: "Error fetching playback by days: $e",
        logDateTime: DateTime.now(),
      ));
      return null;
    }
  }

  @override
  getPlaybackByArtists(DateTime inOldDate, DateTime inCurDate) async {
    try {
      return await jellyfinRepo.getPlaybackStatsByArtists(inOldDate, inCurDate);
    } catch (e) {
      await logger.addToLog(LogModel(
        logType: "Error",
        logMessage: "Error fetching playback by artists: $e",
        logDateTime: DateTime.now(),
      ));
      return null;
    }
  }

  @override
  getPlaybackForDay(DateTime day) async {
    try {
      return await jellyfinRepo.getPlaybackForDay(day);
    } catch (e) {
      await logger.addToLog(LogModel(
        logType: "Error",
        logMessage: "Error fetching playback for day: $e",
        logDateTime: DateTime.now(),
      ));
      return null;
    }
  }

  Future<void> refreshData() async {
    try {
      await jellyfinRepo.refreshAllData();
      await logger.addToLog(LogModel(
        logType: "Info",
        logMessage: "Data refresh triggered successfully",
        logDateTime: DateTime.now(),
      ));
    } catch (e) {
      await logger.addToLog(LogModel(
        logType: "Error",
        logMessage: "Error refreshing data: $e",
        logDateTime: DateTime.now(),
      ));
    }
  }
}
