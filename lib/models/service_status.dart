import 'package:flutter/material.dart';

class ServiceState {
  static const New = "new";
  static const Updated = "updt";
  static const WorkInProgress = "wip";
  static const WorkFinished = "wrk_fin";
  static const Exported = "exported";
  static const ExportError = "exp_err";

  IconData getStateIcon(String state, String status) {
    var stateIcon;

    switch (state) {
      case ServiceState.New:
        {
          stateIcon = Icons.fiber_new;
        }
        break;

      case ServiceState.Updated:
        {
          if (status == ServiceStatus.Start)
            stateIcon = Icons.note;
          else if (status == ServiceStatus.End)
            stateIcon = Icons.check_box;
          else if (status == ServiceStatus.Refuse)
            stateIcon = Icons.cancel;
          else
            stateIcon = Icons.error;
        }
        break;

      case ServiceState.WorkInProgress:
        {
          stateIcon = Icons.handyman;
        }
        break;

      case ServiceState.WorkFinished:
        {
          /* TODO: refactor to get normal icons for mounting */
          if (status == ServiceStatus.Start)
            stateIcon = Icons.check_box;
          else
            stateIcon = Icons.cloud_upload;
        }
        break;

      case ServiceState.Exported:
        {
          stateIcon = Icons.pending;
        }
        break;

      case ServiceState.ExportError:
        {
          stateIcon = Icons.error_outline;
        }
    }

    return stateIcon;
  }
}

class ServiceStatus {
  static const Start = 'Назначен';
  static const Refuse = 'Отказ';
  static const Done = 'Выполнен';
  static const End = 'Завершен';
  static const DateSwap = 'ПереносДаты';

  IconData getStatusIcon(String status) {
    var statusIcon;

    switch (status) {
      case ServiceStatus.Start:
        {
          statusIcon = Icons.note;
        }
        break;

      case ServiceStatus.Done:
        {
          statusIcon = Icons.cloud_upload;
        }
        break;

      case ServiceStatus.End:
        {
          statusIcon = Icons.check_box;
        }
        break;

      case ServiceStatus.Refuse:
        {
          statusIcon = Icons.cancel;
        }
        break;

      case ServiceStatus.DateSwap:
        {
          statusIcon = Icons.pending;
        }
        break;
    }

    return statusIcon;
  }
}

class FabsState {
  static const Main = 'main';
  static const GoodAdding = 'goodAdding';
  static const AddImage = 'addImage';
  static const RefusePage = 'refusePage';
  static const ReschedulePage = 'reschedulePage';
  static const PaymentPage = 'paymentPage';
}

class WorkTypes {
  static const TO1 = 'TO1';
  static const TO2 = 'TO2';
  static const Attachment = 'attachment';
}

class PaymentTypes {
  static const Cash = 'Наличные';
  static const Card = 'Безнал';
}

class ClientDecision {
  static const Agree = 'Согласен';
  static const Think = 'Подумаю';
  static const Refuse = 'Отказ';
}
