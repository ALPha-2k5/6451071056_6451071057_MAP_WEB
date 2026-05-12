import 'package:flutter/material.dart';
import '../data/models/attribute_model.dart';

class AttributeController extends ChangeNotifier {
  List<AttributeModel> _allData = [];
  List<AttributeModel> _filteredData = [];
  int currentPage = 0;
  int rowsPerPage = 5;
  String _searchText = "";

  /// SET DATA từ stream
  void setData(List<AttributeModel> data) {
    _allData = data;
    _applyFilter();
  }

  /// SEARCH
  void search(String value) {
    _searchText = value.toLowerCase();
    currentPage = 0;
    _applyFilter();
  }

  /// FILTER LOGIC
  void _applyFilter() {
    if (_searchText.isEmpty) {
      _filteredData = _allData;
    } else {
      _filteredData = _allData.where((e) {
        return e.name.toLowerCase().contains(_searchText) ||
            e.attributeValues.join("|").toLowerCase().contains(_searchText);
      }).toList();
    }
    notifyListeners();
  }

  /// PAGINATION
  List<AttributeModel> get paginatedData {
    final start = currentPage * rowsPerPage;
    final end = start + rowsPerPage;
    return _filteredData.sublist(
      start,
      end > _filteredData.length ? _filteredData.length : end,
    );
  }

  int get totalPages => (_filteredData.length / rowsPerPage).ceil();
}
