import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:service_app/constants/app_fonts.dart';
import 'package:service_app/get/controllers/service_controller.dart';
import 'package:service_app/get/controllers/services_controller.dart';
import 'package:service_app/models/service_status.dart';
import 'package:service_app/widgets/service_page/service_goods_list.dart';
import 'package:service_app/widgets/service_page/service_body.dart';
import 'package:service_app/widgets/service_page/service_header.dart';
import 'package:service_app/widgets/goods_page/goods_page.dart';
import 'package:service_app/widgets/attachments_page/attachments_page.dart';

class ServicePage extends StatefulWidget {
  final int serviceId;

  ServicePage({Key key, @required this.serviceId});

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final ServiceController serviceController = Get.find();
  final ServicesController servicesController = Get.find();

  final List<String> lists = [WorkTypes.TO1, WorkTypes.TO2];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      serviceController.disposeController();
      servicesController.ref(servicesController.selectedDateStart.value,
          servicesController.selectedDateEnd.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    var serviceState = serviceController.service.value.state;
    var serviceStatus = serviceController.service.value.status;

    serviceController.fabsState.value = FabsState.Main;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => serviceController.service.value.id != -1
            ? Text('${serviceController.service.value.number ?? ''}')
            : SizedBox()),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Obx(() => ServiceHeader(
                      service: serviceController.service.value,
                      statusIcon: Icon(
                        ServiceState()
                            .getStateIcon(serviceState, serviceStatus),
                        color: serviceController.brand.value.bColor(),
                        size: 52.0,
                      ),
                    )),
                Obx(() =>
                    ServiceBody(service: serviceController.service.value)),
                Obx(() {
                  List<Widget> cards = [];
                  lists.forEach((card) {
                    cards.add(
                      GoodsList(
                        workType: card,
                        goodsList: serviceController.serviceGoods
                            .where((sg) => sg.workType == card)
                            .toList(),
                        onAdd: !serviceController.locked.value
                            ? () {
                                serviceController.workType.value = card;
                                Get.to(GoodsPage());
                                print(card);
                              }
                            : null,
                      ),
                    );
                  });
                  return Column(
                    children: cards,
                  );
                }),
                Card(
                  child: ListTile(
                    title: Text(
                      'Вложения (${serviceController.serviceImages.length})',
                      style: kCardTitleStyle,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      serviceController.fabsState.value = FabsState.AddImage;
                      Get.to(AttachmentsPage());
                    },
                  ),
                ),
                SizedBox(height: 130)
              ]),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          Obx(() => serviceController.refreshFabButtons(null)),
    );
  }
}
