import 'package:hesap.co_app/classes/localdb/database.dart';
import 'package:hesap.co_app/classes/type_loc_model.dart';
import 'package:sembast/sembast.dart';

class DatabaseDao {
  static const String LOCATION_NAME = 'locationModel';
  static const String TRANSTYPE_MODEL = 'transtypeModel';
  static const String TRANSTYPE_QR_MODEL = 'transtypeQrModel';

  final _locationModelStore = intMapStoreFactory.store(LOCATION_NAME);
  final _transtypeModelStore = intMapStoreFactory.store(TRANSTYPE_MODEL);
  final _transtypeQrModelStore = intMapStoreFactory.store(TRANSTYPE_QR_MODEL);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertLocation(List<Model> listModel) async {
    print("insertLocation");
    print(listModel[0].id);
    listModel.asMap().forEach((key, model) async {
      await _locationModelStore.add(await _db, model.toJson());
    });
  }

  Future insertTranstype(List<Model> listModel) async {
    print("insertTranstype");
    print(listModel[0].id);
    listModel.asMap().forEach((key, model) async {
      await _transtypeModelStore.add(await _db, model.toJson());
    });
  }

  Future insertTranstypeQr(List<Model> listModel) async {
    print("insertTranstypeQr");
    print(listModel[0].id);
    listModel.asMap().forEach((key, model) async {
      await _transtypeQrModelStore.add(await _db, model.toJson());
    });
  }

  Future getAllSortedByName() async {
    final finder = Finder(sortOrders: [
      SortOrder('entities'),
    ]);

    final recordSnapshots = await _locationModelStore.find(
      await _db,
      finder: finder,
    );
    print("local1");
    print(recordSnapshots);
    return recordSnapshots.map((snapshot) {
      final data = Model.fromJson(snapshot.value);
      return data;
    }).toList();
  }

  Future getAllSortedByName2() async {
    final finder = Finder(sortOrders: [
      SortOrder('entities'),
    ]);

    final recordSnapshots = await _transtypeModelStore.find(
      await _db,
      finder: finder,
    );
    print("local2");
    print(recordSnapshots);
    return recordSnapshots.map((snapshot) {
      final data = Model.fromJson(snapshot.value);
      return data;
    }).toList();
  }

  Future getAllSortedByName3() async {
    final finder = Finder(sortOrders: [
      SortOrder('entities'),
    ]);

    final recordSnapshots = await _transtypeQrModelStore.find(
      await _db,
      finder: finder,
    );
    print("local3");
    print(recordSnapshots);
    return recordSnapshots.map((snapshot) {
      final data = Model.fromJson(snapshot.value);
      return data;
    }).toList();
  }

  Future deleteAll() async {
    await _locationModelStore.delete(await _db);
    await _transtypeModelStore.delete(await _db);
    await _transtypeQrModelStore.delete(await _db);
  }
}
