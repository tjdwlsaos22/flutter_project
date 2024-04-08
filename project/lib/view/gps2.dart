import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;

class GPSPage1 extends StatefulWidget {
  const GPSPage1({Key? key}) : super(key: key);
  @override
  State<GPSPage1> createState() => _GPSPage1State();
}

class _GPSPage1State extends State<GPSPage1> {
  var value = Get.arguments ?? "__";
  late TextEditingController nameController;
  late TextEditingController latitudeController; // 위도를 입력받는 컨트롤러
  late TextEditingController longitudeController; // 경도를 입력받는 컨트롤러
  late MapController mapController;
  late Position currentPosition;
  bool canRun = false; //

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    latitudeController = TextEditingController(); // 위도 컨트롤러 초기화
    longitudeController = TextEditingController(); // 경도 컨트롤러 초기화
    mapController = MapController();

    nameController.text = value[1];

    latitudeController.text = value[4];
    longitudeController.text = value[5];

    // 위치 정보 가져오기
    checkLocationPermission();
  }

  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentPosition = position;
      canRun = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GPS & Map',
          style: TextStyle(color: Colors.black),
        ),
        toolbarHeight: 100,
      ),
      body: Center(
        child: Container(
          width: 400, // 지도 컨테이너의 폭 조정
          height: 600, // 지도 컨테이너의 높이 조정
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // 모서리를 둥글게 조정
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)
            ], // 그림자 효과 추가
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20), // 모서리를 둥글게 조정
            child: canRun
                ? FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: latlng.LatLng(
                        double.parse(latitudeController.text),
                        double.parse(longitudeController.text),
                      ),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: latlng.LatLng(
                              double.parse(latitudeController.text),
                              double.parse(longitudeController.text),
                            ),
                            // 아이콘 대신 빈 컨테이너를 사용하여 child 매개변수를 설정합니다.
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                  child: Text(
                                    nameController.text,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.pin_drop,
                                    size: 50, color: Colors.red)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
