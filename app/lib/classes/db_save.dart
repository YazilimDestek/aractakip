import 'package:connectivity/connectivity.dart';
import 'package:hesap.co_app/classes/localdb/database_crud.dart';
import 'package:hesap.co_app/classes/type_loc_model.dart';
import 'package:hesap.co_app/services/location_service.dart';
import 'package:hesap.co_app/services/transtype_qr_service.dart';
import 'package:hesap.co_app/services/transtype_service.dart';

Future<bool> dbSave() async {
  DatabaseDao _databaseDao = DatabaseDao();

  TransTypeService _transTypeService = TransTypeService();
  LocationService _locationService = LocationService();
  TransTypeQrService _transTypeQrService = TransTypeQrService();

  try {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      print("İnternet Yok");
      return false;
    } else if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      await _databaseDao.deleteAll();

      List<Model> _model = await _locationService.getLocationInfo();
      await _databaseDao.insertLocation(_model);
      List<Model> _transfer = await _transTypeService.getTransTypeInfo();
      await _databaseDao.insertTranstype(_transfer);
      List<Model> _transferqr = await _transTypeQrService.getTransTypeQrInfo();
      await _databaseDao.insertTranstypeQr(_transferqr);

      if (_model.length > 0 && _transfer.length > 0 && _transferqr.length > 0) {
        print("DATA VAR");
        return true;
      } else {
        print("Data Boş");
        return false;
      }
    }
  } catch (e) {
    print("Beklenmedik");
    return false;
  }
}
