import 'package:flutter/foundation.dart';
import 'package:burning2026/core/models/burn_severity_alert.dart';
import 'package:burning2026/mock/repositories/alert_repository_impl.dart';

class AlertProvider extends ChangeNotifier {
  final FakeAlertRepository _repository = FakeAlertRepository();
  List<BurnSeverityAlert> _alerts = [];
  bool _loading = false;

  List<BurnSeverityAlert> get alerts => _alerts;
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    _alerts = await _repository.getAll();
    _loading = false;
    notifyListeners();
  }
}