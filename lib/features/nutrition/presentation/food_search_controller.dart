import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/logging/app_logger.dart';
import '../../../models/food_item.dart';
import '../domain/nutrition_repository.dart';

const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org';

class FoodSearchController extends ChangeNotifier {
  FoodSearchController({
    required NutritionRepository nutritionRepository,
    http.Client? httpClient,
    AppLogger logger = const AppLogger(),
  })  : _nutritionRepository = nutritionRepository,
        _httpClient = httpClient ?? http.Client(),
        _logger = logger;

  final NutritionRepository _nutritionRepository;
  final http.Client _httpClient;
  final AppLogger _logger;

  final Map<String, List<FoodItem>> _searchCache = {};
  final Map<String, FoodItem?> _barcodeCache = {};

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearCache() {
    _searchCache.clear();
    _barcodeCache.clear();
    notifyListeners();
  }

  Future<List<FoodItem>> searchFood(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final local = await _nutritionRepository.searchFoods(trimmed);
    if (local.isNotEmpty) return local;

    return await searchOpenFoodFacts(trimmed);
  }

  Future<List<FoodItem>> searchOpenFoodFacts(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    if (_searchCache.containsKey(trimmed)) {
      return _searchCache[trimmed]!;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse(
        '$openFoodFactsBaseUrl/cgi/search.pl?search_terms=$trimmed&search_simple=1&action=process&json=1&page_size=20',
      );
      final response =
          await _httpClient.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data['products'] as List? ?? [];
        final results = <FoodItem>[];
        for (final p in products) {
          final nutriments = p['nutriments'] ?? {};
          final name = p['product_name'] ?? p['generic_name'] ?? 'Unbekannt';
          final brand = p['brands'] ?? 'Unbekannt';
          final cal =
              nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal'] ?? 0;
          final fat = (nutriments['fat_100g'] ?? 0).toDouble();
          final carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
          final sugar = (nutriments['sugars_100g'] ?? 0).toDouble();
          final prot = (nutriments['proteins_100g'] ?? 0).toDouble();

          if (name != 'Unbekannt' && cal > 0) {
            results.add(
              FoodItem(
                name: name,
                brand: brand,
                barcode: p['code'],
                caloriesPer100g: (cal as num).round(),
                fatPer100g: fat,
                carbsPer100g: carbs,
                sugarPer100g: sugar,
                proteinPer100g: prot,
                source: 'openfoodfacts',
                isVerified: false,
              ),
            );
          }
        }
        _searchCache[trimmed] = results;
        return results;
      }
    } catch (e) {
      _logger.warning('OFF search error for "$trimmed": $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
    return [];
  }

  Future<FoodItem?> searchOpenFoodFactsByBarcode(String barcode) async {
    final code = barcode.trim().toLowerCase();
    if (code.isEmpty) return null;

    final local = await _nutritionRepository.getFoodByBarcode(code);
    if (local != null) return local;

    if (_barcodeCache.containsKey(code)) {
      return _barcodeCache[code];
    }

    _isSearching = true;
    notifyListeners();

    try {
      final url = Uri.parse('$openFoodFactsBaseUrl/api/v2/product/$code.json');
      final response =
          await _httpClient.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final p = data['product'];
          final nutriments = p['nutriments'] ?? {};
          final name = p['product_name'] ?? p['generic_name'] ?? 'Unbekannt';
          final brand = p['brands'] ?? 'Unbekannt';
          final cal =
              nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal'] ?? 0;
          final fat = (nutriments['fat_100g'] ?? 0).toDouble();
          final carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
          final sugar = (nutriments['sugars_100g'] ?? 0).toDouble();
          final prot = (nutriments['proteins_100g'] ?? 0).toDouble();

          final item = FoodItem(
            name: name,
            brand: brand,
            barcode: code,
            caloriesPer100g: (cal as num).round(),
            fatPer100g: fat,
            carbsPer100g: carbs,
            sugarPer100g: sugar,
            proteinPer100g: prot,
            source: 'openfoodfacts',
            isVerified: false,
          );
          _barcodeCache[code] = item;
          return item;
        }
      }
    } catch (e) {
      _logger.warning('OFF barcode error for "$code": $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
    return null;
  }
}
