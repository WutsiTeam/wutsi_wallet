import 'package:contacts_service/contacts_service.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdui/sdui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'event.dart';

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
    _logger.i('Synching contacts');
    _getSyncedPhones().then((phones) => _sync(phones));
  }

  void _sync(List<String>? phones) async {
    if (phones == null) return;

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
        'sync_url=$_syncUrl synced_phoned=${phones.length} all_phone_numbers=${allPhoneNumbers.length} new_phone_numbers=${newPhoneNumbers.length}');
    if (newPhoneNumbers.isNotEmpty) {
      _requestPermission().then(
          (value) => _syncWithServer(value, newPhoneNumbers, allPhoneNumbers));
    }
  }

  void _syncWithServer(
      bool flag, List<String> newPhoneNumbers, List<String> allPhoneNumbers) {
    if (!flag) {
      _logger.i(
          "User doesn't have permission to contacts. No synchronization with server");
      return;
    }

    Http.getInstance().post(_syncUrl, {'phoneNumbers': newPhoneNumbers}).then(
        (value) => _setSyncedPhones(allPhoneNumbers));
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
