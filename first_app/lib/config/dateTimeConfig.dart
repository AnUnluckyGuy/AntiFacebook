
class DateTimeConfig {
  String showDateTimeDiff(String dt){
    DateTime dateNow = DateTime.now();
    DateTime date = DateTime.parse(dt);
    Duration diff = dateNow.difference(date);
    if ((diff.inHours / 24).floor() >= 365){
      return ((diff.inHours / 24) / 365).floor().toString() + ' năm';
    }
    if ((diff.inHours / 24).floor() >= 30){
      return ((diff.inHours / 24) / 30).floor().toString() + ' tháng';
    }
    if ((diff.inHours / 24).floor() >= 7){
      return ((diff.inHours / 24) / 7).floor().toString() + ' tuần';
    }
    if ((diff.inHours / 24).floor() > 0){
      return (diff.inHours / 24).floor().toString() + ' ngày';
    }
    if (diff.inHours.floor() > 0){
      return diff.inHours.floor().toString() + ' giờ';
    }
    if (diff.inMinutes.floor() > 0){
      return diff.inMinutes.floor().toString() + ' phút';
    }
    if (diff.inSeconds.floor() >= 30){
      return diff.inSeconds.floor().toString() + ' giây';
    }
    return 'Vừa xong';
  }

  int timeToInt(String dt){
    DateTime dateNow = DateTime.now();
    DateTime date = DateTime.parse(dt);
    Duration diff = dateNow.difference(date);

    return diff.inMinutes;
  }
}