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
  static const String _preferenceContactPhones = 'com.wutsi.contact_phones';
  final Logger _logger = LoggerFactory.create('ContactSynchronizer');
  final String _syncUrl;

  ContactSynchronizer(this._syncUrl);

  void sync() async {
    _getSyncedPhones().then((phones) => _sync(phones == null ? [] : phones));
  }

  void _sync(List<String> phones) async {
    ContactsService.getContacts(withThumbnails: false)
        .then((contacts) => _syncContacts(phones, contacts));
  }

  void _syncContacts(List<String> phones, List<Contact> contacts) async {
    List<String> allPhoneNumbers = [];
    List<String> newPhoneNumbers = [];
    for (var i = 0; i < contacts.length; i++) {
      Contact contact = contacts[i];
      if (contact.phones == null) continue;

      for (var j = 0; j < contact.phones!.length; j++) {
        var value = contact.phones?[j].value;
        if (value != null) {
          allPhoneNumbers.add(value);
          if (!phones.contains(value)) {
            newPhoneNumbers.add(value);
          }
        }
      }
    }

    _logger.i(
        'sync_url=$_syncUrl synced_phoned=$phones all_phone_numbers=$allPhoneNumbers new_phone_numbers=$newPhoneNumbers');
    if (newPhoneNumbers.isNotEmpty) {
      _requestPermission()
          .then((value) => _syncWithServer(value, allPhoneNumbers));
    }
  }

  void _syncWithServer(bool flag, List<String> phoneNumbers) {
    if (!flag) return;

    Http.getInstance().post(_syncUrl, {'phoneNumbers': phoneNumbers}).then(
        (value) => _setSyncedPhones(phoneNumbers));
  }

  void _setSyncedPhones(List<String> phones) async =>
      SharedPreferences.getInstance().then(
          (prefs) => prefs.setStringList(_preferenceContactPhones, phones));

  Future<List<String>?> _getSyncedPhones() async =>
      SharedPreferences.getInstance()
          .then((prefs) => prefs.getStringList(_preferenceContactPhones));

  Future<bool> _requestPermission() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      return await Permission.contacts.request().isGranted;
    } else {
      return true;
    }
  }
}
