import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:project/model/student.dart';
import 'package:project/view/gps.dart';
import 'package:project/view/home2.dart';
import 'package:project/view/home3.dart';
import 'package:project/view/insert.dart';
import 'package:project/view/update.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore List'),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(const Insert());
            },
            icon: const Icon(Icons.add_outlined),
          )
        ],
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('musteatplace')
              .orderBy('name', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final documents = snapshot.data!.docs;
            return ListView(
              children: documents.map((e) => _buildItemWidget(e)).toList(),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: Text('FireBase'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(Home2());
              },
              child: Text('Sqlite'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(OurRestaurant());
              },
              child: Text('MySQL'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemWidget(doc) {
    final musteatplace = Musteatplace(
      name: doc['name'],
      phone: doc['phone'],
      lat: doc['lat'],
      ing: doc['long'],
      image: doc['image'],
      estimate: doc['estimate'],
      initdate: doc['initdate'].toDate(),
    );

    return Dismissible(
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.edit),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_forever),
      ),
      key: ValueKey(doc),
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          FirebaseFirestore.instance
              .collection('musteatplace')
              .doc(doc.id)
              .delete();
          await deleteImage(musteatplace.name);
        } else if (direction == DismissDirection.startToEnd) {
          Get.to(const UpdatePage(), arguments: [
            doc.id,
            doc['name'],
            doc['phone'],
            doc['lat'],
            doc['long'],
            doc['image'],
            doc['estimate'],
            doc['initdate'].toDate(),
          ]);
          setState(() {});
        }
      },
      child: GestureDetector(
        onTap: () {
          Get.to(const GPSPage(), arguments: [
            doc.id,
            doc['name'],
            doc['phone'],
            doc['lat'],
            doc['long'],
            doc['image'],
            doc['estimate'],
            doc['initdate'].toDate(),
          ]);
        },
        child: Card(
          child: ListTile(
            title: Row(
              children: [
                Image.network(
                  musteatplace.image,
                  width: 100,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('이름: ${musteatplace.name}'),
                    SizedBox(height: 10),
                    Text('전화번호: ${musteatplace.phone}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  deleteImage(deletecode) async {
    final firebaseStorage =
        FirebaseStorage.instance.ref().child('images').child('$deletecode.png');

    firebaseStorage.delete();
  }
}
