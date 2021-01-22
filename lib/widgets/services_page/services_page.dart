import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:service_app/get/controllers/sync_controller.dart';
import 'package:service_app/get/controllers/service_controller.dart';
import 'package:service_app/get/controllers/services_controller.dart';
import 'package:service_app/models/brand.dart';
import 'package:service_app/models/service.dart';
import 'package:service_app/constants/app_colors.dart';
import 'package:service_app/widgets/service_page/service_page.dart';
import 'package:service_app/widgets/services_page/services_list_tile.dart';
import 'package:service_app/widgets/services_page/services_filter_panel.dart';
import 'package:service_app/widgets/side-menu/side-menu.dart';

class ServicesPage extends StatefulWidget {
  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final SyncController syncController = Get.put(SyncController());
  final ServicesController servicesController = Get.put(ServicesController());
  final ServiceController serviceController = Get.put(ServiceController());
  final GlobalKey<RefreshIndicatorState> _refKey =
      GlobalKey<RefreshIndicatorState>();
  final PanelController _panelController = PanelController();

  DateTime selectedDate = DateTime.now();
  bool showFAB = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _refKey.currentState.show();
    });
  }

  Widget _buildRow(Service service, List<Brand> brands) {
    var brand = brands.firstWhere(
        (brand) => brand.externalId == service.brandId,
        orElse: () => null);

    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () async {
          await serviceController.init(service.id);
          await serviceController.onInit();
          await Get.to(ServicePage(
            serviceId: service.id,
            brand: brand,
          ));
        },
        child: ServiceListTile(
          service: service,
          brand: brand,
        ),
      ),
    );
  }

  void _clearSearch() {
    servicesController.isSearching.value =
        !servicesController.isSearching.value;

    if (!servicesController.isSearching.value) {
      servicesController.searchString = "";
    }

    servicesController.ref(selectedDate);

    setState(() {});
  }

  void _hideFilterButton(bool hide) {
    if (hide) {
      showFAB = true;
    } else {
      _panelController.open();
      showFAB = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !servicesController.isSearching.value
            ? Row(children: [
                Text("Заявки"),
                Obx(() => Text(" (${servicesController.servicesCount})")),
              ])
            : TextField(
                decoration: InputDecoration(
                    icon: Icon(Icons.search, color: kSecondColor),
                    hintText: 'Поиск',
                    hintStyle: kSearchBarTextStyle),
                style: kSearchBarTextStyle,
                autofocus: true,
                onChanged: (value) {
                  servicesController.searchString = value;
                },
                onEditingComplete: () => servicesController.ref(selectedDate),
              ),
        actions: [
          IconButton(
            icon: !servicesController.isSearching.value
                ? Icon(Icons.search)
                : Icon(Icons.cancel),
            onPressed: _clearSearch,
          )
        ],
      ),
      drawer: SideMenu(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Visibility(
        visible: showFAB,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => syncController.needSync
                    ? FloatingActionButton.extended(
                        onPressed: () => servicesController.sync(),
                        label: Row(
                          children: [
                            Icon(
                              Icons.sync_problem,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5.0),
                            Text(
                              'Синхронизировать',
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      )
                    : SizedBox(),
              ),
              FloatingActionButton(
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                heroTag: 'rfab',
                onPressed: () => _hideFilterButton(false),
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            RefreshIndicator(
                key: _refKey,
                child: Column(
                  children: [
                    Expanded(
                      child: Obx(
                        () => ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: servicesController.filteredServices.length,
                          itemBuilder: (context, i) {
                            return _buildRow(
                                servicesController.filteredServices[i],
                                servicesController.brands);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                onRefresh: () => servicesController.sync()),
            FilterPanel(
              selectedDate: servicesController.selectedDate.value,
              controller: _panelController,
              onDateChange: (value) {
                selectedDate = value;

                if (servicesController.isSearching.value) {
                  _clearSearch();
                } else {
                  servicesController.ref(selectedDate);
                }
              },
              hideFilterButton: () => _hideFilterButton(true),
            )
          ],
        ),
      ),
    );
  }
}
