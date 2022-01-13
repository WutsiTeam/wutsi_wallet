import 'package:contacts_service/contacts_service.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdui/sdui.dart';

import 'event.dart';

void initContacts(String syncUrl) {
  eventBus.on<UserLoggedInEvent>().listen((event) {
    ContactSynchronizer(syncUrl).sync();
  });
}

class ContactSynchronizer {
  final Logger _logger = LoggerFactory.create('ContactSynchronizer');
  final String _syncUrl;

  ContactSynchronizer(this._syncUrl);

  void sync() async {
    _requestPermission().then((value) => _sync(value));
  }

  void _sync(bool flag) {
    if (!flag) {
      _logger.i(
          "User doesn't have permission to contacts. No synchronization with server");
      return;
    }

    ContactsService.getContacts(withThumbnails: false)
        .then((contacts) => _syncContacts(contacts));
  }

  void _syncContacts(List<Contact> contacts) async {
    List<String> phoneNumbers = [];
    for (var i = 0; i < contacts.length; i++) {
      Contact contact = contacts[i];
      if (contact.phones == null) continue;

      for (var j = 0; j < contact.phones!.length; j++) {
        var value = contact.phones?[j].value;
        if (value != null) {
          phoneNumbers.add(value);
        }
      }
    }

    if (phoneNumbers.isNotEmpty) {
      _logger
          .i('phone_number_count=${phoneNumbers.length} - Synching contacts');
      Http.getInstance().post(_syncUrl, {'phoneNumbers': phoneNumbers});
    } else {
      _logger
          .i('phone_number_count=${phoneNumbers.length} - No contact to sync');
    }
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      return await Permission.contacts.request().isGranted;
    } else {
      return true;
    }
  }
}
