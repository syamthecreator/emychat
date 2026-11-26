import 'package:flutter/foundation.dart';
import '../models/contact_model.dart';
import '../repositories/contacts_repository.dart';

class ContactsProvider extends ChangeNotifier {
  ContactsProvider({ContactsRepository? contactsRepository})
      : _contactsRepository = contactsRepository ?? ContactsRepository() {
    loadContacts();
  }

  final ContactsRepository _contactsRepository;

  List<ContactModel> _allContacts = const [];
  String _selectedChannelFilter = 'all';
  String _searchQuery = '';
  bool _isLoading = false;

  List<ContactModel> get allContacts => _allContacts;
  String get selectedChannelFilter => _selectedChannelFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<ContactModel> get filteredContacts {
    return _allContacts.where((c) {
      final matchesChannel =
          _selectedChannelFilter == 'all' || c.channel == _selectedChannelFilter;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          c.handle.toLowerCase().contains(query);
      return matchesChannel && matchesSearch;
    }).toList();
  }

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allContacts = await _contactsRepository.getContacts();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void setChannelFilter(String filter) {
    if (_selectedChannelFilter == filter) return;
    _selectedChannelFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void reset() {
    _allContacts = const [];
    _selectedChannelFilter = 'all';
    _searchQuery = '';
    _isLoading = false;
    notifyListeners();
  }
}
