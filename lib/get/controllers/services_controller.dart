import 'dart:core';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:service_app/get/services/api_service.dart';
import 'package:service_app/get/services/db_service.dart';
import 'package:service_app/get/services/shared_preferences_service.dart';
import 'package:service_app/models/brand.dart';
import 'package:service_app/models/service.dart';

class ServicesController extends GetxController {
  var isLoading = false.obs;
  var isSearching = false.obs;
  var hideFinished = false.obs;

  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<DateTime> _lastSyncDate = DateTime.now().obs;

  RxList<Service> _services = <Service>[].obs;

  int get servicesCount => _services.length;

  RxList<Brand> brands = <Brand>[].obs;
  RxList<Service> filteredServices = <Service>[].obs;

  String searchString = "";
  List<String> statusFilters = <String>[];

  ApiService _apiService;
  DbService _dbService;
  SharedPreferencesService _sharedPreferencesService;
  String _token;
  String _personName;
  String _personId;

  @override
  void onInit() {
    super.onInit();

    _apiService = Get.find();
    _dbService = Get.find();
    _sharedPreferencesService = Get.find();

    _lastSyncDate.value = _sharedPreferencesService.getLastSyncDate();
    _token = _sharedPreferencesService.getAccessToken();
    _personName = _sharedPreferencesService.getPersonName();
    _personId = _sharedPreferencesService.getPersonExternalId();

    _services.listen((value) => updateFilteredServices());
    _lastSyncDate.listen((value) {
      _sharedPreferencesService.setLastSyncDate(value);
    });

    ref(DateTime.now());
  }

  void disposeController() {
    _lastSyncDate.value = null;

    selectedDate.value = DateTime.now();
    _services.clear();
    filteredServices.clear();
  }

  Future<void> sync() async {
    try {
      isLoading.value = true;

      await _syncBrands();
      await _syncGoods();
      await _syncGoodPrices();
      await _syncServices();

      _lastSyncDate.value = DateTime.now();
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> ref(DateTime dt) async {
    try {
      selectedDate.value = dt;

      await _refreshServices();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _syncServices() async {
    var services = await _apiService.getServices(_token, _lastSyncDate.value);
    await _dbService.saveServices(services);

    await _refreshServices();
  }

  Future<void> _syncBrands() async {
    var brands = await _apiService.getBrands(_token, _lastSyncDate.value);
    await _dbService.saveBrands(brands);
    this.brands.assignAll(brands);
  }

  Future<void> _syncGoods() async {
    var goods = await _apiService.getGoods(_token, _lastSyncDate.value);
    await _dbService.saveGoods(goods);
  }

  Future<void> _syncGoodPrices() async {
    var goodPrices =
        await _apiService.getGoodPrices(_token, _lastSyncDate.value);
    await _dbService.saveGoodPrices(goodPrices);
  }

  Future<void> _refreshServices() async {
    if (brands.isEmpty) {
      var dbBrands = await _dbService.getBrands();
      brands.assignAll(dbBrands);
    }

    if (!isSearching.value) {
      DateTime d = selectedDate.value;
      DateTime _dateStart = DateTime(d.year, d.month, d.day);
      DateTime _dateEnd =
          _dateStart.add(Duration(hours: 23, minutes: 59, seconds: 59));
      //TODO: убрать код ниже чисто для вывода данных
      /* DateTime _dateStart = DateTime(2020, 12, 1);
      DateTime _dateEnd = DateTime(2020, 12, 31); */

      var dbServices =
          await _dbService.getServices(_personId, _dateStart, _dateEnd);
      _services.assignAll(dbServices);
    }
    if (isSearching.value && searchString.isNotEmpty) {
      var dbServices =
          await _dbService.getServicesBySearch(_personId, searchString);
      _services.assignAll(dbServices);
    }
  }

  String getName() {
    return _personName;
  }

  void updateFilteredServices() {
    filteredServices.assignAll(_services
        .where((service) => statusFilters.length > 0
            ? service.checkStatus(statusFilters)
            : true)
        .toList());
  }

  void callMethod(BuildContext context, String phones) async {
    var phonesList = phones.split(",");
    var selectedPhone = "";

    if (phonesList.length > 1) {
      List<SimpleDialogOption> chooseList = [];

      phones.split(",").forEach((element) {
        SimpleDialogOption option = SimpleDialogOption(
          child: Text(element.trim()),
          onPressed: () {
            Navigator.pop(context, element);
          },
        );

        chooseList.add(option);
      });

      selectedPhone = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Выберите номер'),
              children: chooseList,
            );
          });
    } else {
      selectedPhone = phonesList.first;
    }

    if (selectedPhone != null) launch('tel:$selectedPhone');
  }

  void openNavigator(Service service) {
    if (service.lat != "" && service.lon != "") {
      MapsLauncher.launchCoordinates(
          double.parse(service.lat), double.parse(service.lon));
    } else {
      MapsLauncher.launchQuery('${service.getShortAddress()}');
    }
  }
}
