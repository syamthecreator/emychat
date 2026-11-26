import '../models/contact_model.dart';
import '../services/contacts_service.dart';

class ContactsRepository {
  ContactsRepository({ContactsService? contactsService})
      : _contactsService = contactsService ?? ContactsService();

  final ContactsService _contactsService;

  Future<List<ContactModel>> getContacts() async {
    final rawList = await _contactsService.fetchContactsRaw();
    return rawList.map((e) => ContactModel.fromJson(e)).toList();
  }
}
