import 'package:flutter/foundation.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../models/entries.dart';
import '../../models/entry.dart';
import '../../router/router.gr.dart';
import '../../services/database/database_service.dart';
import '../../services/favicon/favicon_service.dart';
import '../../services/locator.dart';
import '../../utils/validate.dart';
import '../../validators/url_validator.dart';

class HomePasswordsViewModel extends ChangeNotifier {
  Entries _entries = Entries(entries: []);
  Entries get entries => _entries;

  bool _loading = true;
  bool get loading => _loading;

  set loading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  HomePasswordsViewModel() {
    reloadDB(true);
  }

  Future reloadDB([bool reload = false]) async {
    if (reload) {
      await locator<DatabaseService>().reloadDatabaseFromDisk();
    }
    _entries = locator<DatabaseService>().entries;

    notifyListeners();
    await Future.delayed(Duration(milliseconds: 500));
    loading = false;

    notifyListeners();
  }

  Future removeEntry(int itemId) async {
    loading = true;
    notifyListeners();
    locator<DatabaseService>().removeEntryAt(itemId);
    reloadDB();
  }

  Future toAdd() async {
    loading = true;
    Entry entry =
        await locator<NavigationService>().navigateTo(Routes.addAccountScreen);

    await processAddedEntry(entry);
  }

  Future processAddedEntry(Entry entry) async {
    if (entry != null) {
      await locator<DatabaseService>().addEntry(entry);
      reloadDB();

      if (entry.name != null) {
        if (validate<bool>(URLValidator(), entry.name, true, false)) {
          String favicon = await locator<FaviconService>().getBestFavicon(
            entry.name.startsWith("http")
                ? Uri.parse(entry.name).host
                : entry.name.split("/")[0],
          );

          if (favicon.isNotEmpty) {
            Entry newEntry = entry;
            newEntry.favicon = favicon;

            await locator<DatabaseService>().modifyEntry(
              entry,
              newEntry,
            );

            reloadDB();
          }
        }
      }
    } else {
      loading = false;
    }
  }

  void showDetails(Entry entry) {
    locator<NavigationService>().navigateTo(
      Routes.accountDetailsScreen,
      arguments: AccountDetailsScreenArguments(
        entry: entry,
      ),
    );
  }
}
