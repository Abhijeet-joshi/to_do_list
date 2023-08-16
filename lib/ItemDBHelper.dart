import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ItemDBHelper {

  var TABLE_NAME = "ITEMS";
  var ITEM_ID = "item_id";
  var ITEM_NAME = "item_name";
  var ITEM_CHECK = "item_check";

  Future<Database> openDB() async {
    var mDirectory = await getApplicationDocumentsDirectory();
    await mDirectory.create(recursive: true);
    var dbPath = "$mDirectory/itemdb.db";
    return await openDatabase(dbPath, version: 1, onCreate: (db, version) {
      var createQuery = "CREATE TABLE $TABLE_NAME ($ITEM_ID text primary key, $ITEM_NAME text, $ITEM_CHECK integer)";
      db.execute(createQuery);
    });
  }

  Future<bool> addItem(
      {required String id, required String name, required int checkVal}) async {
    var db = await openDB();
    var check = await db.insert(
        TABLE_NAME, {ITEM_ID: id, ITEM_NAME: name, ITEM_CHECK: checkVal});
    return check > 0;
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    var db = await openDB();
    List<Map<String, dynamic>> items = await db.query(TABLE_NAME);
    return items;
  }

  Future<bool> updateCheckOfItem(String id, int val) async{
    var db = await openDB();
    int check = await db.update(TABLE_NAME, {ITEM_CHECK: val}, where: "$ITEM_ID = $id");
    return check>0;
  }

  Future<bool> deleteItem(String id) async{
    var db = await openDB();
    int check = await db.delete(TABLE_NAME, where: "$ITEM_ID = ?", whereArgs: [id]);
    return check>0;
  }

  Future<List<Map<String, dynamic>>> deleteAllItems() async{
    var db = await openDB();
    List<Map<String, dynamic>> items = await db.rawQuery("DELETE FROM $TABLE_NAME");
    return items;
  }

  Future<List<Map<String, dynamic>>> getCount() async{

    String whereString = '$ITEM_CHECK = ?';
    List<dynamic> whereArguments = ["1"];

    var db = await openDB();
    var checkedItems = await db.query(TABLE_NAME, where: whereString, whereArgs: whereArguments);
    return checkedItems;
  }

}