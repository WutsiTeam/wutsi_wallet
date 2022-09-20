import 'package:contacts_service/contacts_service.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdui/sdui.dart';
import 'package:wutsi_wallet/src/environment.dart';
import 'package:wutsi_wallet/src/event.dart';

final Logger _logger = LoggerFactory.create('contact');

void initContacts(){
  registerLoginEventHanlder((env) => _onLogin(env));
}

void _onLogin(Environment env) async {
  _requestPermission().then((flag) {
    if (flag){
      String url = '${env.getShellUrl()}/commands/sync-contacts';
      _logger.i('Syncing User FCM Token - url=$url');
      ContactsService.getContacts(withThumbnails: false)
          .then((contacts) => _syncContacts(contacts, url));
    }
  });
}

void _syncContacts(List<Contact> contacts, String url) async {
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
        .i('phone_number_count=${phoneNumbers.length} - Syncing contacts');
    Http.getInstance().post(url, {'phoneNumbers': phoneNumbers});
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
