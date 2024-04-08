import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  var value = Get.arguments ?? "__";

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController latitudeController; // 위도를 입력받는 컨트롤러
  late TextEditingController longitudeController; // 경도를 입력받는 컨트롤러
  late TextEditingController estimateController;
  late TextEditingController dateController;
  XFile? imageFile;
  File? imgFile;
  final ImagePicker picker = ImagePicker();
  late DateTime date;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    latitudeController = TextEditingController(); // 위도 컨트롤러 초기화
    longitudeController = TextEditingController(); // 경도 컨트롤러 초기화
    dateController = TextEditingController();
    estimateController = TextEditingController();
    date = DateTime.now();

    nameController.text = value[1];
    phoneController.text = value[2];
    latitudeController.text = value[3];
    longitudeController.text = value[4];
    estimateController.text = value[6];
    date = value[7];
    print(value[5]);
  }

  getCurrentLocation() async {
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
        title: const Text('Update Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => getImageFromDevice(ImageSource.gallery),
                child: const Text('Image')),
            SizedBox(
              height: 10,
            ),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white, // 배경색
                border: Border.all(
                  color: Colors.black, // 테두리 색상
                  width: 2, // 테두리 두께
                ),
              ),
              child: Center(
                child: imageFile == null
                    ? Image.network(value[5])
                    : Image.file(File(imageFile!.path)),
              ),
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
                  SizedBox(width: 10),
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
                    estimateController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  errorSnackbar();
                } else {
                  updateAction();
                }
              },
              child: const Text('수정'),
            )
          ],
        ),
      ),
    );
  }

  updateAction() async {
    String name = nameController.text;
    String phone = phoneController.text;
    String estimate = estimateController.text;
    DateTime date1 = date;
    String lat = latitudeController.text;
    String long = longitudeController.text;
    String image = '';

    if (imageFile != null) {
      image = await preparingImage();
    } else {
      image = value[5];
    }

    FirebaseFirestore.instance.collection('musteatplace').doc(value[0]).update({
      'name': name,
      'phone': phone,
      'estimate': estimate,
      'initdate': date1,
      'lat': lat,
      'long': long,
      'image': image,
    });

    Get.back();
  }

  getImageFromDevice(imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      imageFile = null;
    } else {
      // 선택한 이미지의 경로를 XFile로 변환 => XFile의 경로를 File로 변환
      imageFile = XFile(pickedFile.path);
      imgFile = File(imageFile!.path);
      latitudeController.text = ''; // 초기화
      longitudeController.text = ''; // 초기화
    }
    setState(() {});
    getCurrentLocation();
  }

  Future<String> preparingImage() async {
    final firebaseStorage = FirebaseStorage.instance
        .ref()
        .child('images')
        .child('${nameController.text}.png');

    await firebaseStorage.delete();
    await firebaseStorage.putFile(imgFile!);

    String downloadURL = await firebaseStorage.getDownloadURL();
    return downloadURL;
  }

  errorSnackbar() {
    Get.snackbar(
      'Error',
      'Please fill in all fields',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
