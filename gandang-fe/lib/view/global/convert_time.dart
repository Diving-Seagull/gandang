class ConvertTime {
  static ConvertTime instance = ConvertTime();

  String convertDecimalToTime(double decimal) {
    // 정수 부분은 시간
    int hours = decimal.floor();

    // 소수 부분을 분 단위로 변환
    double fractionalPart = decimal - hours;
    int minutes = (fractionalPart * 60).floor();

    // HH:MM:SS 형식으로 반환
    return '${hours.toString().padLeft(1, '0')}시간 '
        '${minutes.toString().padLeft(2, '0')}분';
  }
}