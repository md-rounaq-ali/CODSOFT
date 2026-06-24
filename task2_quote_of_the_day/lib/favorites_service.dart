import 'package:shared_preferences/shared_preferences.dart';
import 'quote.dart';

class FavoritesService {
  static const _key = 'favorites';

  static Future<List<Quote>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => Quote.deserialize(s)).whereType<Quote>().toList();
  }

  static Future<bool> isFavorite(Quote quote) async {
    final favs = await getFavorites();
    return favs.contains(quote);
  }

  static Future<bool> addFavorite(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final serialized = quote.serialize();
    if (!raw.contains(serialized)) {
      raw.add(serialized);
      await prefs.setStringList(_key, raw);
      return true;
    }
    return false; // already exists
  }

  static Future<void> removeFavorite(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.remove(quote.serialize());
    await prefs.setStringList(_key, raw);
  }
}
