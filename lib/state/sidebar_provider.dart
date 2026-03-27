import 'package:flutter/foundation.dart';

import '../services/session_store.dart';

class SidebarProvider extends ChangeNotifier {
  SidebarProvider({required this.store});

  final SessionStore store;
  bool _isRailExpanded = true;

  bool get isRailExpanded => _isRailExpanded;

  Future<void> restore() async {
    _isRailExpanded = await store.loadSidebarExpanded();
    notifyListeners();
  }

  Future<void> setRailExpanded(bool value) async {
    _isRailExpanded = value;
    notifyListeners();
    await store.saveSidebarExpanded(value);
  }

  Future<void> toggleRail() async {
    await setRailExpanded(!_isRailExpanded);
  }
}
