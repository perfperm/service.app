import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:service_app/get/controllers/service_controller.dart';
import 'package:service_app/constants/app_fonts.dart';
import 'package:service_app/models/service.dart';
import 'package:service_app/models/service_status.dart';
import 'package:service_app/widgets/text/cardRow.dart';

class ServiceHeader extends StatelessWidget {
  ServiceHeader({@required this.service, @required this.statusIcon});

  final ServiceController serviceController = Get.find();
  final Service service;
  final Widget statusIcon;

  @override
  Widget build(BuildContext context) {
    if (service.id == -1) return SizedBox();

    String measureDate =
        DateFormat('dd.MM').format(service.dateStart).toString();
    String measureInterval =
        DateFormat.Hm().format(service.dateStart).toString() +
            " - " +
            DateFormat.Hm().format(service.dateEnd).toString();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListTile(
            leading: statusIcon,
            title: Text(
              "Статус заявки: ${service.status}",
              style: kCardTitleStyle,
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "\nДата: $measureDate\nВремя: $measureInterval",
                  style: kCardSubtitleStyle,
                ),
                Text("Бренд: ${serviceController.brand.value.name}",
                    style: kCardSubtitleStyle),
                Text(
                  "${(service.thermalImager ? '\n\nТребуется тепловизор' : '')}",
                  style: kCardSubtitleStyle,
                ),
                Visibility(
                    visible: service.status == ServiceStatus.Refuse,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CardRow(
                          leading: Text('Причина отказа:'),
                          tailing: Text(
                            service.refuseReason,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Комментарий: ' + service.userComment),
                        ),
                      ],
                    )),
                Visibility(
                  visible: service.status == ServiceStatus.Done ||
                      service.status == ServiceStatus.End,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CardRow(
                        leading: Text('Решение ТО-2'),
                        tailing: Text(
                          service.customerDecision,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      CardRow(
                          leading: Text('Сумма заказа:'),
                          tailing: MoneyPlate(
                            amount: service.sumTotal / 100,
                          )),
                      CardRow(
                        leading: Text('Сумма скидки:'),
                        tailing: MoneyPlate(
                          amount: service.sumDiscount / 100,
                        ),
                      ),
                      CardRow(
                        leading: Text('Сумма оплаты:'),
                        tailing: MoneyPlate(
                          amount: service.sumPayment / 100,
                        ),
                      ),
                      Visibility(
                        visible: service.userComment.length > 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Комментарий: ' + service.userComment),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
