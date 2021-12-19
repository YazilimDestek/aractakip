import 'package:hesap.co_app/classes/qr_data_class.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database _database;

  String _qrDataTable = "qrData";
  String _primary = "_id";
  String _columnDestinationLocationId = "DestinationLocationId";
  String _columnTransactionTypeId = "TransactionTypeId";
  String _columnQRModel = "QRModel";
  String _columnMultiorSingle = "MultiorSingle";
  String _columnCreateTime = "CreateTime";
  String _columnErrorMessage = "ErrorMessage";
  String _columnIsSuccess = "IsSuccess";

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    String dbPath = join(await getDatabasesPath(), "QRData.db");
    var QRDataDb = await openDatabase(dbPath, version: 1, onCreate: createDb);
    return QRDataDb;
  }

  void createDb(Database db, int version) async   {
    await db.execute(
        "Create table $_qrDataTable(_id INTEGER PRIMARY KEY, $_columnDestinationLocationId integer, $_columnTransactionTypeId integer,"
            "$_columnQRModel var, $_columnMultiorSingle text, $_columnCreateTime text, $_columnErrorMessage text, $_columnIsSuccess bool)");
  }
  Future<List<ScanModel>> getAllData() async {
    Database db = await this.database;
    var result = await db.query("$_qrDataTable");
    return List.generate(result.length, (i) {
      return ScanModel.fromMap(result[i]);
    });
  }
  Future<int> update(ScanModel qrScanModel) async {
    Database db = await this.database;
    var result = await db.update("$_qrDataTable", qrScanModel.toMap(),
        where: "id=?", whereArgs: [qrScanModel.id]);
    return result;
  }

  Future<int> insert(ScanModel QRData) async {
    Database db = await this.database;
    var result = await db.insert("$_qrDataTable", QRData.toMap());
    return result;
  }
  deleteAll() async {
    Database db = await this.database;
    db.execute("delete from $_qrDataTable");
  }
  Future<int> delete(ScanModel scanModel) async {
    Database db = await this.database;
    var result = await db.rawDelete("delete from $_qrDataTable where _id = ${scanModel.id}");
    return result;
  }

}