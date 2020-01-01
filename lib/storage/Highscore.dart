import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class HighScoreStorage{
  Future<String> get _localPath async{
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _file async{
    final path = await _localPath;
    return File('$path/high.score');
  }

  Future<int> get highscore async{
    try{
      final f = await _file;
      String c = await f.readAsString();
      return int.parse(c);
    }
    catch(e){
      return 0;
    }
  }

  Future<File> setHighscore(int value) async{
    final f = await _file;
    return f.writeAsString(value.toString());
  }
}