import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:service_app/models/service.dart';
import 'package:service_app/redux/root_reducer.dart';
import 'package:service_app/widgets/call_button/call_button.dart';
import 'package:service_app/widgets/payment_page/payment_page.dart';
import 'package:service_app/widgets/refuse_page/refuse_page.dart';
import 'package:service_app/widgets/reschedule_page/reschedule_page.dart';
import 'package:service_app/widgets/service-to-page-view/service-to-page-view.dart';

class ServicePage extends StatelessWidget {
  final int serviceId;

  final controller = PageController(initialPage: 0);

  ServicePage({Key key, @required this.serviceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Service>(
      converter: (store) => store.state.servicesState.services.firstWhere((service) => service.id == serviceId),
      builder: (context, service) {
        return Scaffold(
          appBar: AppBar(
            title: Text(service.number),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ExpansionTile(
                        initiallyExpanded: true,
                        title: Text('Данные по заявке'),
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(service.customer, style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 8),
                                      Text('Адрес: ${service.customerAddress}'),
                                      SizedBox(height: 8),
                                      Text('Информация клиента: ${service.comment}'),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 8),
                                  child: PhoneButton(phone: service.phone),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(
                        child: Expanded(
                          child: PageView(
                            controller: controller,
                            children: [
                              ServiceTOPageView(title: 'Услуги ТО-1'),
                              ServiceTOPageView(title: 'Услуги ТО-2'),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: Colors.grey),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RefusePage()));
                          },
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                child: Icon(Icons.cancel, color: Colors.red, size: 24.0),
                              ),
                              Text('Отказ')
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ReschedulePage()));
                          },
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                child: Icon(Icons.calendar_today_rounded, color: Colors.blue, size: 24.0),
                              ),
                              Text('Перенести дату')
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage()));
                          },
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                child: Icon(Icons.check_circle, color: Colors.green, size: 24.0),
                              ),
                              Text('Завершить')
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}