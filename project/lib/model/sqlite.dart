import 'dart:typed_data';

class Students {
  int? seq; //  null값이 올 수도 있다.
  String name;
  String phone;
  double lat;
  double lng;
  Uint8List image;
  String estimate;
  DateTime initdate;

  Students(
      {this.seq, //required = 필수
      required this.name,
      required this.phone,
      required this.lat,
      required this.lng,
      required this.image,
      required this.estimate,
      required this.initdate});

  factory Students.fromMap(Map<String, dynamic> res) {
    return Students(
      seq: res['seq'],
      name: res['name'],
      phone: res['phone'],
      lat: res['lat'] as double, // double로 형변환
      lng: res['lng'] as double, // double로 형변환
      image: Uint8List.fromList(res['image']), // Uint8List로 변환
      estimate: res['estimate'],
      initdate: DateTime.parse(res['initdate']), // DateTime으로 변환
    );
  }
}
