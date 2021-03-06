import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:service_app/models/brand.dart';
import 'package:service_app/models/closed_dates.dart';
import 'package:service_app/models/good.dart';
import 'package:service_app/models/good_price.dart';
import 'package:service_app/models/mounting.dart';
import 'package:service_app/models/mounting_image.dart';
import 'package:service_app/models/mounting_stage.dart';
import 'package:service_app/models/service.dart';
import 'package:service_app/models/service_good.dart';
import 'package:service_app/models/service_image.dart';
import 'package:service_app/models/push_notifications.dart';
import 'package:service_app/models/construction_type.dart';
import 'package:service_app/models/stage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbService extends GetxService {
  static const SERVICES_TABLE_NAME = "services";
  static const SERVICE_GOODS_NAME = "service_goods";
  static const SERVICE_IMAGES_NAME = "service_images";
  static const BRANDS_TABLE_NAME = "brands";
  static const GOODS_TABLE_NAME = "goods";
  static const GOOD_PRICES_TABLE_NAME = "good_prices";
  static const PUSH_NOTIFICATIONS_TABLE_NAME = "push_notifications";
  static const CLOSED_DATES_TABLE_NAME = "closed_dates";
  static const MOUNTINGS_TABLE_NAME = "mountings";
  static const MOUNTINGS_STAGES_TABLE_NAME = "mounting_stages";
  static const MOUNTINGS_IMAGES_TABLE_NAME = "mounting_images";
  static const CONSTRUCTION_TYPES_TABLE_NAME = "construction_types";
  static const CONSTRUCTION_STAGES_TABLE_NAME = "construction_stages";

  static Database _database;

  Future<DbService> init() async {
    var databasesPath = await getDatabasesPath();
    print(databasesPath);
    String path = join(databasesPath, 'app.db');

    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE $SERVICES_TABLE_NAME '
          '('
          'id INTEGER PRIMARY KEY,'
          'state TEXT,'
          'createdAt DATETIME,'
          'updatedAt DATETIME,'
          'externalId TEXT,'
          'number TEXT,'
          'deleteMark BOOLEAN,'
          'status TEXT,'
          'dateStart DATETIME,'
          'dateEnd DATETIME,'
          'cityId TEXT,'
          'brandId TEXT,'
          'customer TEXT,'
          'customerAddress TEXT,'
          'floor TEXT,'
          'lat TEXT,'
          'lon TEXT,'
          'intercom BOOLEAN,'
          'thermalImager BOOLEAN,'
          'phone TEXT,'
          'comment TEXT,'
          'userId TEXT,'
          'paymentType TEXT,'
          'customerDecision TEXT,'
          'refuseReason TEXT,'
          'userComment TEXT,'
          'dateStartNext DATETIME,'
          'dateEndNext DATETIME,'
          'sumTotal INTEGER,'
          'sumPayment INTEGER,'
          'sumDiscount INTEGER,'
          'export BOOLEAN'
          ')');
      await db.execute('CREATE TABLE $SERVICE_GOODS_NAME '
          '('
          'id TEXT,'
          'workType TEXT,'
          'serviceId INTEGER,'
          'construction TEXT,'
          'goodId INTEGER,'
          'price INTEGER,'
          'qty INTEGER,'
          'sum INTEGER,'
          'export BOOLEAN,'
          'UNIQUE(id, serviceId)'
          ')');
      await db.execute('CREATE TABLE $SERVICE_IMAGES_NAME '
          '('
          'id TEXT,'
          'serviceId INTEGER,'
          'fileId INTEGER,'
          'fileName TEXT,'
          'local TEXT,'
          'export BOOLEAN,'
          'UNIQUE(id, serviceId)'
          ')');
      await db.execute('CREATE TABLE $BRANDS_TABLE_NAME '
          '('
          'id INTEGER PRIMARY KEY,'
          'externalId TEXT,'
          'name TEXT,'
          'code TEXT,'
          'deleteMark BOOLEAN,'
          'brandColor TEXT'
          ')');
      await db.execute('CREATE TABLE $GOODS_TABLE_NAME '
          '('
          'id INTEGER PRIMARY KEY,'
          'externalId TEXT,'
          'name TEXT,'
          'parentId TEXT,'
          'code TEXT,'
          'deleteMark BOOLEAN,'
          'article TEXT,'
          'isGroup BOOLEAN,'
          'minPrice INTEGER,'
          'image TEXT'
          ')');
      await db.execute('CREATE TABLE $GOOD_PRICES_TABLE_NAME '
          '('
          'id INTEGER PRIMARY KEY,'
          'period DATETIME,'
          'goodId TEXT,'
          'cityId TEXT,'
          'brandId TEXT,'
          'name TEXT,'
          'price INTEGER,'
          'UNIQUE(goodId, cityId, brandId)'
          ')');
      await db.execute('CREATE TABLE $PUSH_NOTIFICATIONS_TABLE_NAME '
          '('
          'id TEXT PRIMARY KEY,'
          'createdAt DATETIME,'
          'messageType TEXT,'
          'guid TEXT,'
          'title TEXT,'
          'subtitle TEXT,'
          'body TEXT,'
          'isNew bool'
          ')');
      await db.execute('CREATE TABLE $CLOSED_DATES_TABLE_NAME '
          '('
          'cityId TEXT,'
          'date DATETIME,'
          'UNIQUE(cityId, date)'
          ')');
      await db.execute('CREATE TABLE $CONSTRUCTION_TYPES_TABLE_NAME'
          '('
          'id TEXT,'
          'code TEXT,'
          'name TEXT,'
          'workDir TEXT'
          ')');
      await db.execute('CREATE TABLE $CONSTRUCTION_STAGES_TABLE_NAME'
          '('
          'id TEXT,'
          'code TEXT,'
          'name TEXT,'
          'constructionTypeId TEXT'
          ')');
      await db.execute('CREATE TABLE $MOUNTINGS_TABLE_NAME'
          '('
          'id INTEGER PRIMARY KEY,'
          'state TEXT,'
          'createdAt DATETIME,'
          'updatedAt DATETIME,'
          'externalId TEXT,'
          'number TEXT,'
          'deleteMark BOOLEAN,'
          'date DATETIME,'
          'dateStart DATETIME,'
          'constructionTypeId TEXT,'
          'cityId TEXT,'
          'brandId TEXT,'
          'customer TEXT,'
          'customerAddress TEXT,'
          'floor TEXT,'
          'lat TEXT,'
          'lon TEXT,'
          /* 'intercom BOOLEAN,'
          'thermalImager BOOLEAN,' */
          'phone TEXT,'
          'comment TEXT,'
          'avalible BOOLEAN,'
          'actCommited BOOLEAN,'
          /* 'customerDecision TEXT,'
          'refuseReason TEXT,'
          'userComment TEXT,'
          'dateStartNext DATETIME,'
          'dateEndNext DATETIME,'
          'sumTotal INTEGER,'
          'sumPayment INTEGER,'
          'sumDiscount INTEGER,' */
          'export BOOLEAN'
          ')');
      await db.execute('CREATE TABLE $MOUNTINGS_STAGES_TABLE_NAME'
          '('
          'id TEXT,'
          'createdAt DATETIME,'
          'updatedAt DATETIME,'
          'stageId TEXT,'
          'mountingId INTEGER,'
          'personId TEXT,'
          'result TEXT,'
          'comment TEXT,'
          'export BOOLEAN,'
          'UNIQUE(id, mountingId, stageId)'
          ')');
      await db.execute('CREATE TABLE $MOUNTINGS_IMAGES_TABLE_NAME'
          '('
          'id TEXT,'
          'mountingId INTEGER,'
          'stageId TEXT,'
          'fileId INTEGER,'
          'fileName TEXT,'
          'local TEXT,'
          'export BOOLEAN,'
          'UNIQUE(id, mountingId, stageId)'
          ')');
    });
    print('$runtimeType ready!');
    return this;
  }

  Future<void> disposeTables() async {
    await _database.delete('$SERVICES_TABLE_NAME');
    await _database.delete('$SERVICE_IMAGES_NAME');
    await _database.delete('$SERVICE_GOODS_NAME');
    await _database.delete('$BRANDS_TABLE_NAME');
    await _database.delete('$GOODS_TABLE_NAME');
    await _database.delete('$GOOD_PRICES_TABLE_NAME');
    await _database.delete('$PUSH_NOTIFICATIONS_TABLE_NAME');
    await _database.delete('$CLOSED_DATES_TABLE_NAME');
    await _database.delete('$MOUNTINGS_TABLE_NAME');
    await _database.delete('$MOUNTINGS_STAGES_TABLE_NAME');
    await _database.delete('$MOUNTINGS_IMAGES_TABLE_NAME');
    await _database.delete('$CONSTRUCTION_TYPES_TABLE_NAME');
    await _database.delete('$CONSTRUCTION_STAGES_TABLE_NAME');
  }

  Future<void> saveServices(List<Service> services) async {
    await _database.transaction((txn) async {
      services.forEach((service) async {
        await txn.insert(SERVICES_TABLE_NAME, service.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        service.serviceGoods?.forEach((serviceGood) async {
          await txn.insert(SERVICE_GOODS_NAME, serviceGood.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        service.serviceImages?.forEach((serviceImage) async {
          await txn.insert(SERVICE_IMAGES_NAME, serviceImage.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
      });
    });
  }

  Future<void> saveMountings(List<Mounting> mountings) async {
    await _database.transaction((txn) async {
      mountings.forEach((mounting) async {
        await txn.insert(MOUNTINGS_TABLE_NAME, mounting.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        mounting.mountingImages?.forEach((mountingImage) async {
          await txn.insert(MOUNTINGS_IMAGES_TABLE_NAME, mountingImage.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        mounting.mountingStages?.forEach((mountingStage) async {
          await txn.insert(MOUNTINGS_STAGES_TABLE_NAME, mountingStage.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
      });
    });
  }

  Future<List<Service>> getServices(
      String userId, DateTime dStart, DateTime dEnd) async {
    String _query =
        "userId = ? AND (dateStart >= ? AND dateEnd <= ?) AND deleteMark == 0";

    final List<Map<String, dynamic>> maps = await _database.query(
      SERVICES_TABLE_NAME,
      where: _query,
      whereArgs: [userId, dStart.toString(), dEnd.toString()],
      orderBy: "dateStart",
    );
    return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
  }

  Future<List<Mounting>> getMountings(DateTime dStart, DateTime dEnd) async {
    String _query = "(dateStart >= ? AND dateStart <= ?) AND deleteMark == 0";

    final List<Map<String, dynamic>> maps = await _database.query(
      MOUNTINGS_TABLE_NAME,
      where: _query,
      whereArgs: [dStart.toString(), dEnd.toString()],
      orderBy: "dateStart",
    );
    return List.generate(maps.length, (i) => Mounting.fromMap(maps[i]));
  }

  Future<dynamic> getRecordByField(
      String tableName, String field, dynamic value) async {
    String _query = "$field = ?";

    final List<Map<String, dynamic>> maps = await _database.query(
      tableName,
      where: _query,
      whereArgs: [value],
    );
    return maps.first;
  }

  /* TODO: change calls to getRecordByField */
  Future<Service> getServiceById(int id) async {
    String _query = "id = ?";

    final List<Map<String, dynamic>> maps = await _database.query(
      SERVICES_TABLE_NAME,
      where: _query,
      whereArgs: [id],
    );
    return Service.fromMap(maps.first);
  }

  Future<Mounting> getMountingById(int id) async {
    String _query = "id = ?";

    final List<Map<String, dynamic>> maps = await _database.query(
      MOUNTINGS_TABLE_NAME,
      where: _query,
      whereArgs: [id],
    );
    return Mounting.fromMap(maps.first);
  }

  Future<Service> getServiceByGUID(String guid) async {
    String _query = "externalId = ?";

    final List<Map<String, dynamic>> maps = await _database.query(
      SERVICES_TABLE_NAME,
      where: _query,
      whereArgs: [guid],
    );
    return maps.length > 0 ? Service.fromMap(maps.first) : null;
  }

  Future<List<Service>> getServicesBySearch(
      String userId, String search) async {
    String _search = '%' + search + '%';
    String _query =
        "userId = ? AND (number LIKE ? OR customerAddress LIKE ?) AND deleteMark == 0";

    final List<Map<String, dynamic>> maps = await _database.query(
      SERVICES_TABLE_NAME,
      where: _query,
      whereArgs: [userId, _search, _search],
      orderBy: "dateStart DESC",
    );
    return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
  }

  Future<List<Mounting>> getMountingsBySearch(
      String userId, String search) async {
    String _search = '%' + search + '%';
    String _query =
        "avalible == 1 AND (number LIKE ? OR customerAddress LIKE ?) AND deleteMark == 0";

    final List<Map<String, dynamic>> maps = await _database.query(
      MOUNTINGS_TABLE_NAME,
      where: _query,
      whereArgs: [_search, _search],
      orderBy: "dateStart DESC",
    );
    return List.generate(maps.length, (i) => Mounting.fromMap(maps[i]));
  }

  Future<void> saveBrands(List<Brand> brands) async {
    await _database.transaction((txn) async {
      brands.forEach((brand) async {
        await txn.insert(BRANDS_TABLE_NAME, brand.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
  }

  Future<List<Brand>> getBrands() async {
    final List<Map<String, dynamic>> maps =
        await _database.query(BRANDS_TABLE_NAME);
    return List.generate(maps.length, (i) => Brand.fromMap(maps[i]));
  }

  Future<void> saveConstructionTypes(
      List<ConstructionType> constructionTypes) async {
    await _database.transaction((txn) async {
      constructionTypes.forEach((ct) async {
        await txn.insert(CONSTRUCTION_TYPES_TABLE_NAME, ct.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
  }

  Future<List<ConstructionType>> getConstructionTypes() async {
    final List<Map<String, dynamic>> maps =
        await _database.query(CONSTRUCTION_TYPES_TABLE_NAME);
    return List.generate(maps.length, (i) => ConstructionType.fromMap(maps[i]));
  }

  Future<void> saveStages(List<Stage> stages) async {
    await _database.transaction((txn) async {
      stages.forEach((stage) async {
        await txn.insert(CONSTRUCTION_STAGES_TABLE_NAME, stage.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
  }

  Future<List<Stage>> getStages() async {
    final List<Map<String, dynamic>> maps =
        await _database.query(CONSTRUCTION_STAGES_TABLE_NAME);
    return List.generate(maps.length, (i) => Stage.fromMap(maps[i]));
  }

  Future<void> saveClosedDates(List<ClosedDates> cldates) async {
    await _database.transaction((txn) async {
      cldates.forEach((cldate) async {
        await txn.insert(CLOSED_DATES_TABLE_NAME, cldate.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
  }

  Future<List<ClosedDates>> getClosedDates(String cityID) async {
    String _query = "cityId = ? AND date >= ?";

    final List<Map<String, dynamic>> maps = await _database.query(
        CLOSED_DATES_TABLE_NAME,
        where: _query,
        whereArgs: [cityID, DateTime.now().toString()]);
    return List.generate(maps.length, (i) => ClosedDates.fromMap(maps[i]));
  }

  Future<void> savePush(List<PushNotification> push) async {
    await _database.transaction((txn) async {
      push.forEach((p) async {
        await txn.insert(PUSH_NOTIFICATIONS_TABLE_NAME, p.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
  }

  Future<List<PushNotification>> getPush(int limit) async {
    final List<Map<String, dynamic>> maps = await _database.query(
        PUSH_NOTIFICATIONS_TABLE_NAME,
        orderBy: "createdAt DESC",
        limit: limit);
    return List.generate(maps.length, (i) => PushNotification.fromMap(maps[i]));
  }

  Future<void> saveGoods(List<Good> goods) async {
    await _database.transaction((txn) async {
      goods.forEach((good) async {
        await txn.insert(GOODS_TABLE_NAME, good.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        // print('inserted good ${good.name}');
      });
    });
  }

  Future<List<Good>> getGoods(Service service) async {
    var maps = await _database.rawQuery(
        'SELECT goods.* ' +
            'FROM goods ' +
            'LEFT JOIN good_prices ' +
            'ON goods.externalId = good_prices.goodId ' +
            'WHERE (goods.deleteMark = 0 AND good_prices.brandId = ?) OR isGroup = 1',
        [service.brandId]);
    return List.generate(maps.length, (i) => Good.fromMap(maps[i]));
  }

  Future<void> saveGoodPrices(List<GoodPrice> goodPrices) async {
    await _database.transaction((txn) async {
      goodPrices.forEach((goodPrice) async {
        await txn.insert(GOOD_PRICES_TABLE_NAME, goodPrice.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        // print('inserted goodPrice ${goodPrice.name}');
      });
    });
  }

  Future<List<GoodPrice>> getGoodPrices(Service service) async {
    String _query = 'cityId = ? AND brandId = ?';
    var maps = await _database.query(GOOD_PRICES_TABLE_NAME,
        where: _query, whereArgs: [service.cityId, service.brandId]);
    return List.generate(maps.length, (i) => GoodPrice.fromMap(maps[i]));
  }

  Future<void> saveServiceGoods(List<ServiceGood> serviceGood) async {
    await _database.transaction((txn) async {
      serviceGood.forEach((sg) async {
        await txn.insert(SERVICE_GOODS_NAME, sg.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
  }

  Future<void> saveServiceImages(List<ServiceImage> serviceImage) async {
    await _database.transaction((txn) async {
      serviceImage.forEach((si) async {
        await txn.insert(SERVICE_IMAGES_NAME, si.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
  }

  Future<void> saveMountingImages(List<MountingImage> mountingImage) async {
    await _database.transaction((txn) async {
      mountingImage.forEach((si) async {
        await txn.insert(MOUNTINGS_IMAGES_TABLE_NAME, si.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
  }

  Future<void> addMountingStage(MountingStage mountingStage) async {
    await _database.transaction((txn) async {
      await txn.insert(MOUNTINGS_STAGES_TABLE_NAME, mountingStage.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> addMountingImage(MountingImage mountingImage) async {
    await _database.transaction((txn) async {
      await txn.insert(MOUNTINGS_IMAGES_TABLE_NAME, mountingImage.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> addServiceGood(ServiceGood serviceGood) async {
    await _database.transaction((txn) async {
      await txn.insert(SERVICE_GOODS_NAME, serviceGood.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> deleteServiceGood(ServiceGood serviceGood) async {
    await _database.transaction((txn) async {
      await txn.delete(SERVICE_GOODS_NAME,
          where: 'id = ?', whereArgs: [serviceGood.id]);
    });
  }

  Future<void> addServiceImage(ServiceImage serviceImage) async {
    await _database.transaction((txn) async {
      await txn.insert(SERVICE_IMAGES_NAME, serviceImage.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> deleteServiceImage(ServiceImage serviceImage) async {
    await _database.transaction((txn) async {
      await txn.delete(SERVICE_IMAGES_NAME,
          where: 'id = ?', whereArgs: [serviceImage.id]);
    });
  }

  Future<void> deleteMountingImage(MountingImage mountingImage) async {
    await _database.transaction((txn) async {
      await txn.delete(MOUNTINGS_IMAGES_TABLE_NAME,
          where: 'id = ?', whereArgs: [mountingImage.id]);
    });
  }

  Future<List<MountingStage>> getMountingStages(int mountingId) async {
    var _query = "mountingId = ?";

    final List<Map<String, dynamic>> maps = await _database.query(
      MOUNTINGS_STAGES_TABLE_NAME,
      where: _query,
      whereArgs: [mountingId],
      orderBy: "createdAt ASC",
    );
    return List.generate(maps.length, (i) => MountingStage.fromMap(maps[i]));
  }

  Future<List<ServiceGood>> getServiceGoods(int serviceId) async {
    var _query = "serviceId = ?";

    final List<Map<String, dynamic>> maps = await _database.query(
      SERVICE_GOODS_NAME,
      where: _query,
      whereArgs: [serviceId],
    );
    return List.generate(maps.length, (i) => ServiceGood.fromMap(maps[i]));
  }

  Future<List<ServiceImage>> getServiceImages(int serviceId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
        SERVICE_IMAGES_NAME,
        where: "serviceId = ?",
        whereArgs: [serviceId]);
    return List.generate(maps.length, (i) => ServiceImage.fromMap(maps[i]));
  }

  Future<List<MountingImage>> getMountingImages(int mountingId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
        MOUNTINGS_IMAGES_TABLE_NAME,
        where: "mountingId = ?",
        whereArgs: [mountingId]);
    return List.generate(maps.length, (i) => MountingImage.fromMap(maps[i]));
  }

  Future<List<Service>> getExportServices(String userId) async {
    String _query = "userId = ? AND deleteMark == 0 AND export == 1";
    final List<Map<String, dynamic>> maps = await _database
        .query(SERVICES_TABLE_NAME, where: _query, whereArgs: [userId]);
    return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
  }

  Future<List<ServiceGood>> getExportServiceGoods() async {
    String _query = "export == 1";
    final List<Map<String, dynamic>> maps =
        await _database.query(SERVICE_GOODS_NAME, where: _query);
    return List.generate(maps.length, (i) => ServiceGood.fromMap(maps[i]));
  }

  Future<List<ServiceImage>> getExportServiceImages() async {
    String _query = "export == 1";
    final List<Map<String, dynamic>> maps =
        await _database.query(SERVICE_IMAGES_NAME, where: _query);
    return List.generate(maps.length, (i) => ServiceImage.fromMap(maps[i]));
  }

  @override
  void onClose() {
    super.onClose();
    _database.close();
  }
}
