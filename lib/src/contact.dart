import 'package:contacts_service/contacts_service.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdui/sdui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wutsi_wallet/src/event.dart';

void initContacts(String syncUrl) {
  eventBus.on<UserLoggedInEvent>().listen((event) {
    ContactSynchronizer(syncUrl).sync();
  });
}

class ContactSynchronizer {
  static const String _preferenceName = 'com.wutsi.last_contact_sync';
  final Logger _logger = LoggerFactory.create('ContactSynchronizer');
  final int _syncDelay = 0; //86400; // 1 days in milliseconds
  final String _syncUrl;

  ContactSynchronizer(this._syncUrl);

  void sync() async {
    _shouldSync().then(
        (value) => _requestPermission(value).then((value) => _sync(value)));
  }

  void _sync(bool flag) {
    if (!flag) {
      return;
    }
    ContactsService.getContacts(withThumbnails: false)
        .then((value) => _syncContacts(value));
  }

  void _syncContacts(List<Contact> contacts) {
    List<String> phoneNumbers = [];
    for (var i = 0; i < contacts.length; i++) {
      Contact contact = contacts[i];
      if (contact.phones == null) {
        continue;
      }

      for (var j = 0; j < contact.phones!.length; j++) {
        var value = contact.phones?[j].value;
        if (value != null) {
          phoneNumbers.add(value);
        }
      }
    }

    _logger.i('sync_url=$_syncUrl phones=$phoneNumbers');
    if (phoneNumbers.isNotEmpty) {
      Http.getInstance().post(
          _syncUrl, {'phoneNumbers': phoneNumbers}).then((value) => _synced());
    }
  }

  void _synced() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_preferenceName, DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> _shouldSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_preferenceName);
    if (lastSync == null) {
      _logger.i('Contacts never synced. Should sync: true');
      return true;
    } else {
      int delay = (DateTime.now().millisecondsSinceEpoch - lastSync) ~/ 1000;
      bool result = delay >= _syncDelay;
      _logger.i('Contacts synced $delay second(s) ago. Should sync: $result');
      return result;
    }
  }

  Future<bool> _requestPermission(bool flag) async {
    if (!flag) {
      return false;
    }

    var status = await Permission.contacts.status;
    if (status.isDenied) {
      return await Permission.contacts.request().isGranted;
    } else {
      return true;
    }
  }
}
