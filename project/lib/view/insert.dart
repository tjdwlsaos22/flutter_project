import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';

class Insert extends StatefulWidget {
  const Insert({super.key});

  @override
  State<Insert> createState() => _InsertState();
}

class _InsertState extends State<Insert> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController latitudeController; // 위도를 입력받는 컨트롤러
  late TextEditingController longitudeController; // 경도를 입력받는 컨트롤러
  late TextEditingController estimateController;
  late TextEditingController dateController;

  late String name;
  late String phone;
  late String lat;
  late String long;
  late String estimate;
  late DateTime date;

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  File? imgFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    latitudeController = TextEditingController(); // 위도 컨트롤러 초기화
    longitudeController = TextEditingController(); // 경도 컨트롤러 초기화
    dateController = TextEditingController();
    estimateController = TextEditingController();
    date = DateTime.now();
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
        title: const Text('맛집 추가'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => getImageFromGallery(ImageSource.gallery),
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
                    ? const Text('Image')
                    : Image.file(
                        File(imageFile!.path),
                        width: 200,
                        height: 200,
                      ),
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
                      child: TextFormField(
                        initialValue: '${latitudeController.text}',
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: '위도',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  SizedBox(width: 10),
                  if (latitudeController.text.isNotEmpty &&
                      longitudeController.text.isNotEmpty)
                    Expanded(
                      child: TextFormField(
                        initialValue: '${longitudeController.text}',
                        readOnly: true,
                        decoration: InputDecoration(
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

  insertAction() async {
    //image때문에 async
    String name = nameController.text;
    String phone = phoneController.text;
    String estimate = estimateController.text;
    String lat = latitudeController.text;
    String long = longitudeController.text;
    DateTime date1 = date;
    String image = await preparingImage();

    FirebaseFirestore.instance.collection('musteatplace').add({
      'name': name,
      'phone': phone,
      'lat': lat,
      'long': long,
      'image': image,
      'estimate': estimate,
      'initdate': date1
    });

    Get.back();
  }

  Future<String> preparingImage() async {
    final firebaseStorage = FirebaseStorage.instance
        .ref()
        .child('images')
        .child('${nameController.text}.png');
    await firebaseStorage.putFile(imgFile!); //업로드 될때까지 기다려라(await)
    String downloadURL = await firebaseStorage.getDownloadURL();
    return downloadURL; //파일 올리고 내리는 것은 시간이 많이 소요되기때문에 await를 사용한다.
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
