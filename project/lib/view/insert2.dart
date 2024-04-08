import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/model/sqlite.dart';
import 'package:project/vm/database_handler.dart';

class InsertStudents extends StatefulWidget {
  const InsertStudents({super.key});

  @override
  State<InsertStudents> createState() => _InsertStudentsState();
}

class _InsertStudentsState extends State<InsertStudents> {
  late DatabaseHandler handler;
  late String name;
  late String phone;
  late double lat;
  late double long;
  late String estimate;
  late DateTime date;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController latitudeController; // 위도를 입력받는 컨트롤러
  late TextEditingController longitudeController; // 경도를 입력받는 컨트롤러
  late TextEditingController estimateController;
  late TextEditingController dateController;

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  File? imgFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    handler = DatabaseHandler();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    latitudeController = TextEditingController(); // 위도 컨트롤러 초기화
    longitudeController = TextEditingController(); // 경도 컨트롤러 초기화
    dateController = TextEditingController();
    estimateController = TextEditingController();
    date = DateTime.now();

    name = '';
    phone = '';
    lat = 0.0;
    long = 0.0;
  }

  void getCurrentLocation() async {
    // 위치 권한을 확인합니다.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 위치 권한이 없는 경우 요청합니다.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 위치 권한이 거부된 경우 처리할 수 있습니다.
        return;
      }
    }

    // 위치 서비스가 활성화되어 있는지 확인합니다.
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      // 위치 서비스가 비활성화된 경우 처리할 수 있습니다.
      return;
    }

    // 사용자의 현재 위치를 가져옵니다.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // 현재 위치의 위도와 경도를 텍스트 필드에 설정합니다.
    setState(() {
      latitudeController.text = position.latitude.toString();
      longitudeController.text = position.longitude.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insert for SQLite'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () => getImageFromGallery(ImageSource.gallery),
                child: const Text('Image')),
            const SizedBox(
              height: 10,
            ),
            imageFile == null
                ? const Text('Image')
                : Image.file(
                    File(imageFile!.path),
                    width: 200,
                    height: 200,
                  ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (latitudeController.text.isNotEmpty &&
                      longitudeController.text.isNotEmpty)
                    Expanded(
                      child: TextField(
                        controller: latitudeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: '위도',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (latitudeController.text.isNotEmpty &&
                      longitudeController.text.isNotEmpty)
                    Expanded(
                      child: TextField(
                        controller: longitudeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: '경도',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: '이름', enabledBorder: OutlineInputBorder()),
                keyboardType: TextInputType.text,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
              child: TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                    labelText: '전화번호',
                    enabledBorder: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0)),
                keyboardType: TextInputType.text,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
              child: TextFormField(
                controller: estimateController,
                decoration: const InputDecoration(
                  labelText: '평가',
                  enabledBorder: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
                maxLines: null,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    phoneController.text.isEmpty ||
                    estimateController.text.isEmpty ||
                    longitudeController.text.isEmpty) {
                  errorSnackbar();
                } else {
                  insertAction();
                }
              },
              child: const Text('입력'),
            )
          ],
        ),
      ),
    );
  }

  insertAction() async {
    lat = double.parse(latitudeController.text);
    long = double.parse(longitudeController.text);
    name = nameController.text.toString();
    phone = phoneController.text.toString();
    estimate = estimateController.text.toString();

    await getImageFromGallery(ImageSource);

    File imageFile1 = File(imageFile!.path);
    Uint8List getImage = await imageFile1.readAsBytes();

    var student = Students(
        name: name,
        phone: phone,
        lat: lat,
        lng: long,
        image: getImage,
        estimate: estimate,
        initdate: date);
    await handler.insertStudents(student);
    _ShowDialog();
  }

  _ShowDialog() {
    Get.defaultDialog(
        title: '입력 결과',
        middleText: '입력이 완료 되었습니다.',
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        barrierDismissible: false,
        actions: [
          TextButton(
              onPressed: () {
                Get.back(); //Dialog종료
                Get.back(); //화면 종료
              },
              child: const Text('OK'))
        ]);
  }

  getImageFromGallery(ImageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource);
    if (pickedFile != null) {
      // 이미지를 선택한 경우에만 실행
      imageFile = XFile(pickedFile.path);
      imgFile = File(imageFile!.path);
      setState(() {
        latitudeController.text = ''; // 초기화
        longitudeController.text = ''; // 초기화
      });
      getCurrentLocation(); // 이미지를 선택한 후에 위치 정보 가져오기
    }
  }

  errorSnackbar() {
    Get.snackbar(
      'Error',
      'Please fill in all fields and select an image',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
