import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project/view/gps2.dart';
import 'package:project/view/home.dart';
import 'package:project/view/insert2.dart';
import 'package:project/view/update2.dart';
import 'package:project/vm/database_handler.dart';

class Home2 extends StatefulWidget {
  const Home2({Key? key}) : super(key: key);

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  late DatabaseHandler handler;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite for Students'),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const InsertStudents())!
                  .then((value) => reloadData());
            },
            icon: const Icon(Icons.add_outlined),
          )
        ],
      ),
      body: FutureBuilder(
        future: handler.queryStudents(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(() => const GPSPage1(), arguments: [
                      snapshot.data![index].seq,
                      snapshot.data![index].name,
                      snapshot.data![index].phone,
                      snapshot.data![index].image,
                      snapshot.data![index].lat.toString(),
                      snapshot.data![index].lng.toString(),
                      snapshot.data![index].estimate
                    ]);
                  },
                  child: Slidable(
                    startActionPane:
                        ActionPane(motion: const DrawerMotion(), children: [
                      SlidableAction(
                        backgroundColor: Colors.green,
                        label: '수정',
                        icon: Icons.edit,
                        onPressed: (context) {
                          Get.to(() => const UpdateStudents(), arguments: [
                            snapshot.data![index].seq,
                            snapshot.data![index].name,
                            snapshot.data![index].phone,
                            snapshot.data![index].image,
                            snapshot.data![index].lat.toString(),
                            snapshot.data![index].lng.toString(),
                            snapshot.data![index].estimate
                          ])!
                              .then((value) => reloadData());
                        },
                      ),
                    ]),
                    endActionPane:
                        ActionPane(motion: const DrawerMotion(), children: [
                      SlidableAction(
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: '삭제',
                        onPressed: (context) {
                          handler.deletestudents(snapshot.data![index]);
                          reloadData();
                        },
                      ),
                    ]),
                    child: Card(
                      child: ListTile(
                        title: Row(
                          children: [
                            Image.memory(
                              snapshot.data![index].image,
                              width: 100,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('이름: ${snapshot.data![index].name}'),
                                SizedBox(height: 10),
                                Text('전화번호: ${snapshot.data![index].phone}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
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
              onPressed: () {},
              child: Text('Sqlite'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('세 번째 버튼'),
            ),
          ],
        ),
      ),
    );
  }

  reloadData() {
    handler.queryStudents();
    setState(() {});
  }
}
