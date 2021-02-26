import 'package:get/get.dart';
import 'package:service_app/get/controllers/account_controller.dart';
import 'package:service_app/get/controllers/sync_controller.dart';
import 'package:service_app/get/services/db_service.dart';
import 'package:service_app/models/brand.dart';
import 'package:service_app/models/construction_type.dart';
import 'package:service_app/models/mounting.dart';
import 'package:service_app/models/stage.dart';

class MountingsController extends GetxController {
  final SyncController syncController = Get.find();
  final AccountController accountController = Get.find();

  var _isSync = false.obs;
  var isSearching = false.obs;

  Rx<DateTime> selectedDateStart =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .obs;
  Rx<DateTime> selectedDateEnd = DateTime(DateTime.now().year,
          DateTime.now().month, DateTime.now().day, 23, 59, 59)
      .obs;

  RxList<Mounting> _mountings = <Mounting>[].obs;
  RxList<Mounting> filteredMountings = <Mounting>[].obs;
  RxList<Brand> brands = <Brand>[].obs;
  RxList<ConstructionType> constructionTypes = <ConstructionType>[].obs;
  RxList<Stage> stages = <Stage>[].obs;

  int get mountingCount => _mountings.length;
  bool get isSync => _isSync.value;

  DbService _dbService;

  String searchString = "";
  List<String> statusFilters = <String>[];

  Future<MountingsController> init() async {
    return this;
  }

  @override
  void onInit() async {
    super.onInit();

    _dbService = Get.find();

    _mountings.listen((value) => updateFilteredMountings());

    ref(selectedDateStart.value, selectedDateEnd.value);
  }

  void disposeController() {
    _mountings.clear();
  }

  Future<void> sync(bool showError, [bool syncAll = false]) async {
    _isSync.value = true;
    await syncController.syncMountings(
        selectedDateStart.value, selectedDateEnd.value, showError, syncAll);
    await _refreshMountings();
    _isSync.value = false;
  }

  Future<void> ref(DateTime dtstart, DateTime dtend) async {
    try {
      selectedDateStart.value = dtstart;
      selectedDateEnd.value = dtend;

      await _refreshMountings();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _refreshMountings() async {
    if (brands.isEmpty) {
      var dbBrands = await _dbService.getBrands();
      brands.assignAll(dbBrands);
    }

    if (!isSearching.value) {
      DateTime d1 = selectedDateStart.value;
      DateTime d2 = selectedDateEnd.value;

      DateTime _dateStart = DateTime(d1.year, d1.month, d1.day);
      DateTime _dateEnd = DateTime(d2.year, d2.month, d2.day, 23, 59, 59);

      var dbMountings = await _dbService.getMountings(_dateStart, _dateEnd);
      _mountings.assignAll(dbMountings);
    }
    if (isSearching.value && searchString.isNotEmpty) {
      var dbMountings = await _dbService.getMountingsBySearch(
          accountController.personId, searchString);
      _mountings.assignAll(dbMountings);
    }
  }

  void updateFilteredMountings() {
    filteredMountings.assignAll(_mountings
        .where((mounting) => statusFilters.length > 0
            ? mounting.checkState(statusFilters)
            : true)
        .toList());
  }
}
