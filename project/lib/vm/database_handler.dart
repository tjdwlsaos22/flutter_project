import 'package:path/path.dart';
import 'package:project/model/sqlite.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'musteatplace.db'), //경로에 해당 디비 이름으로 만든다.
      onCreate: (db, version) async {
        //디비 처음 만들때 실행하는 코드
        await db.execute(
            "create table musteatplace (seq integer primary key autoincrement, name text, phone text, lat real, lng real,image blob,estimate text,initdate text)");
      },
      version: 1,
    );
  }

  Future<List<Students>> queryStudents() async {
    final Database db = await initializeDB(); //위에  initializeDB() 가져오기.
    final List<Map<String, Object?>> queryResults =
        await db.rawQuery('select * from musteatplace');
    return queryResults.map((e) => Students.fromMap(e)).toList();
  }

  Future<void> insertStudents(Students student) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawInsert(
        'insert into musteatplace(name,phone,lat,lng,image,estimate,initdate) values(?,?,?,?,?,?,datetime("now"))',
        [
          student.name,
          student.phone,
          student.lat,
          student.lng,
          student.image,
          student.estimate,
        ]);
    //int 대신 void쓰면 리턴 필요없음.
  }

  Future<void> updatestudents(Students student) async {
    final Database db = await initializeDB();
    await db.rawUpdate(
        'update musteatplace set name=?,phone=?,lat=?,lng=?,image=?,estimate=?,initdate=datetime("now") where seq=?',
        [
          student.name,
          student.phone,
          student.lat,
          student.lng,
          student.image,
          student.estimate,
          student.seq
        ]);
  }

  Future<void> deletestudents(Students student) async {
    final Database db = await initializeDB();
    await db.rawDelete('delete from musteatplace where seq=?', [student.seq]);
  }
}
