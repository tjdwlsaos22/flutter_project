import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project/view/gps3.dart';
import 'package:project/view/home.dart';
import 'package:project/view/home2.dart';
import 'package:project/view/insert.dart';
import 'package:project/view/insert2.dart';
import 'package:project/view/insert3.dart';
import 'package:project/view/update3.dart';

/* 
    Description : 우리의 맛집 리스트
                  appBar : actions -> 리스트 추가
                  body : onTap -> 지도보기
                         slidable -> 수정 및 삭제
                         onClick -> ActionSheet을 통한 전화
    Author 		: Lcy
    Date 			: 2024.04.06
*/

class OurRestaurant extends StatefulWidget {
  const OurRestaurant({super.key});

  @override
  State<OurRestaurant> createState() => _OurRestaurantState();
}

class _OurRestaurantState extends State<OurRestaurant> {
  late List eatlist;

  @override
  void initState() {
    eatlist = [];
    super.initState();
    getJSPData();
  }

  getJSPData() async {
    var url = Uri.parse(
        'http://localhost:8080/Flutter/MustEatPlace/select_musteat_list.jsp');
    var response = await http.readBytes(url);
    List result = json.decode(utf8.decode(response))['eatlist'];
    eatlist.addAll(result);
    setState(() {});
  }

  reloadData() {
    eatlist.clear();
    getJSPData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite for Students'),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const InsertStudent2());
            },
            icon: const Icon(Icons.add_outlined),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: eatlist.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
            child: Slidable(
              startActionPane:
                  ActionPane(motion: const DrawerMotion(), children: [
                SlidableAction(
                  onPressed: (context) {
                    // 수정 Action
                    Get.to(const Update3(), arguments: eatlist[index])!
                        .then((value) => reloadData());
                  },
                  icon: Icons.edit,
                  label: '수정하기',
                  backgroundColor: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
              ]),
              endActionPane:
                  ActionPane(motion: const DrawerMotion(), children: [
                SlidableAction(
                  onPressed: (context) async {
                    await sendDeleteJSP(index);
                    reloadData();
                  },
                  icon: Icons.delete_outline,
                  label: '삭제하기',
                  backgroundColor: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
              ]),
              child: GestureDetector(
                onTap: () =>
                    Get.to(const GPSPage3(), arguments: eatlist[index]),
                child: Card(
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.height / 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'http://localhost:8080/Flutter/MustEatPlace/image/${eatlist[index]['image']}',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3 * 1.78,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                eatlist[index]['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width /
                                      3 *
                                      1.4,
                                  height:
                                      MediaQuery.of(context).size.height / 16,
                                  child: Text(
                                    eatlist[index]['estimate'],
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.call),
                                  label: Text(eatlist[index]['phone']),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(Home());
              },
              child: Text('FireBase'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(Home2());
              },
              child: Text('Sqlite'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('MySQL'),
            ),
          ],
        ),
      ),
    );
  }

  showDeleteDialog() {
    Get.defaultDialog(title: '완료', middleText: '맛집 리스트가 삭제되었습니다.', actions: [
      ElevatedButton(
          onPressed: () {
            Get.back();
            setState(() {});
          },
          child: const Text('확인'))
    ]);
  }

  sendDeleteJSP(index) async {
    String seq = eatlist[index]['seq'];

    var url = Uri.parse(
        'http://localhost:8080/Flutter/MustEatPlace/delete_musteat_list.jsp?seq=$seq');
    var response = await http.get(url);
    var convert = json.decode(utf8.decode(response.bodyBytes));

    var result = convert['result'];
    result == 'OK' ? showDeleteDialog() : _errorDelteSnackBar();
  }

  _errorDelteSnackBar() {
    Get.snackbar(
      '오류 발생',
      '삭제 중 오류가 발생하였습니다. 다시 시도해주세요.',
      borderColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
